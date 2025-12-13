extends Control

var current_level: String = "" # will store the current scene file path

func _ready():
	visible = false

func show_game_win():
	visible = true
	get_tree().paused = true
	# Сохраняем путь текущей сцены (файл уровня)
	var scene = get_tree().current_scene
	if scene and scene.has_method("get_name"):
		# store file path when available
		current_level = scene.scene_file_path
	else:
		current_level = get_tree().current_scene.scene_file_path

func _on_next_level_button_pressed():
	get_tree().paused = false
	# Попробуем вычислить путь следующего уровня по имени файла текущей сцены
	if current_level != "":
		var filename = current_level.get_file() # e.g. "level_01.tscn"
		var basename = filename.get_basename() # e.g. "level_01"
		if basename.begins_with("level_"):
			var num_str = basename.substr(6, basename.length() - 6)
			# безопасно преобразуем в число
			var num = 0
			var ok = true
			# int() бросает ошибку если не число, используем safe conversion
			# В Godot int(non_numeric) возвращает 0, поэтому проверим на пустую строк
			if num_str != "":
				num = int(num_str)
				# следующий номер
				num += 1
				var next_num = num
				var next_num_str = "0" + str(next_num) if next_num < 10 else str(next_num)
				var next_path = "res://Level/Scenes/level_" + next_num_str + ".tscn"
				if FileAccess.file_exists(next_path):
					get_tree().change_scene_to_file(next_path)
					return
	# По умолчанию — возвращаемся в главное меню
	get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")

func _on_main_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")
