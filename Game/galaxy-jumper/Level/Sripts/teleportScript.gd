extends Area2D

@export var target_teleport: NodePath = NodePath("")
@export var offset_x: float = 0.0
@export var offset_y: float = 0.0
@export var teleport_delay: float = 0.2
@export var cooldown_time: float = 1.0

@export var anim_in: String = "teleport_in"
@export var anim_out: String = "teleport_out"

# Анимации состояний
@export var anim_idle: String = "Idle"
@export var anim_start_work: String = "StartWork"
@export var anim_work: String = "Work"
@export var anim_end_work: String = "EndWork"

var player_inside := false
var player_reference: Node = null
var is_teleporting := false
var can_teleport := true
var cooldown_timer: float = 0.0

@onready var hint_label := $Label
@onready var sprite_node := _find_sprite_node()

func _find_sprite_node() -> Node:
	var n = get_node_or_null("AnimatedSprite2D")
	if n:
		return n
	n = get_node_or_null("Sprite2D")
	if n:
		return n
	for c in get_children():
		if c is AnimatedSprite2D or c is Sprite2D:
			return c
	return null

func _ready():
	hint_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("teleports")
	_play_state_anim(anim_idle)

func _process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			can_teleport = true

	if player_inside and can_teleport and not is_teleporting:
		if sprite_node is AnimatedSprite2D:
			if sprite_node.animation != anim_work:
				return

		if Input.is_action_just_pressed("interact"):
			start_teleport()

func _on_body_entered(body):
	if body.name == "Player" and not is_teleporting:
		player_inside = true
		player_reference = body

		# StartWork → Work
		_play_state_anim(anim_start_work)

		if sprite_node is AnimatedSprite2D:
			await sprite_node.animation_finished
			if player_inside:
				_play_state_anim(anim_work)

		if can_teleport:
			hint_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player_reference = null
		hint_label.visible = false

		# EndWork → Idle
		_play_state_anim(anim_end_work)

		if sprite_node is AnimatedSprite2D:
			await sprite_node.animation_finished
			if not player_inside:
				_play_state_anim(anim_idle)

func start_teleport():
	if player_reference == null or is_teleporting:
		return

	is_teleporting = true
	can_teleport = false
	hint_label.visible = false

	_play_teleport_effect(true)
	await get_tree().create_timer(teleport_delay).timeout

	perform_teleport()

	_play_teleport_effect(false)
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
	else:
		target_position = global_position + Vector2(offset_x, offset_y)

	player_reference.global_position = target_position
	print("Телепортирован в ", target_position)

func _play_state_anim(anim_name: String) -> void:
	if sprite_node and sprite_node is AnimatedSprite2D:
		var frames = sprite_node.sprite_frames
		if frames and anim_name in frames.get_animation_names():
			sprite_node.play(anim_name)

func _play_teleport_effect(is_before: bool) -> void:
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

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite_node, "scale", Vector2(1.2, 1.2), teleport_delay * 0.5)
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
