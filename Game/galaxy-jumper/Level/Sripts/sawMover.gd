extends CharacterBody2D

# --- Настройки ---
@export var point_b_offset: Vector2 = Vector2(0, 100) # Куда двигаться относительно старта
@export var speed: float = 100.0
@export var wait_time: float = 1.0

# --- Переменные ---
var start_pos: Vector2
var target_pos: Vector2
var is_waiting: bool = false
var wait_timer: float = 0.0

# --- Узлы ---
# Используем @onready для автоматического получения узлов при старте
@onready var anim: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("Saw") # Имя шейпа в вашей сцене "Saw"

func _ready() -> void:
	# 1. Запоминаем начальную и конечную точки
	start_pos = global_position
	target_pos = start_pos + point_b_offset
	
	# 2. Запускаем анимацию ОДИН РАЗ при старте
	if anim:
		anim.play("default")
	else:
		push_warning("Saw: AnimatedSprite2D не найден!")

	# 3. Создаем зону урона (Area2D)
	# Это нужно, чтобы пила убивала игрока при касании, даже если физика тела его оттолкнет
	_create_kill_zone()

func _physics_process(delta: float) -> void:
	# Если находимся в режиме ожидания
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
		return # Пропускаем движение

	# Движение к цели
	global_position = global_position.move_toward(target_pos, speed * delta)

	# Проверка: дошли ли мы до цели?
	if global_position.distance_to(target_pos) < 1.0:
		# Включаем таймер ожидания
		is_waiting = true
		wait_timer = wait_time
		
		# Меняем цель на противоположную
		if target_pos == start_pos:
			target_pos = start_pos + point_b_offset
		else:
			target_pos = start_pos

# --- Вспомогательные функции ---

func _create_kill_zone() -> void:
	var area = Area2D.new()
	area.name = "KillArea"
	add_child(area)
	
	# Копируем форму коллизии пилы для зоны урона
	if collision_shape:
		var shape_copy = collision_shape.duplicate()
		area.add_child(shape_copy)
	else:
		# Если шейп не найден, создаем стандартный круг
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 30.0
		shape.shape = circle
		area.add_child(shape)
	
	# Подключаем сигнал входа в зону
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Если в пилу вошел кто-то, у кого есть метод game_over (например, игрок)
	if body.has_method("game_over"):
		body.game_over()
