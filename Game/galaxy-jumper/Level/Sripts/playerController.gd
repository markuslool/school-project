extends CharacterBody2D

var speed = 200              # скорость по X
var gravity = 900            # сила гравитации
var jump_force = -400        # сила прыжка

var game_over_menu_scene = preload("res://Level/Scenes/GameOverMenu.tscn")
var game_over_menu

func _ready():
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	game_over_menu = game_over_menu_scene.instantiate()
	canvas_layer.add_child(game_over_menu)

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
	
	# Проверка столкновения с шипами
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.name == "Spikes":
			game_over()
		if collider.name == "Saw":
			game_over()

func game_over():
	if game_over_menu:
		game_over_menu.show_game_over()
