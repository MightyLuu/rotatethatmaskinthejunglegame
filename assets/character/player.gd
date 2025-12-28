extends CharacterBody2D
class_name Player

const GRAVITY = 1200.0
const WALK_SPEED = 200
const JUMP_FORCE = -320.0
const JUMP_HOLD_FORCE := -690.0
const JUMP_HOLD_TIME := 0.69
const MAX_FALL_SPEED := 600
const COYOTE_TIME := 0.12

var jump_time := 0.0
var is_jumping := false
var active_mask: Mask
var is_rotating := false
var facing_right := true
var coyote_timer := 0.0

func switch_mask(mask: Mask) -> void:
	active_mask = mask
	$Mask.texture = mask.texture
	if active_mask.is_connected("start_mask_rotation", rotate_mask):
		active_mask.disconnect("start_mask_rotation", rotate_mask)
	active_mask.connect("start_mask_rotation", rotate_mask)

func rotate_mask(left: bool) -> void:
	var tween = create_tween()
	GameManager.count_rotation()
	if left:
		tween.tween_property($Mask, "rotation_degrees", active_mask.rotation_degrees - 90, 0.2)
	else:
		tween.tween_property($Mask, "rotation_degrees", active_mask.rotation_degrees + 90, 0.2)
	await tween.finished

func _ready() -> void:
	scale = Vector2i(4, 4)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		start_jump()
	if event.is_action_released("jump"):
		is_jumping = false
	if event.is_action_released("switch_mask_down"):
		GameManager.switch_mask(true)
	if event.is_action_released("switch_mask_up"):
		GameManager.switch_mask(false)
		

func start_jump() -> void:
	if is_on_floor() or coyote_timer > 0.0:
		velocity.y = JUMP_FORCE
		jump_time = 0.0
		is_jumping = true
		coyote_timer = 0.0

func _physics_process(delta):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		
	if not is_on_floor(): velocity.y += delta * GRAVITY

	if Input.is_action_pressed("move_left"):
		facing_right = false
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("move_right"):
		facing_right = true
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0
		
	if not facing_right:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	if is_jumping:
		jump_time += delta
		if jump_time < JUMP_HOLD_TIME and Input.is_action_pressed("jump"):
			velocity.y += JUMP_HOLD_FORCE * delta
		else:
			is_jumping = false

	move_and_slide()

func _process(_delta: float) -> void:
	#check if player pos is in lvl bounds
	if global_position.x < GameManager.mid_coords.x-GameManager.lvl_size/2 && GameManager.current_level.coords.x > 0:
		GameManager.switch_level(Vector2i(-1, 0))
	if global_position.x > GameManager.mid_coords.x+GameManager.lvl_size/2 && GameManager.current_level.coords.x < 2:
		GameManager.switch_level(Vector2i(1, 0))
	if global_position.y < GameManager.mid_coords.y-GameManager.lvl_size/2 && GameManager.current_level.coords.y > 0:
		GameManager.switch_level(Vector2i(0, -1))
	if global_position.y > GameManager.mid_coords.y+GameManager.lvl_size/2 && GameManager.current_level.coords.y < 2:
		GameManager.switch_level(Vector2i(0, 1))
	if global_position.y > 1000:
		GameManager.roll_credits_lose()
