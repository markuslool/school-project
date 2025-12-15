
extends CharacterBody2D

@export var point_b_offset: Vector2 = Vector2(0, 100)   # Смещение от стартовой точки
@export var speed: float = 100.0                        # Скорость движения
@export var wait_time: float = 1.0                      # Задержка в точках

# Требуется ли игроку нажать кнопку перед стартом
@export var activation_action: String = "interact"
@export var activation_key_label: String = "E"
@export var detection_radius: float = 64.0
@export var infinite_drop: bool = true
# Через сколько секунд после начала падения платформа резко ускоряется
@export var snap_delay: float = 2.0
# Во сколько раз увеличивается скорость при обрыве
@export var snap_multiplier: float = 3.0

var point_a: Vector2
var point_b: Vector2
var target: Vector2
var wait_left: float = 0.0
var active: bool = false # движется только если true (активация игроком)
var hint_label: Label = null
var _player_node: Node = null
var active_time: float = 0.0
var snapped: bool = false

func _find_player_node() -> Node:
		# Сначала попробуем по группам (если игрок добавлен в группу "player" или "Player")
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			return nodes[0]
		nodes = get_tree().get_nodes_in_group("Player")
		if nodes.size() > 0:
			return nodes[0]

		# Фоллбек: итеративный обход дерева (без вызова find_node)
		var root = get_tree().get_root()
		var stack: Array = [root]
		while stack.size() > 0:
			var n = stack.pop_back()
			for c in n.get_children():
				if c is Node:
					if c.name == "Player" or c.name == "player":
						return c
					stack.append(c)
		return null


func _ready() -> void:
		# Стартовая точка
		point_a = global_position

		# Конечная точка = стартовая + смещение
		point_b = point_a + point_b_offset

		# Первая цель — точка B
		target = point_b

		# Попытаемся найти игрока через helper
		_player_node = _find_player_node()

		# Если у платформы нет дочернего Label, создадим подсказку
		if has_node("Label"):
			hint_label = $Label
		else:
			hint_label = Label.new()
			hint_label.name = "Label"
			hint_label.text = activation_key_label
			hint_label.horizontal_alignment = 1
			hint_label.vertical_alignment = 1
			hint_label.position = Vector2(0, -32)
			add_child(hint_label)

		hint_label.visible = false


func _physics_process(delta: float) -> void:
		if wait_left > 0.0:
			wait_left = max(wait_left - delta, 0.0)
			return

		# Если платформа активирована игроком — двигаемся
		if active:
			# Если включён режим бесконечного падения - двигаемся только вниз
			if infinite_drop:
				# накапливаем время активации
				active_time += delta
				var current_speed = speed
				if not snapped and active_time >= snap_delay:
					snapped = true
					current_speed = speed * snap_multiplier
				elif snapped:
					current_speed = speed * snap_multiplier
				# Двигаемся вниз по оси Y
				global_position.y += current_speed * delta
				# Можно здесь добавить проверку на выход за границы и удалить/деактивировать платформу
			else:
				# Обычное поведение: движение к цели
				global_position = global_position.move_toward(target, speed * delta)

				# Проверка достижения
				if global_position.distance_to(target) <= 1.0:
					wait_left = wait_time
					# Переключение цели
					target = point_a if target == point_b else point_b
					# Останавливаем платформу до следующей активации
					active = false
					# Показываем подсказку снова, если игрок рядом
					if _is_player_near():
						hint_label.visible = true
					else:
						hint_label.visible = false
		else:
			# Платформа неактивна — проверяем, рядом ли игрок, чтобы показать подсказку
			if _is_player_near():
				hint_label.visible = true
				# Обновляем текст подсказки на текущую кнопку
				hint_label.text = activation_key_label
				# Если игрок нажал кнопку — активируем платформу
				if Input.is_action_just_pressed(activation_action):
					active = true
					hint_label.visible = false
					# сбрасываем счётчики для режима обрыва
					active_time = 0.0
					snapped = false
			else:
				hint_label.visible = false


func _is_player_near() -> bool:
		if _player_node == null or not is_instance_valid(_player_node):
			_player_node = _find_player_node()
			if _player_node == null:
				return false
		# Проверяем, является ли игрок Node2D (чтобы безопасно использовать global_position)
		if not (_player_node is Node2D):
			return false
		var player_pos: Vector2 = _player_node.global_position
		return player_pos.distance_to(global_position) <= detection_radius
