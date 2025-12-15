extends CharacterBody2D

# ==============================
# Параметры движения и физики
# ==============================

var speed = 200              # скорость по X
var gravity = 900            # сила гравитации
var jump_force = -400        # сила прыжка

# ==============================
# Сцены меню (game over / win)
# ==============================

var game_over_menu_scene = preload("res://Level/Scenes/GameOverMenu.tscn")
var game_win_menu_scene = preload("res://Level/Scenes/GameWinMenu.tscn")
var game_over_menu
var game_win_menu
var level_completed: bool = false
var is_dead: bool = false

# ==============================
# Инициализация сцены
# ==============================

func _ready():
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	game_over_menu = game_over_menu_scene.instantiate()
	game_win_menu = game_win_menu_scene.instantiate()
	canvas_layer.add_child(game_over_menu)
	canvas_layer.add_child(game_win_menu)

# ==============================
# Основной игровой цикл (физика)
# ==============================

func _physics_process(delta):
	if is_dead or level_completed:
		return
	
	# Проверка на падение за пределы экрана
	if global_position.y > 2000:
		game_over()
		return
	
	# Применяем гравитацию
	if not is_on_floor():
		velocity.y += gravity * delta

	# Управление влево/вправо
	velocity.x = Input.get_action_strength("ui_right") * speed \
			   - Input.get_action_strength("ui_left") * speed
	
	# ===== РАЗВОРОТ ПО X =====
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# ===== ЗВУК ДВИЖЕНИЯ (ИСПРАВЛЕННЫЙ БЛОК) =====
	if is_on_floor() and abs(velocity.x) > 0:
		if not $MoveSound.playing:
			$MoveSound.play()
	else:
		if $MoveSound.playing:
			$MoveSound.stop()

	# Двигаем тело
	move_and_slide()

	# ===== АНИМАЦИИ =====
	update_animation()
	
	# ==============================
	# Блок: проверка раздавливания
	# ==============================
	
	var crush_detector = $CrushDetector
	if crush_detector:
		var bodies = crush_detector.get_overlapping_bodies()
		for body in bodies:
			if body == self:
				continue
			if "Platform" in body.name:
				game_over()
				return

	# ==============================
	# Блок: проверка столкновений
	# ==============================
	
	if not level_completed:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is TileMapLayer and collider.name == "Spikes":
				game_over()
				return
			
			if collider.name == "Saw" or "Saw" in collider.name:
				game_over()
				return
			
			if collider.name == "EndLevel":
				level_complete()
				return

# ==============================
# Анимации персонажа
# ==============================

func update_animation():
	if velocity.y < 0 and not is_on_floor():
		play_anim("Jump")
	elif abs(velocity.x) > 0 and is_on_floor():
		play_anim("Walk")
	elif is_on_floor():
		play_anim("Idle")

func play_anim(anim_name: String):
	var sprite = $AnimatedSprite2D
	if sprite.animation != anim_name:
		sprite.play(anim_name)

# ==============================
# Функции управления состоянием игры
# ==============================

func game_over():
	if is_dead:
		return
	is_dead = true
	if game_over_menu:
		game_over_menu.show_game_over()

func level_complete():
	if game_win_menu and not level_completed:
		level_completed = true
		game_win_menu.show_game_win()
