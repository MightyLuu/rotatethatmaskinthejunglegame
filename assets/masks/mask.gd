extends TileMapLayer
class_name Mask

var rotating = false
signal mask_rotated
signal start_mask_rotation

func _ready() -> void:
	position = get_viewport_rect().size / 2
	scale = scale * 4
	
func _input(event):
	if event.is_action_pressed("rotate_mask_right"):
		rotate_mask(false)
	if event.is_action_pressed("rotate_mask_left"):
		rotate_mask(true)


func rotate_mask(left: bool) -> void:
	var tween = create_tween()
	emit_signal("start_mask_rotation", left)
	
	if left and not rotating:
		rotating = true
		tween.tween_property(self, "rotation_degrees", rotation_degrees - 90, 0.2)
	elif not rotating:
		rotating = true
		tween.tween_property(self, "rotation_degrees", rotation_degrees + 90, 0.2)
	else:
		pass
		tween.kill()
		
	await tween.finished
	rotating = false
	emit_signal("mask_rotated")
	tween.kill()
