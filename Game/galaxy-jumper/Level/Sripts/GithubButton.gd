extends TextureButton

# Ссылка, на которую будет переход
@export var url: String = "https://example.com"

func _ready():
	# Подключаем сигнал с использованием Callable
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Открыть ссылку в браузере
	OS.shell_open(url)
