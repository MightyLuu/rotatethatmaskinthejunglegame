extends Node

var masks: Array[Mask]
var allowed_masks: Array[bool]
var current_mask_idx: int = 0
var levels: Array[MaskedTileMapLayer]
var player: Player
var current_level: MaskedTileMapLayer
var game_scene: Node2D
var world_map: Node2D
var lvl_size: int = 704-32
var mid_coords: Vector2i
var ui : Control
var game_time_start: float

var mask_scenes = [
	preload("res://assets/masks/mask_0.tscn"),
	preload("res://assets/masks/mask_1.tscn"),
	preload("res://assets/masks/mask_2.tscn"),
	preload("res://assets/masks/mask_3.tscn"),
	preload("res://assets/masks/mask_4.tscn")
	]

var level_scenes = [
	preload("res://assets/levels/demo.tscn"),
	preload("res://assets/levels/lvl_0_1.tscn"),
	preload("res://assets/levels/lvl_0_2.tscn"),
	preload("res://assets/levels/lvl_1_0.tscn"),
	preload("res://assets/levels/lvl_1_1.tscn"),
	preload("res://assets/levels/lvl_1_2.tscn"),
	preload("res://assets/levels/lvl_2_0.tscn"),
	preload("res://assets/levels/lvl_2_1.tscn"),
	preload("res://assets/levels/lvl_2_2.tscn")
	]
	
var player_scene = preload("res://assets/character/character.tscn")

var total_melons: int = 0
var melon_count: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_released("debug_mode"):
		update_melon_count(1)

func allow_mask(id: int) -> void:
	var mui = ui.get_node("HBoxContainer/Right/VBoxContainer/MarginContainer/VBoxContainer").get_child(id)		
	GameManager.allowed_masks[id] = true
	mui.get_node("TextureRect").self_modulate = Color(1, 1, 1, 1)
	if id == 4:
		mui.get_node("TextureRect").texture = load("res://assets/masks/mask4.png")
		mui.get_node("MelonCount").hide()

func update_melon_count(diff: int) -> void:
	if diff > 0:
		total_melons += diff
	melon_count += diff
	var melon_count_label = ui.get_node("HBoxContainer/Right/VBoxContainer/MarginContainer/VBoxContainer/Mask4UI/MelonCount")
	melon_count_label.text = "%s" % melon_count

func preload_assets() -> void:
	allowed_masks = [
		true,
		false,
		false,
		false,
		false
	]	
	masks = []
	for scene in mask_scenes:
		masks.append(scene.instantiate())
	
	# Loading all mask textures because the timing is off when doing it in the mask _ready func
	for m in masks:
		m.texture = load(m.texturePath)
	
	levels = []
	for scene in level_scenes:
		levels.append(scene.instantiate())
		
	player = player_scene.instantiate()
	
	var masks_container = get_tree().get_nodes_in_group("game_scene")[0].get_node("CanvasLayer/MainMenu").get_node("HBoxContainer/Right/VBoxContainer/MarginContainer/VBoxContainer")
	for m_idx in range(masks_container.get_children().size()):
		if m_idx == 0 || m_idx == 4:
			continue
		var mui = masks_container.get_child(m_idx)
		mui.get_node("TextureRect").self_modulate = Color(0.0, 0.0, 0.0, 0.243)
	

func _ready() -> void:	
	preload_assets()

func _process(_delta: float) -> void:
	if current_level:
		write_debug_world_message("Current Level: \n%s" % [current_level.coords])

func init_game() -> void:
	game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	ui = game_scene.get_node("CanvasLayer/MainMenu")
	world_map = game_scene.get_node("WorldMap")
	current_level = levels[2]
	current_level.active_mask = masks[current_mask_idx]
	current_level.switch_mask(current_level.active_mask)
	current_level.set_new_masked_tiles()
	player.switch_mask(current_level.active_mask)
	player.position = Vector2(400, 400)
	mid_coords = game_scene.get_viewport_rect().size / 2
	current_level.position = mid_coords
	world_map.position = Vector2i(0, 0)
	game_scene.add_child(player)
	world_map.add_child(current_level)
	game_scene.add_child(current_level.active_mask)
	highlight_selected_mask()
	game_time_start = Time.get_unix_time_from_system()
	for level in levels:
		if level != current_level:
			level.position = game_scene.get_viewport_rect().size / 2 + Vector2(level.coords.x, level.coords.y-2) * lvl_size
			level.visible = false
			world_map.add_child(level)

func roll_credits() -> void:
	var finished_time = Time.get_unix_time_from_system() - game_time_start
	var credits = ui.get_node("Credits")
	var credits_label = credits.get_node("Time")
	
	var time_dict = Time.get_datetime_dict_from_unix_time(finished_time)
	var hours = time_dict['hour']
	var minutes = time_dict['minute']
	var seconds = time_dict['second']
	
	credits_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
	
	credits.show()

func switch_mask(up: bool) -> void:
	var next_mask_idx = posmod((current_mask_idx + 1 if up else current_mask_idx - 1), allowed_masks.size())
	if allowed_masks[next_mask_idx]:
		game_scene.remove_child(current_level.active_mask)
		current_level.active_mask = masks[next_mask_idx]
		current_level.switch_mask(masks[next_mask_idx])
		current_mask_idx = next_mask_idx
		player.switch_mask(current_level.active_mask)
		game_scene.add_child(current_level.active_mask)
		current_level.active_mask.showMaskOutline(0.2)
		current_level.set_new_masked_tiles()
		playSfx("switchMask")
		highlight_selected_mask()
		if current_mask_idx == 4:
			player.set_physics_process(false)
			player.set_process(false)
			roll_credits()
	else:
		current_mask_idx = (current_mask_idx + 1 if up else current_mask_idx - 1)
		switch_mask(up)
		
func highlight_selected_mask() -> void:
	var masks_container = ui.get_node("HBoxContainer/Right/VBoxContainer/MarginContainer/VBoxContainer")
	var selected_mask = masks_container.get_child(current_mask_idx)
	
	for m in masks_container.get_children():
		m.self_modulate.a = 0
		
	selected_mask.self_modulate.a = 1
	
	
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
	current_level.set_new_masked_tiles()
	
func write_debug_mask_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugMask")
	debug_area.text = message
	
func write_debug_player_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugPlayer")
	debug_area.text = message

func write_debug_world_message(message: String) -> void:
	var debug_area = get_tree().get_first_node_in_group("debug_area").get_node("DebugWorld")
	debug_area.text = message


	
func playSfx(sfxName: String) -> void:
	var sfx : AudioStreamPlayer = ui.get_node(sfxName)
	#duplicate sfx
	var sfx_dup : AudioStreamPlayer = sfx.duplicate()
	ui.add_child(sfx_dup)
	var rand_pitch_offi : float = randf_range(-0.2, 0.2)
	sfx_dup.pitch_scale += rand_pitch_offi
	if sfxName == "spawnMask" && sfx.volume_db > -80:
		sfx_dup.volume_db = min(sfx.volume_db + 12, 24)

	sfx_dup.play()
	await sfx_dup.finished
	sfx_dup.queue_free()