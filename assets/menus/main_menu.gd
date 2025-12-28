extends Control
var volume_label : Label
var volume_label_sfx : Label
var start_volume : float = 42.0
var music : AudioStreamPlayer
var debug_mode : bool = true

func _ready() -> void:
	music = $AudioStreamPlayer
	music.volume_db = -40+start_volume/2
	volume_label = $HBoxContainer/Left/MarginContainer2/VBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/Volume
	volume_label.text = str(int(start_volume))

	#set sfx volume
	volume_label_sfx = $HBoxContainer/Left/MarginContainer2/VBoxContainer/VBoxContainer/VBoxContainerSFX/HBoxContainer/Volume
	volume_label_sfx.text = str(int(start_volume))
	for n in get_tree().get_nodes_in_group("sfx"):
		n.volume_db = -40+start_volume/2

# func _input(event: InputEvent) -> void:
# 	if event.is_action_released("debug_mode"):
# 		debug_mode = !debug_mode
# 		$HBoxContainer/Left/MarginContainer2/VBoxContainer/DebugContent.visible = debug_mode

func _on_demo_level_start_button_up() -> void:
	GameManager.init_game()
	$DemoLevelStart.visible = false
	$HBoxContainer/TextureRect.visible = false
	$HBoxContainer/Right/VBoxContainer.visible = true
	$HBoxContainer/Left/MarginContainer2/VBoxContainer/VBoxContainer/Restart.visible = true




func _on_h_slider_value_changed(value: float) -> void:
	music.volume_db = -40+value/2
	volume_label.text = str(int(value))
	if value == 0:
		music.volume_db = -80



func _on_h_slider_sfx_value_changed(value: float) -> void:
	volume_label_sfx.text = str(int(value))
	for n in get_tree().get_nodes_in_group("sfx"):
		if value == 0:
			n.volume_db = -80
		else:
			n.volume_db = -40+value/2


func _on_restart_button_up() -> void:
	reset()

func _on_button_button_up() -> void:
	$Credits.hide()
	reset()

func reset() -> void:
	var world_map = get_tree().get_first_node_in_group("WorldMap")
	for n in world_map.get_children():
		n.queue_free()
		await n.tree_exited
	var nodes = get_tree().root.get_node("GameScene").get_children()
	for n in nodes:
		if n.name == "CanvasLayer" || n.name == "WorldMap" || n.name == "ShaderLayer":
			continue
		n.queue_free()
		await n.tree_exited
	GameManager.preload_assets()
	GameManager.melon_count = 0
	GameManager.total_melons = 0
	GameManager.update_melon_count(0)
	if !get_node("AudioStreamPlayer").playing:
		get_node("AudioStreamPlayer").play()
	GameManager.current_mask_idx = 0
	GameManager.init_game()