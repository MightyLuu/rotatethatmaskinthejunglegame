extends Node2D
class_name Collectable

var active = false
var time = 0

@export var texture: CompressedTexture2D = null
@export var collectible_id: String = ""
@export var cost: int = 0

func _ready() -> void:
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
	elif collectible_id == "mask1":
		GameManager.allowed_masks[1] = true
	elif collectible_id == "mask2":
		GameManager.allowed_masks[2] = true
	elif collectible_id == "mask3":
		GameManager.allowed_masks[3] = true
	
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_released("pick_up") && active:
		_pick_up()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	active = true
	$Label.visible = true
	

func _on_area_2d_body_exited(_body: Node2D) -> void:
	active = false
	$Label.visible = false
	pass # Replace with function body.

func _process(delta: float) -> void:
	time += delta
	global_position.y += sin(time*5) * 0.1
