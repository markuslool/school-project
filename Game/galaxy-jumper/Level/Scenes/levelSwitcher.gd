extends Control

# --- НАСТРОЙКИ ПУТЕЙ (Следи за регистром букв!) ---
@export var level1_path: String = "res://Level/Scenes/level_01.tscn"
@export var level2_path: String = "res://Level/Scenes/level_02.tscn"
@export var level3_path: String = "res://Level/Scenes/level_03.tscn"
@export var level4_path: String = "res://Level/Scenes/level_04.tscn" # <-- Новый уровень
@export var level5_path: String = "res://Level/Scenes/level_05.tscn" # <-- Новый уровень

@export var github_url: String = "https://github.com/your-repo"
@export var credits_url: String = "https://exmaple.com"

func _ready() -> void:
	# Инициализируем SettingsManager при старте игры
	_init_settings_manager()
	
	var buttons = find_child("Buttons", true, false)
	if buttons == null:
		push_error("levelSwitcher.gd: 'Buttons' node not found")
		return

	var menu_vbox = buttons.find_child("MenuVBox", true, false)
	if menu_vbox == null:
		push_error("levelSwitcher.gd: 'MenuVBox' node not found")
		return

	var level_select_vbox = buttons.find_child("LevelSelectVBox", true, false)
	if level_select_vbox == null:
		push_error("levelSwitcher.gd: 'LevelSelectVBox' node not found")
		return

	# Подключаем кнопки главного меню
	_connect_button(menu_vbox, "PlayButton", "_on_play_pressed")
	_connect_button(menu_vbox, "TextureButton", "_on_github_pressed")
	_connect_button(menu_vbox, "SettingsButton", "_on_settings_pressed")
	_connect_button(menu_vbox, "CreditsButton", "_on_credits_pressed")

	# Подключаем кнопки выбора уровня
	_connect_button(level_select_vbox, "TestButton1", "_on_testbutton1_pressed")
	_connect_button(level_select_vbox, "TestButton2", "_on_testbutton2_pressed")
	_connect_button(level_select_vbox, "TestButton3", "_on_testbutton3_pressed")
	# --- Новые кнопки ---
	_connect_button(level_select_vbox, "TestButton4", "_on_testbutton4_pressed")
	_connect_button(level_select_vbox, "TestButton5", "_on_testbutton5_pressed")
	
	_connect_button(level_select_vbox, "BackButton", "_on_back_pressed")

func _connect_button(parent: Node, btn_name: String, method_name: String) -> void:
	var btn = parent.find_child(btn_name, true, false)
	if btn and btn.has_signal("pressed"):
		if not btn.pressed.is_connected(Callable(self, method_name)):
			btn.pressed.connect(Callable(self, method_name))
	else:
		# Это предупреждение поможет понять, если ты забыл создать кнопку в редакторе
		push_warning("Button '%s' not found or has no pressed signal" % btn_name)

# --- Обработчики нажатий ---

func _on_testbutton1_pressed() -> void:
	if level1_path != "": get_tree().change_scene_to_file(level1_path)

func _on_testbutton2_pressed() -> void:
	if level2_path != "": get_tree().change_scene_to_file(level2_path)

func _on_testbutton3_pressed() -> void:
	if level3_path != "": get_tree().change_scene_to_file(level3_path)

func _on_testbutton4_pressed() -> void:
	if level4_path != "": get_tree().change_scene_to_file(level4_path)

func _on_testbutton5_pressed() -> void:
	if level5_path != "": get_tree().change_scene_to_file(level5_path)

# --- Остальной функционал ---

func _on_github_pressed() -> void:
	if github_url != "": OS.shell_open(github_url)

func _on_settings_pressed() -> void:
	var dialog = find_child("SettingsDialog", true, false)
	if dialog: dialog.popup_centered()

func _on_credits_pressed() -> void:
	if credits_url != "": OS.shell_open(credits_url)

func _on_play_pressed() -> void:
	var buttons = find_child("Buttons", true, false)
	var menu_vbox = buttons.find_child("MenuVBox", true, false)
	var level_select_vbox = buttons.find_child("LevelSelectVBox", true, false)
	
	if menu_vbox and level_select_vbox:
		menu_vbox.visible = false
		level_select_vbox.visible = true

func _on_back_pressed() -> void:
	var buttons = find_child("Buttons", true, false)
	var menu_vbox = buttons.find_child("MenuVBox", true, false)
	var level_select_vbox = buttons.find_child("LevelSelectVBox", true, false)
	
	if menu_vbox and level_select_vbox:
		menu_vbox.visible = true
		level_select_vbox.visible = false

func _init_settings_manager() -> void:
	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager == null:
		var script = load("res://Level/Sripts/SettingsManager.gd")
		settings_manager = script.new()
		settings_manager.name = "SettingsManager"
		get_tree().root.add_child.call_deferred(settings_manager)
		await get_tree().process_frame
		if settings_manager.has_method("_ready"):
			settings_manager._ready()
