extends Camera2D

# Сюда мы перетащим игрока в инспекторе
@export var target: Node2D

# Скорость следования (чем меньше, тем больше "занос")
@export var smooth_speed: float = 1.0

func _physics_process(delta):
	# Проверяем, существует ли цель (игрок), иначе будет ошибка
	if target != null:
		# ТЕКУЩАЯ позиция камеры стремится к ПОЗИЦИИ ИГРОКА
		global_position = global_position.lerp(target.global_position, smooth_speed * delta)
