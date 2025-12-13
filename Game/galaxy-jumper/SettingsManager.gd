extends Node

# Путь к файлу настроек
const SETTINGS_FILE = "user://settings.cfg"

# Доступные разрешения
var resolutions = [
	Vector2i(1280, 720),   # 16:9
	Vector2i(1366, 768),   # 16:9
	Vector2i(1440, 900),   # 16:10
	Vector2i(1600, 900),   # 16:9
	Vector2i(1920, 1080),  # 16:9
	Vector2i(2560, 1440),  # 16:9
	Vector2i(3840, 2160)   # 16:9
]

# Доступные значения FPS
var fps_options = [30, 60, 120, 144, 240, 0]  # 0 = Unlimited

# Текущие настройки
var current_resolution_index: int = 4  # По умолчанию 1920x1080
var is_fullscreen: bool = false
var current_fps_index: int = 1  # По умолчанию 60 FPS

signal settings_changed()

func _ready():
	load_settings()
	# Откладываем применение настроек, чтобы окно было готово
	call_deferred("apply_settings")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	if err == OK:
		current_resolution_index = config.get_value("display", "resolution_index", 4)
		# Проверяем, что индекс валидный
		if current_resolution_index >= resolutions.size():
			current_resolution_index = 4
		is_fullscreen = config.get_value("display", "fullscreen", false)
		current_fps_index = config.get_value("display", "fps_index", 1)
	else:
		# Используем настройки по умолчанию
		current_resolution_index = 4
		is_fullscreen = false
		current_fps_index = 1

func save_settings():
	var config = ConfigFile.new()
	config.set_value("display", "resolution_index", current_resolution_index)
	config.set_value("display", "fullscreen", is_fullscreen)
	config.set_value("display", "fps_index", current_fps_index)
	config.save(SETTINGS_FILE)

func apply_settings():
	var window = get_window()
	if window == null:
		push_warning("SettingsManager: Window is not available yet")
		return
	
	# На Web платформе размер окна управляется браузером
	if OS.get_name() == "Web":
		apply_fps()
		return

	var resolution = resolutions[current_resolution_index]
	
	# Применяем разрешение
	window.size = resolution
	
	# Применяем полноэкранный режим
	if is_fullscreen:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
	
	# Центрируем окно
	if not is_fullscreen:
		window.move_to_center()
	
	# Настраиваем правильное масштабирование для разных соотношений сторон
	_configure_viewport_stretch(resolution)
	
	# Применяем FPS
	apply_fps()
	
	settings_changed.emit()

func _configure_viewport_stretch(resolution: Vector2i):
	var root = get_tree().root
	if root == null:
		return
	
	# Базовое разрешение viewport (1920x1080)
	var base_size = Vector2i(1920, 1080)
	var base_aspect = float(base_size.x) / float(base_size.y)  # 16:9 = 1.777...
	var current_aspect = float(resolution.x) / float(resolution.y)
	
	# Используем canvas_items режим (как в настройках проекта)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	
	# Если соотношение сторон отличается от базового (16:9), используем expand
	if abs(current_aspect - base_aspect) > 0.01:
		# Для разрешений с другим соотношением сторон (16:10) используем expand
		# Это заполнит весь экран без черных полос, растягивая контент
		root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	else:
		# Для разрешений 16:9 используем стандартный режим keep
		root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP

func set_resolution(index: int):
	if index >= 0 and index < resolutions.size():
		current_resolution_index = index
		save_settings()
		call_deferred("apply_settings")

func set_fullscreen(value: bool):
	is_fullscreen = value
	save_settings()
	call_deferred("apply_settings")

func set_fps(index: int):
	if index >= 0 and index < fps_options.size():
		current_fps_index = index
		save_settings()
		apply_fps()

func apply_fps():
	var fps_value = fps_options[current_fps_index]
	Engine.max_fps = fps_value

func get_fps_string(index: int) -> String:
	if index >= 0 and index < fps_options.size():
		var fps = fps_options[index]
		if fps == 0:
			return "Unlimited"
		return "%d FPS" % fps
	return "Unknown"

func get_all_fps_strings() -> Array:
	var strings = []
	for fps in fps_options:
		if fps == 0:
			strings.append("Unlimited")
		else:
			strings.append("%d FPS" % fps)
	return strings

func get_resolution_string(index: int) -> String:
	if index >= 0 and index < resolutions.size():
		var res = resolutions[index]
		return "%dx%d" % [res.x, res.y]
	return "Unknown"

func get_all_resolution_strings() -> Array:
	var strings = []
	for res in resolutions:
		strings.append("%dx%d" % [res.x, res.y])
	return strings
