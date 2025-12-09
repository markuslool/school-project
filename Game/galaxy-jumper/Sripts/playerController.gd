extends CharacterBody2D

var speed = 200              # скорость по X
var gravity = 900            # сила гравитации
var jump_force = -400        # сила прыжка

func _physics_process(delta):
	# Применяем гравитацию
	if not is_on_floor():
		velocity.y += gravity * delta

	# Управление влево/вправо
	velocity.x = Input.get_action_strength("ui_right") * speed \
				 - Input.get_action_strength("ui_left") * speed

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# Двигаем тело
	move_and_slide()
