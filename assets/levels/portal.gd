extends Area2D
class_name Portal

@export var lvlCoords : Vector2i = Vector2i.ZERO

func _on_body_entered(body: Player) -> void:
	body.set_physics_process(false)
	body.set_process(false)
	GameManager.switch_level(lvlCoords)
