extends TextureButton

func _on_button_up() -> void:
	$"../Help".visible = !$"../Help".visible
	$"../Settings".visible = !$"../Settings".visible
