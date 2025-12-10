extends Control

func _ready():
	visible = false

func show_game_over():
	visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")
