extends Node2D
class_name Collectable

var in_range = false
var time = 0

@export var texture: CompressedTexture2D = null
@export var collectible_id: String = ""
@export var cost: int = 0

func _ready() -> void:
	if collectible_id != "melon" && collectible_id != "mask1":
		self.get_node("Area2D").monitoring = false
		visible = false
	
	$Sprite2D.texture = texture
	if cost > 0:
		$Label.text +=  "\noffer " + str(cost) + " Melons"

func _pick_up() -> void:
	if GameManager.melon_count < cost:
		#error sound
		return
	GameManager.update_melon_count(-cost)

	if collectible_id == "melon":
		GameManager.update_melon_count(1)
		set_mask_visibility()
	elif collectible_id == "mask1":
		GameManager.allow_mask(1)
	elif collectible_id == "mask2":
		GameManager.allow_mask(2)
	elif collectible_id == "mask3":
		GameManager.allow_mask(3)
	elif collectible_id == "winwin":
		GameManager.allow_mask(4)
	queue_free()

func set_mask_visibility() -> void:
	for mask in get_tree().get_nodes_in_group("mask"):
		if mask.collectible_id == "mask2" && GameManager.total_melons >= 3:
			mask.get_node("Area2D").monitoring = true
			mask.visible = true
		if mask.collectible_id == "mask3" && GameManager.total_melons >= 6:
			mask.get_node("Area2D").monitoring = true
			mask.visible = true
		if mask.collectible_id == "winwin" && GameManager.total_melons >= 9:
			mask.get_node("Area2D").monitoring = true
			mask.visible = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("pick_up") && in_range:
		_pick_up()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	in_range = true
	$Label.visible = true
	
func _on_area_2d_body_exited(_body: Node2D) -> void:
	in_range = false
	$Label.visible = false
	pass # Replace with function body.

func _process(delta: float) -> void:
	time += delta
	global_position.y += sin(time*5) * 0.1
