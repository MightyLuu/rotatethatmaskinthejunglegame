extends ColorRect


func tweenAberration(duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(set_shader_value, -0.005, 0.05, duration);
	tween.tween_method(set_shader_value, 0.05, -0.005, duration*2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD);

func set_shader_value(value: float):
	material.set_shader_parameter("aberration", Color(1, 1, 1, value));
	material.set_shader_parameter("aberration", value);