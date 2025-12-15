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
# Имена анимаций в AnimatedSprite2D (если есть)
@export var anim_in: String = "teleport_in"
@export var anim_out: String = "teleport_out"

var player_inside := false
var player_reference: Node = null
var is_teleporting := false
var can_teleport := true
var cooldown_timer: float = 0.0

@onready var hint_label := $Label
@onready var sprite_node := _find_sprite_node()

func _find_sprite_node() -> Node:
	# Пытаемся найти AnimatedSprite2D или Sprite2D в стандартных местах
	var n = get_node_or_null("AnimatedSprite2D")
	if n:
		return n
	n = get_node_or_null("Sprite2D")
	if n:
		return n
	# Поищем среди дочерних узлов
	for c in get_children():
		if c is AnimatedSprite2D or c is Sprite2D:
			return c
	return null

func _ready():
	hint_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("teleports")

func _process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_teleport = true

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

	# Визуальный эффект и анимация перед телепортацией
	_play_teleport_effect(true)

	# Задержка перед телепортацией
	await get_tree().create_timer(teleport_delay).timeout

	# Выполняем телепортацию
	perform_teleport()

	# Визуальный эффект и анимация после телепортации
	_play_teleport_effect(false)

	# Задержка после телепортации
	await get_tree().create_timer(teleport_delay).timeout

	is_teleporting = false
	cooldown_timer = cooldown_time

func perform_teleport():
	if player_reference == null:
		is_teleporting = false
		return

	var target_position: Vector2
	var target_teleport_node = get_node_or_null(target_teleport)

	if target_teleport_node and target_teleport_node != self:
		target_position = target_teleport_node.global_position
		target_position.y -= 10
	elif target_teleport == NodePath("") or target_teleport_node == null:
		target_position = global_position + Vector2(offset_x, offset_y)
	else:
		target_position = global_position + Vector2(offset_x, offset_y)

	# Телепортируем игрока
	player_reference.global_position = target_position

	# Лог
	print("Телепортирован в ", target_position)

func _play_teleport_effect(is_before: bool) -> void:
	# Если найден AnimatedSprite2D, пробуем проиграть указанные анимации
	if sprite_node and is_instance_valid(sprite_node):
		if sprite_node is AnimatedSprite2D:
			var frames = sprite_node.sprite_frames
			if frames:
				var names = frames.get_animation_names()
				if is_before and anim_in in names:
					sprite_node.play(anim_in)
					return
				elif not is_before and anim_out in names:
					sprite_node.play(anim_out)
					return
		# Если узел есть, но нет подходящей анимации — fallback визуал
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite_node, "scale", Vector2(1.2, 1.2), teleport_delay * 0.5)
		# Проверяем, поддерживает ли узел модульную прозрачность (наследует CanvasItem)
		if sprite_node is CanvasItem:
			tween.tween_property(sprite_node, "modulate:a", 0.5, teleport_delay * 0.5)
		tween.tween_callback(func():
				if sprite_node and is_instance_valid(sprite_node):
					var tween2 = create_tween()
					tween2.set_parallel(true)
					tween2.tween_property(sprite_node, "scale", Vector2(1.0, 1.0), teleport_delay * 0.5)
					if sprite_node is CanvasItem:
						tween2.tween_property(sprite_node, "modulate:a", 1.0, teleport_delay * 0.5)
		).set_delay(teleport_delay * 0.5)
	else:
		# Если вообще нет спрайта, ничего не делаем — эффекты визуальны
		return
