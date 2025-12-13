extends AcceptDialog

@onready var resolution_option: OptionButton = $VBoxContainer/ResolutionContainer/ResolutionOption
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/FullscreenContainer/FullscreenCheckBox
@onready var fps_option: OptionButton = $VBoxContainer/FPSContainer/FPSOption

var settings_manager: Node = null

func _ready():
	# Ищем SettingsManager в автозагрузке или на сцене
	settings_manager = get_node_or_null("/root/SettingsManager")
	
	if settings_manager == null:
		# Если нет в автозагрузке, создаем временный
		var script = load("res://Level/Sripts/SettingsManager.gd")
		settings_manager = script.new()
		settings_manager.name = "SettingsManager"
		# Используем call_deferred, так как мы в _ready()
		get_tree().root.add_child.call_deferred(settings_manager)
		# Ждем следующий кадр для инициализации
		await get_tree().process_frame
		if settings_manager.has_method("_ready"):
			settings_manager._ready()
	
	# Ждем следующий кадр, чтобы убедиться, что все узлы готовы
	await get_tree().process_frame
	_setup_ui()

func _setup_ui():
	# Заполняем список разрешений
	if resolution_option:
		resolution_option.clear()
		var resolution_strings = settings_manager.get_all_resolution_strings()
		for res_string in resolution_strings:
			resolution_option.add_item(res_string)
		
		# Устанавливаем текущее разрешение
		if settings_manager.current_resolution_index < resolution_option.get_item_count():
			resolution_option.selected = settings_manager.current_resolution_index
	
	# Устанавливаем состояние чекбокса полноэкранного режима
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = settings_manager.is_fullscreen
	
	# Заполняем список FPS
	if fps_option:
		fps_option.clear()
		var fps_strings = settings_manager.get_all_fps_strings()
		for fps_string in fps_strings:
			fps_option.add_item(fps_string)
		
		# Устанавливаем текущий FPS
		if settings_manager.current_fps_index < fps_option.get_item_count():
			fps_option.selected = settings_manager.current_fps_index
	
	# Подключаем сигналы
	if resolution_option:
		if not resolution_option.item_selected.is_connected(_on_resolution_selected):
			resolution_option.item_selected.connect(_on_resolution_selected)
	if fullscreen_checkbox:
		if not fullscreen_checkbox.toggled.is_connected(_on_fullscreen_toggled):
			fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	if fps_option:
		if not fps_option.item_selected.is_connected(_on_fps_selected):
			fps_option.item_selected.connect(_on_fps_selected)

func _on_resolution_selected(index: int):
	if settings_manager:
		settings_manager.set_resolution(index)

func _on_fullscreen_toggled(button_pressed: bool):
	if settings_manager:
		settings_manager.set_fullscreen(button_pressed)

func _on_fps_selected(index: int):
	if settings_manager:
		settings_manager.set_fps(index)
