extends Area2D

# Целевой телепорт (можно указать через NodePath в инспекторе)
@export var target_teleport: NodePath = NodePath("")
# Или использовать смещение (если целевой телепорт не указан)
@export var offset_x: float = 0.0
@export var offset_y: float = 0.0
# Задержка перед телепортацией (для эффекта)
@export var teleport_delay: float = 0.2
# Время защиты от повторного использования
@export var cooldown_time: float = 1.0

var player_inside := false
var player_reference: Node = null
var is_teleporting := false
var can_teleport := true
var cooldown_timer: float = 0.0

@onready var hint_label := $Label
var sprite: Sprite2D = null


func _ready():
	hint_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Получаем спрайт
	sprite = get_node_or_null("Sprite2D")
	
	# Добавляем в группу телепортов для поиска
	add_to_group("teleports")


func _process(delta):
	# Обработка кулдауна
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_teleport = true
	
	# Проверка на телепортацию
	if player_inside and can_teleport and not is_teleporting:
		if Input.is_action_just_pressed("interact"):
			start_teleport()


func _on_body_entered(body):
	if body.name == "Player" and not is_teleporting:
		player_inside = true
		player_reference = body
		if can_teleport:
			hint_label.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player_reference = null
		hint_label.visible = false


func start_teleport():
	if player_reference == null or is_teleporting:
		return
	
	is_teleporting = true
	can_teleport = false
	hint_label.visible = false
	
	# Визуальный эффект перед телепортацией
	_play_teleport_effect()
	
	# Задержка перед телепортацией
	await get_tree().create_timer(teleport_delay).timeout
	
	# Выполняем телепортацию
	perform_teleport()
	
	# Задержка после телепортации
	await get_tree().create_timer(teleport_delay).timeout
	
	is_teleporting = false
	cooldown_timer = cooldown_time


func perform_teleport():
	if player_reference == null:
		is_teleporting = false
		return
	
	var target_position: Vector2
	
	# Пытаемся найти целевой телепорт
	var target_teleport_node = get_node_or_null(target_teleport)
	
	if target_teleport_node and target_teleport_node != self:
		# Используем позицию целевого телепорта
		target_position = target_teleport_node.global_position
		# Небольшое смещение вверх, чтобы игрок не застрял
		target_position.y -= 10
	elif target_teleport == NodePath("") or target_teleport_node == null:
		# Используем смещение, если целевой телепорт не указан
		target_position = global_position + Vector2(offset_x, offset_y)
	else:
		# Если целевой телепорт не найден, используем смещение
		target_position = global_position + Vector2(offset_x, offset_y)
	
	# Телепортируем игрока
	player_reference.global_position = target_position
	
	# Визуальный эффект после телепортации
	_play_teleport_effect()
	
	print("Телепортирован в ", target_position)


func _play_teleport_effect():
	# Простой визуальный эффект - изменение масштаба и прозрачности
	if sprite and is_instance_valid(sprite):
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), teleport_delay * 0.5)
		tween.tween_property(sprite, "modulate:a", 0.5, teleport_delay * 0.5)
		tween.tween_callback(func():
			if sprite and is_instance_valid(sprite):
				var tween2 = create_tween()
				tween2.set_parallel(true)
				tween2.tween_property(sprite, "scale", Vector2(1.0, 1.0), teleport_delay * 0.5)
				tween2.tween_property(sprite, "modulate:a", 1.0, teleport_delay * 0.5)
		).set_delay(teleport_delay * 0.5)
