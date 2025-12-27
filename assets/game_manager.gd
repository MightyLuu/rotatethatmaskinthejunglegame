extends Node

var masks: Array[Mask]
var levels: Array[MaskedTileMapLayer]
var player: Player
var current_level: MaskedTileMapLayer
var game_scene: Node2D
var world_map: Node2D
var lvl_size: int = 704-32
var mid_coords: Vector2i

func _ready() -> void:
	masks = [
		preload("res://assets/masks/mask_1.tscn").instantiate()
	]
	levels = [
		preload("res://assets/levels/demo.tscn").instantiate(),
		preload("res://assets/levels/lvl_0_1.tscn").instantiate(),
		preload("res://assets/levels/lvl_0_2.tscn").instantiate(),
		preload("res://assets/levels/lvl_1_0.tscn").instantiate(),
		preload("res://assets/levels/lvl_1_1.tscn").instantiate(),
		preload("res://assets/levels/lvl_1_2.tscn").instantiate(),
		preload("res://assets/levels/lvl_2_0.tscn").instantiate(),
		preload("res://assets/levels/lvl_2_1.tscn").instantiate(),
		preload("res://assets/levels/lvl_2_2.tscn").instantiate()

	]
	player = preload("res://assets/character/character.tscn").instantiate()
	
func _process(_delta: float) -> void:
	if current_level:
		write_debug_world_message("Current Level: \n%s" % [current_level.coords])

func write_debug_player_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugPlayer")
	debug_area.text = message

func write_debug_world_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugWorld")
	debug_area.text = message
	
func write_debug_mask_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugMask")
	debug_area.text = message

func load_level(start_level: int) -> void:
	game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	world_map = game_scene.get_node("WorldMap")
	current_level = levels[start_level]
	current_level.allowed_masks = masks
	current_level.active_mask = masks[0]
	current_level.switch_mask(current_level.active_mask)
	player.switch_mask(current_level.active_mask)
	player.position = Vector2(400, 300)
	mid_coords = game_scene.get_viewport_rect().size / 2
	current_level.position = mid_coords
	game_scene.add_child(player)
	world_map.add_child(current_level)
	game_scene.add_child(current_level.active_mask)
	for level in levels:
		if level != current_level:
			level.position = game_scene.get_viewport_rect().size / 2 + Vector2(level.coords.x, level.coords.y) * lvl_size
			level.visible = false
			world_map.add_child(level)

	
func switch_level(direction: Vector2i) -> void:
	print_debug("switching level" + str(direction))
	player.set_physics_process(false)
	player.set_process(false) 
	var _new_level : MaskedTileMapLayer
	# find direction
	for level in levels:
		if level.coords == current_level.coords + direction:
			_new_level = level
			_new_level.visible = true # kann man auch noch tweenen
			break
	#move level to center
	var tween = create_tween()
	#var player_tween = create_tween()
	tween.tween_property(world_map, "position", world_map.position - Vector2(lvl_size*direction.x, lvl_size*direction.y), 0.25)
	player.position -= Vector2((lvl_size-32)*direction.x, (lvl_size-32)*direction.y)
	#player_tween.tween_property(player, "position", Vector2(player.position.x + offset.x+64, player.position.y), 0.05) # tween verschieb aus irgend nem grun die map?
	await tween.finished
	current_level.visible = false
	#current_level.visible = false # das auch
	_new_level.active_mask = current_level.active_mask
	current_level = _new_level
	player.set_physics_process(true)
	player.set_process(true)


	
