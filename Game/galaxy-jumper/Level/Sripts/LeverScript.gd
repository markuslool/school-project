extends Node2D

var player_near := false
var is_on := false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		toggle_lever()

func toggle_lever():
	is_on = !is_on

	if is_on:
		LeverNumber.LeverCounter += 1
		print("Рычаг ВКЛ | LeverCounter:", LeverNumber.LeverCounter)
	else:
		LeverNumber.LeverCounter -= 1
		print("Рычаг ВЫКЛ | LeverCounter:", LeverNumber.LeverCounter)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_near = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_near = false
