extends Area2D

# Настройки, которые будут видны в Инспекторе
@export var offset_x: float = 0.0
@export var offset_y: float = 0.0

var player_inside := false
var player_reference: Node = null

@onready var hint_label := $Label


func _ready():
	hint_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		player_reference = body
		hint_label.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player_reference = null
		hint_label.visible = false


func _process(_delta):
	if player_inside and Input.is_action_just_pressed("interact"):
		teleport()


func teleport():
	if player_reference == null:
		return

	# Новая позиция = позиция телепорта + смещение из инспектора
	var target_position: Vector2 = global_position + Vector2(offset_x, offset_y)

	player_reference.global_position = target_position
	print("Телепортирован в ", target_position)
