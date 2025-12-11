extends Control

var current_level: String = ""

func _ready():
	visible = false

func show_game_win():
	visible = true
	get_tree().paused = true
	# Определяем текущий уровень из имени сцены
	var scene_path = get_tree().current_scene.scene_file_path
	if "Level_01" in scene_path:
		current_level = "Level_02"
	elif "Level_02" in scene_path:
		current_level = "Level_03"
	else:
		current_level = ""

func _on_next_level_button_pressed():
	get_tree().paused = false
	if current_level != "":
		var level_paths = {
			"Level_02": "res://Level/Scenes/Level_02.tscn",
			"Level_03": "res://Level/Scenes/Level_03.tscn"
		}
		var next_level_path = level_paths.get(current_level, "")
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)
		else:
			# Если следующего уровня нет, возвращаемся в главное меню
			get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")
	else:
		# Если уровень не определен, возвращаемся в главное меню
		get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")
