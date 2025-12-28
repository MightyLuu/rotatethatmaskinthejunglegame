extends TileMapLayer
class_name Mask

@export var texturePath: String
@export var generate_mask_tiles: bool = true

var texture: CompressedTexture2D
var rotating = false

signal start_mask_rotation

func _ready() -> void:
	position = get_viewport_rect().size / 2
	scale = scale * 4
	load_texture_to_tiles()

	
func _input(event):
	if event.is_action_pressed("rotate_mask_right"):
		rotate_mask(false)
	if event.is_action_pressed("rotate_mask_left"):
		rotate_mask(true)


func rotate_mask(left: bool) -> void:
	var tween = create_tween()
	showMaskOutline(0.2)
	GameManager.playSfx("rotateMask")
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
	GameManager.current_level.set_new_masked_tiles()
	tween.kill()

func showMaskOutline(duration: float) -> void:
	GameManager.shaderRect.tweenAberration(duration/2)
	var spriteTween = create_tween()
	spriteTween.tween_method(set_shader_value, 0.0, 0.6, duration);
	spriteTween.tween_method(set_shader_value, 0.6, 0.0, duration*5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD);

func set_shader_value(value: float):
	$Sprite2D.material.set_shader_parameter("outline_color", Color(1, 1, 1, value));
	$Sprite2D.material.set_shader_parameter("inner_alpha", value);

func load_texture_to_tiles() -> void:
	if !generate_mask_tiles:
		return
	var txt: Texture2D = load(texturePath)
	if txt == null:
		push_error("Textur konnte nicht geladen werden")
		return

	var image: Image = txt.get_image()

	var width := image.get_width()
	var height := image.get_height()

	clear()

	for y in height:
		for x in width:
			var color: Color = image.get_pixel(x, y)

			# Prüfen ob Pixel nicht transparent ist
			if color.a > 0.0:
				set_cell(Vector2i(x-10, y-10), 0,Vector2i(0, 0))
