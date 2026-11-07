class_name IcePlayer
extends CharacterBody2D

const WALK_SPEED := 175.0
const RUN_SPEED := 260.0
const JUMP_SPEED := -470.0
const GRAVITY := 1250.0
const DASH_SPEED := 520.0
const DASH_DURATION := 0.15
var game
var has_key := false
var dash_ready := true
var crouching := false
var dead := false
var damage_protection := 0.0
var facing := 1.0
# Tests inject inputs through the same controller and real physics.
var axis_override := NAN
var jump_override := false
var run_override := false
var crouch_override := false
var dash_override := false
var shape: CollisionShape2D
var sprite: Texture2D
var coyote := 0.0
var buffer := 0.0
var dash_time := 0.0
var animation := 0.0
var trail_timer := 0.0
var dash_facing := 1.0
var dash_pending := 0.0
var jump_dash_wait := 0.0
var dash_serial := 0
var dashed_this_step := false
var dash_step_from := Vector2.ZERO
var dash_step_to := Vector2.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 5.0
	shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(22, 38)
	shape.shape = rect
	shape.position = Vector2(0, -19)
	add_child(shape)
	sprite = load("res://assets/sprites/personagem-principal.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _physics_process(delta: float) -> void:
	if dead or game == null or game.state != game.Screen.PLAYING:
		return
	damage_protection = maxf(0, damage_protection - delta)
	dashed_this_step = false
	var axis: float = Input.get_axis("left", "right") if is_nan(axis_override) else axis_override
	var jump: bool = jump_override or Input.is_action_just_pressed("jump")
	var dash: bool = dash_override or Input.is_action_just_pressed("dash")
	var crouch: bool = crouch_override or Input.is_action_pressed("crouch")
	var run: bool = run_override or Input.is_action_pressed("run")
	jump_override = false
	dash_override = false
	if absf(axis) > 0.1:
		facing = signf(axis)
	if is_on_floor():
		coyote = 0.11
		if dash_time <= 0:
			dash_ready = true
	else:
		coyote -= delta
	buffer = 0.12 if jump else buffer - delta
	if crouch and is_on_floor() and dash_time <= 0:
		_set_crouch(true)
	elif crouching and _can_stand():
		_set_crouch(false)
	if dash and dash_ready and not crouching:
		if buffer > 0 and coyote > 0:
			# Give a simultaneous jump + dash three physics ticks to leave the floor.
			# Otherwise the horizontal dash discards the jump before it can rise.
			dash_pending = 0.12
			jump_dash_wait = 0.05
		else:
			_start_dash()
	if dash_pending > 0:
		dash_pending -= delta
		jump_dash_wait -= delta
		if jump_dash_wait <= 0 and dash_ready and not crouching:
			_start_dash()
			dash_pending = 0
	if dash_time > 0:
		dashed_this_step = true
		dash_step_from = global_position
		dash_time -= delta
		velocity = Vector2(dash_facing * DASH_SPEED, 0)
		if dash_time <= 0:
			velocity.x = dash_facing * WALK_SPEED
		trail_timer -= delta
		if trail_timer <= 0:
			trail_timer = 0.035
			game.world.burst(global_position - Vector2(0, 18), Color("baf6ff"), 3)
	else:
		var target_speed: float = 80.0 if crouching else (RUN_SPEED if run else WALK_SPEED)
		velocity.x = move_toward(velocity.x, axis * target_speed, (1800.0 if is_on_floor() else 1050.0) * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, 760)
		if buffer > 0 and coyote > 0 and not crouching:
			velocity.y = JUMP_SPEED
			buffer = 0
			coyote = 0
			game.audio.sfx("jump")
		if not Input.is_action_pressed("jump") and is_nan(axis_override) and velocity.y < -170:
			velocity.y += GRAVITY * delta * 1.3
	move_and_slide()
	if dashed_this_step:
		dash_step_to = global_position
	animation += delta * (16 if run else 10)
	if global_position.y > 580:
		die("Você caiu no vazio.")
	global_position.x = clampf(global_position.x, 12, game.world.width - 12)
	queue_redraw()

func _start_dash() -> void:
	dash_ready = false
	dash_time = DASH_DURATION
	dash_facing = facing
	dash_serial += 1
	dash_pending = 0
	game.audio.sfx("dash")

func collision_rect() -> Rect2:
	return Rect2(shape.global_position - shape.shape.size / 2, shape.shape.size)

func dash_hits_rect(target: Rect2) -> bool:
	if not dashed_this_step:
		return false
	var half: Vector2 = shape.shape.size / 2
	var from := Rect2(dash_step_from + shape.position - half, shape.shape.size)
	var to := Rect2(dash_step_to + shape.position - half, shape.shape.size)
	return from.merge(to).intersects(target)

func is_dashing() -> bool:
	return dash_time > 0.0

func rebound_from_boss() -> void:
	dash_pending = 0
	dashed_this_step = false
	dash_time = 0
	dash_ready = false
	velocity = Vector2(-360, -330)

func _set_crouch(value: bool) -> void:
	crouching = value
	shape.shape.size = Vector2(22, 20 if value else 38)
	shape.position = Vector2(0, -10 if value else -19)

func _can_stand() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 36)
	query.shape = rect
	query.transform = Transform2D(0, global_position + Vector2(0, -20))
	query.collision_mask = 1
	return get_world_2d().direct_space_state.intersect_shape(query).is_empty()

func die(reason: String, force_game_over: bool = false) -> void:
	if dead or game == null or game.state != game.Screen.PLAYING:
		return
	if not force_game_over and game.level == game.TOTAL_LEVELS and game.world.arena_locked and game.world.boss.active and not game.world.boss.defeated:
		game.world.receive_player_hit(reason)
		return
	dead = true
	game.on_death(reason)

func recover_boss_life(at: Vector2) -> void:
	if dead:
		return
	global_position = at
	velocity = Vector2.ZERO
	dash_time = 0
	dash_pending = 0
	dashed_this_step = false
	dash_ready = true
	buffer = 0
	coyote = 0
	_set_crouch(false)
	queue_redraw()

func _draw() -> void:
	if sprite == null or (damage_protection > 0 and int(damage_protection * 12) % 2 == 0):
		return
	var frame := 0
	if crouching:
		frame = 4
	elif not is_on_floor():
		frame = 5
	elif absf(velocity.x) > 12:
		frame = 2 + int(animation) % 2
	var source := Rect2((frame % 2) * 16, floori(frame / 2.0) * 16, 16, 16)
	draw_set_transform(Vector2(0, -24), 0, Vector2(facing * 3, 3))
	draw_texture_rect_region(sprite, Rect2(-8, -1 if crouching else -8, 16, 9 if crouching else 16), source)
	draw_set_transform(Vector2.ZERO)
