extends CharacterBody2D

@export var point_b_offset: Vector2 = Vector2(0, 100)
@export var speed: float = 100.0
@export var wait_time: float = 1.0

@export var animation_node_path: NodePath = NodePath("AnimatedSprite2D")

var point_a: Vector2
var point_b: Vector2
var target: Vector2
var wait_left: float = 0.0

var anim: AnimatedSprite2D


func _ready() -> void:
	# Пытаемся получить доступ к аниматору
	if animation_node_path != NodePath():
		anim = get_node_or_null(animation_node_path)

	if anim == null:
		push_warning("AnimatedSprite2D не найден. Анимация отключена.")

	point_a = global_position
	point_b = point_a + point_b_offset
	target = point_b


func _physics_process(delta: float) -> void:
	if wait_left > 0.0:
		wait_left = max(wait_left - delta, 0.0)
		if anim:
			anim.play("default")
		return

	global_position = global_position.move_toward(target, speed * delta)

	if global_position.distance_to(target) <= 1.0:
		wait_left = wait_time
		target = point_a if target == point_b else point_b
