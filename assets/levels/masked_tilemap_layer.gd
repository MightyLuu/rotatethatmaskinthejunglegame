extends TileMapLayer

class_name MaskedTileMapLayer

var active_mask: Mask
var time: float = 0.0
@export var coords : Vector2i = Vector2i.ZERO
var current_overlay: Sprite2D = null
var overlymaterial = preload("res://assets/levels/darken.tres")

func _ready() -> void:
	scale = Vector2i(4, 4)
	
func switch_mask(mask: Mask) -> void:
	active_mask = mask

func set_new_masked_tiles() -> void:
	if active_mask.rotating:
		return
	for y in range(-10, 11):
		for x in range(-10, 11):
			var level_coords = Vector2i(x, y)
			var world_coords = self.to_global(self.map_to_local(level_coords))
			var mask_coords = active_mask.local_to_map(active_mask.to_local(world_coords))
			
			var mask_tile_data = active_mask.get_cell_tile_data(mask_coords)
			var level_tile_data = self.get_cell_tile_data(level_coords)

			if not level_tile_data:
				continue
			
			var atlas_coords = self.get_cell_atlas_coords(level_coords)

			if not mask_tile_data:
				if level_tile_data:
					atlas_coords.y = 0
					self.set_cell(level_coords, 0, atlas_coords)
			else:
				atlas_coords.y = 1
				self.set_cell(level_coords, 0, atlas_coords)
	draw_mask()


func draw_mask() -> void:
	var tile_size := self.tile_set.tile_size
	var used :Rect2i= Rect2i(Vector2i(-11,-11), Vector2i(22, 22))
	var image_size := used.size * tile_size
	var image := Image.create(
		image_size.x,
		image_size.y,
		false,
		Image.FORMAT_RGBA8
	)
	var border_px := 4

	image.fill(Color(0, 0, 0, 0))
	for cell in get_used_cells():
		if !is_dark_tile(cell) or !is_in_rect(used, cell):
			continue

		var local_pos = cell - used.position
		var pos = local_pos * tile_size

		var edges = {
			"up":    !is_dark_tile(cell + Vector2i.UP),
			"down":  !is_dark_tile(cell + Vector2i.DOWN),
			"left":  !is_dark_tile(cell + Vector2i.LEFT),
			"right": !is_dark_tile(cell + Vector2i.RIGHT),
			"up_left":    !is_dark_tile(cell + Vector2i(-1, -1)),
			"up_right":   !is_dark_tile(cell + Vector2i(1, -1)),
			"down_left":  !is_dark_tile(cell + Vector2i(-1, 1)),
			"down_right": !is_dark_tile(cell + Vector2i(1, 1)),
		}

		draw_mask_tile(image, pos, tile_size, edges, border_px)
	
	var tex := ImageTexture.create_from_image(image)
	var overlay := Sprite2D.new()
	overlay.texture = tex
	#overlay.material = overlymaterial
	overlay.self_modulate.a = 0.3
	if current_overlay:
		current_overlay.queue_free()
	current_overlay = overlay
	add_child(overlay)

func draw_mask_tile(
	img: Image,
	base: Vector2i,
	size: Vector2i,
	edges: Dictionary,
	border: int
):
	for y in size.y:
		for x in size.x:
			var px = base + Vector2i(x, y)

			var alpha := 1.0

			if edges["left"]  and x < border:
				alpha = min(alpha, float(x) / border)
			if edges["right"] and x > size.x - border:
				alpha = min(alpha, float(size.x - x) / border)
			if edges["up"]    and y < border:
				alpha = min(alpha, float(y) / border)
			if edges["down"]  and y > size.y - border:
				alpha = min(alpha, float(size.y - y) / border)

			if edges["up_left"]    and x < border and y < border:
				alpha = min(alpha, float(x + y) / (border * 2))
			if edges["up_right"]   and x > size.x - border and y < border:
				alpha = min(alpha, float(size.x - x + y) / (border * 2))
			if edges["down_left"]  and x < border and y > size.y - border:
				alpha = min(alpha, float(x + size.y - y) / (border * 2))
			if edges["down_right"] and x > size.x - border and y > size.y - border:
				alpha = min(alpha, float(size.x - x + size.y - y) / (border * 2))

			if alpha > 0.0:
				img.set_pixel(px.x, px.y, Color(0, 0, 0, alpha))

func is_in_rect(rect: Rect2i, pos: Vector2i) -> bool:
	return pos.x >= rect.position.x and pos.x < rect.end.x and pos.y >= rect.position.y and pos.y < rect.end.y

func is_dark_tile(cell: Vector2i) -> bool:
	var atlas_coords = self.get_cell_atlas_coords(cell)
	return atlas_coords.y == 0
