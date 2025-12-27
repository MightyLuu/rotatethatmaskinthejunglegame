extends Node

var masks: Array[Mask]
var levels: Array[MaskedTileMapLayer]
var player: Player
var current_level: MaskedTileMapLayer
var game_scene: Node2D
var world_map: Node2D
var lvl_size: int = 704-32

func _ready() -> void:
	masks = [
		preload("res://assets/masks/mask_1.tscn").instantiate()
	]
	levels = [
		preload("res://assets/levels/demo.tscn").instantiate(),
		preload("res://assets/levels/lvl2.tscn").instantiate()
	]
	player = preload("res://assets/character/character.tscn").instantiate()

func load_level(start_level: int) -> void:
	game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	world_map = game_scene.get_node("WorldMap")
	current_level = levels[start_level]
	current_level.allowed_masks = masks
	current_level.active_mask = masks[0]
	current_level.switch_mask(current_level.active_mask)
	player.switch_mask(current_level.active_mask)
	player.position = Vector2(400, 300)
	current_level.position = game_scene.get_viewport_rect().size / 2
	game_scene.add_child(player)
	world_map.add_child(current_level)
	game_scene.add_child(current_level.active_mask)
	for level in levels:
		if level != current_level:
			level.position = game_scene.get_viewport_rect().size / 2 + Vector2(level.coords.x, level.coords.y) * lvl_size
			level.visible = false
			world_map.add_child(level)

	
func switch_level(coords: Vector2i) -> void: 
	var current_coords = current_level.coords
	var _new_level : MaskedTileMapLayer
	# find direction
	var offset : Vector2 = Vector2i.ZERO
	if coords.x > current_coords.x:
		#right
		offset.x = -lvl_size
	elif coords.x < current_coords.x:
		#left
		offset.x = lvl_size
	if coords.y > current_coords.y:
		#down
		offset.y = -lvl_size
	elif coords.y < current_coords.y:
		#up
		offset.y = lvl_size
	for level in levels:
		if level.coords == coords:
			_new_level = level
			_new_level.visible = true # kann man auch noch tweenen
			break
	#move level to center
	var tween = create_tween()
	#var player_tween = create_tween()
	tween.tween_property(world_map, "position", world_map.position + Vector2(offset.x*coords.x, offset.y*coords.y), 0.25)
	player.position.x += offset.x
	#player_tween.tween_property(player, "position", Vector2(player.position.x + offset.x+64, player.position.y), 0.05) # tween verschieb aus irgend nem grun die map?
	await tween.finished
	#current_level.visible = false # das auch
	current_level = _new_level
	player.set_physics_process(true)
	player.set_process(true)


	
