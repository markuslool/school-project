extends Node

# Пути к уровням
var level_paths = {
	"Level_01": "res://Level/Scenes/Level_01.tscn",
	"Level_02": "res://Level/Scenes/Level_02.tscn",
	"Level_03": "res://Level/Scenes/Level_03.tscn"
}

# Сюда будем хранить текущую сцену (меню или уровень)
var current_scene: Node = null

func _ready():
	# Получаем меню напрямую из корня сцены
	current_scene = get_node("/root/Main_Menu") # путь указываем согласно твоей иерархии

	# Подключаем сигналы кнопок меню
	var buttons_node = current_scene.get_node("Buttons")
	for button in buttons_node.get_children():
		if button is Button:
			button.pressed.connect(func():
				load_level(button.name.replace("TestButton", "Level_0"))
			)

# Функция загрузки уровня
func load_level(level_name: String):
	# Загружаем новый уровень
	var level_scene = load(level_paths.get(level_name, ""))
	if level_scene:
		var new_level = level_scene.instantiate()
		add_child(new_level)

		# После успешной загрузки удаляем старую сцену
		if current_scene:
			current_scene.queue_free()
		
		# Обновляем текущую сцену
		current_scene = new_level
