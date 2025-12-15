extends Node2D

# Level-specific logic for SkiKe Level 5
# - detect player touching spikes (calls player's game_over())
# - detect reaching end level (calls player's level_complete())

@export var spikes_node_name: String = "Spikes"
@export var end_node_name: String = "EndLevel"

var _player: Node = null
var _spikes: Node = null
var _end_area: Node = null
var _dead_or_won: bool = false

func _ready() -> void:
	# find player (search groups first)
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes.size() > 0:
		_player = nodes[0]
	else:
		# fallback: search current scene (use safe DFS helper to avoid calling find_node on nodes that may not have it)
		_player = _find_node_by_name("Player")

	# find spikes TileMap/node by name
	# find spikes and end area by name in the current scene
	_spikes = _find_node_by_name(spikes_node_name)
	_end_area = _find_node_by_name(end_node_name)

	# connect end area if it exists and is Area2D
	if _end_area and _end_area is Area2D:
		_end_area.body_entered.connect(_on_end_body_entered)

func _find_node_by_name(name: String) -> Node:
	var scene = get_tree().get_current_scene()
	if scene == null:
		return null
	var stack: Array = [scene]
	while stack.size() > 0:
		var n = stack.pop_back()
		if n.name == name:
			return n
		for c in n.get_children():
			if c is Node:
				stack.append(c)
	return null

	# connect end area if it exists and is Area2D
	if _end_area and _end_area is Area2D:
		_end_area.body_entered.connect(_on_end_body_entered)

	# sanity logs
	if not _player:
		push_warning("skikelevel5: Player node not found; spike/end checks will be disabled.")
	if not _spikes:
		push_warning("skikelevel5: Spikes node not found; spike checks disabled.")

func _physics_process(delta: float) -> void:
	if _dead_or_won:
		return
	if _player and _spikes:
		_check_spikes_collision()

func _check_spikes_collision() -> void:
	# Only check if player has a global_position and not already dead
	if not (_player is Node2D):
		return
	# If player already has is_dead flag, don't trigger again
	# rely on local _dead_or_won flag to avoid duplicate triggers

	# TileMap API: world_to_map + get_cellv
	if _spikes is TileMap:
		var cell = _spikes.world_to_map(_player.global_position)
		var tile_id = _spikes.get_cellv(cell)
		if tile_id != -1:
			_on_player_hit_spike()
	else:
		# If spikes is not a TileMap, but an Area2D, check overlap
		if _spikes is Area2D:
			var overlapping = _spikes.get_overlapping_bodies()
			for b in overlapping:
				if b == _player:
					_on_player_hit_spike()
					return

func _on_player_hit_spike() -> void:
	_dead_or_won = true
	if _player and _player.has_method("game_over"):
		_player.game_over()
	else:
		push_warning("skikelevel5: Player has no game_over() method; cannot trigger game over UI.")

func _on_end_body_entered(body: Node) -> void:
	if _dead_or_won:
		return
	if body == _player:
		_dead_or_won = true
		if _player and _player.has_method("level_complete"):
			_player.level_complete()
		else:
			push_warning("skikelevel5: Player has no level_complete() method; cannot trigger win UI.")
