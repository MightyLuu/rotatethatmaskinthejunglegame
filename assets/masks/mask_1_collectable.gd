extends Node2D

var active = false

@export var texture: CompressedTexture2D = null
@export var collectible_id: String = ""

func _ready() -> void:
	$Sprite2D.texture = texture

func pick_up() -> void:
	if collectible_id == "Melon":
		GameManager.melon_count += 1
	elif collectible_id == "Mask0":
		GameManager.allowed_masks[1] = true
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_released("pick_up"):
		pick_up()

func _on_area_2d_body_entered(_body: Node2D) -> void:
	active = true
	$Label.visible = true
	

func _on_area_2d_body_exited(_body: Node2D) -> void:
	active = false
	$Label.visible = false
	pass # Replace with function body.
