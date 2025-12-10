extends Control

@export var level1_path: String = "res://Level/Scenes/Level_01.tscn"
@export var level2_path: String = "res://Level/Scenes/Level_02.tscn"
@export var level3_path: String = "res://Level/Scenes/Level_03.tscn"
@export var github_url: String = "https://github.com/your-repo"
@export var credits_url: String = "https://exmaple.com"

func _ready() -> void:
	# Ищем контейнер с кнопками (исправлено на find_child для Godot 4)
	var buttons = find_child("Buttons", true, false)
	if buttons == null:
		push_error("levelSwitcher.gd: 'Buttons' node not found")
		return

	var menu_vbox = buttons.find_child("MenuVBox", true, false)
	if menu_vbox == null:
		push_error("levelSwitcher.gd: 'MenuVBox' node not found")
		return

	# Подключаем кнопки
	_connect_button(menu_vbox, "TestButton1", "_on_testbutton1_pressed")
	_connect_button(menu_vbox, "TestButton2", "_on_testbutton2_pressed")
	_connect_button(menu_vbox, "TestButton3", "_on_testbutton3_pressed")
	_connect_button(menu_vbox, "TextureButton", "_on_github_pressed")
	
	# Новые кнопки
	_connect_button(menu_vbox, "SettingsButton", "_on_settings_pressed")
	_connect_button(menu_vbox, "CreditsButton", "_on_credits_pressed")

func _connect_button(parent: Node, btn_name: String, method_name: String) -> void:
	var btn = parent.find_child(btn_name, true, false)
	if btn and btn.has_signal("pressed"):
		if not btn.pressed.is_connected(Callable(self, method_name)):
			btn.pressed.connect(Callable(self, method_name))
	else:
		push_warning("Button '%s' not found or has no pressed signal" % btn_name)

func _on_testbutton1_pressed() -> void:
	if level1_path != "":
		get_tree().change_scene_to_file(level1_path)

func _on_testbutton2_pressed() -> void:
	if level2_path != "":
		get_tree().change_scene_to_file(level2_path)

func _on_testbutton3_pressed() -> void:
	if level3_path != "":
		get_tree().change_scene_to_file(level3_path)

func _on_github_pressed() -> void:
	if github_url != "":
		OS.shell_open(github_url)

func _on_settings_pressed() -> void:
	var dialog = find_child("SettingsDialog", true, false)
	if dialog:
		dialog.popup_centered()

func _on_credits_pressed() -> void:
	if credits_url != "":
		OS.shell_open(credits_url)
