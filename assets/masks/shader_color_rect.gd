extends ColorRect
var aberration: float = 0.05

func _ready():
	GameManager.shaderRect = self
	
func tweenAberration(duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(set_shader_value, -0.005, aberration, duration/2);
	tween.tween_method(set_shader_value, aberration, -0.005, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD);

func set_shader_value(value: float):
	material.set_shader_parameter("aberration", value);
	material.set_shader_parameter("aberration", value);