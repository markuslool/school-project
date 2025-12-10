extends CharacterBody2D

@export var point_b_offset: Vector2 = Vector2(0, 100)   # Смещение от стартовой точки
@export var speed: float = 100.0                        # Скорость движения
@export var wait_time: float = 1.0                      # Задержка в точках

var point_a: Vector2
var point_b: Vector2
var target: Vector2
var wait_left: float = 0.0


func _ready() -> void:
	# Стартовая точка
	point_a = global_position

	# Конечная точка = стартовая + смещение
	point_b = point_a + point_b_offset

	# Первая цель — точка B
	target = point_b


func _physics_process(delta: float) -> void:
	if wait_left > 0.0:
		wait_left = max(wait_left - delta, 0.0)
		return

	# Движение
	global_position = global_position.move_toward(target, speed * delta)

	# Проверка достижения
	if global_position.distance_to(target) <= 1.0:
		wait_left = wait_time

		# Переключение цели
		target = point_a if target == point_b else point_b
