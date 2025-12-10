extends CharacterBody2D

# Точки движения
var point_a := Vector2()
var point_b := Vector2()
var speed := 100

var target_pos := Vector2()
var wait_time := 1.0      # задержка в секундах
var wait_left := 0.0      # внутренний таймер ожидания

var hight := 100          # значение по умолчанию, если метаданных нет

func _ready():
	# Получаем метаданные "Hight", если они есть
	if has_meta("Hight"):
		hight = int(get_meta("Hight"))
	
	point_a = global_position
	point_b = Vector2(point_a.x, point_a.y + hight)
	target_pos = point_b

func _physics_process(delta):
	# Если есть задержка — уменьшаем таймер и не двигаемся
	if wait_left > 0:
		wait_left -= delta
		return

	# Движение к цели
	global_position = global_position.move_toward(target_pos, speed * delta)

	# Проверяем достижение цели
	if global_position.distance_to(target_pos) < 1:
		wait_left = wait_time                        # запустить задержку
		# Меняем цель
		target_pos = point_a if target_pos == point_b else point_b
