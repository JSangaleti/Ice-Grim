extends Node2D
const SHOT = preload("res://gd/boss_projectile.gd")
const MAX_HP := 9
const CORE_CENTER := Vector2(0, 40)
const CORE_RADIUS := 32.0
var world
var hp := MAX_HP
var active := false
var defeated := false
var exposed := false
var cycle := 0.0
var stagger := 0.0
var body_grace := 0.0
var defeat_time := 0.0
var volley_serial := 0
var fired: Dictionary = {}
var texture: Texture2D
var accepted_dash_serial := -1

func _ready() -> void:
	texture = load("res://assets/generated/scoop.svg")
	z_index = 2

func phase() -> int:
	return 1 + int((MAX_HP - hp) / 3)

func start() -> void:
	active = true
	cycle = -4.0

func _physics_process(delta: float) -> void:
	if world.game.state != world.game.Screen.PLAYING:
		return
	if defeated:
		defeat_time += delta
		if defeat_time >= 0.8 and not world.key_spawned:
			world.spawn_reward()
		queue_redraw()
		return
	if not active:
		return
	var was_exposed := exposed
	body_grace = maxf(0, body_grace - delta)
	if stagger > 0:
		stagger -= delta
	else:
		cycle += delta
		var current_phase := phase()
		var shots := 3 + current_phase - 1
		for i in shots:
			if once("aim%d" % i, 0.35 + i * 0.6):
				aimed_scoop()
		if once("wave", 2.5):
			spawn_shot(SHOT.Kind.WAVE, Vector2(world.width + 25, 472), Vector2(-380 - current_phase * 25, 0))
		if current_phase >= 2 and once("rain", 3.0):
			for lane in [220, 440, 800]:
				spawn_shot(SHOT.Kind.RAIN, Vector2(world.ARENA_START + lane, 110), Vector2(0, 40), 750)
		if current_phase == 3 and once("beam", 2.85):
			spawn_shot(SHOT.Kind.BEAM, Vector2(world.width + 25, 366), Vector2(-360, 0))
		exposed = cycle >= 3.8 + (current_phase - 1) * 0.6 and cycle < 6.5
		if cycle >= 7.0:
			cycle = 0
			fired.clear()
	check_contact(was_exposed)
	queue_redraw()

func once(id: String, at: float) -> bool:
	if cycle < at or fired.has(id):
		return false
	fired[id] = true
	return true

func aimed_scoop() -> void:
	var origin := global_position + Vector2(-45, -15)
	var target: Vector2 = world.player.global_position - Vector2(0, 20)
	var flight := clampf(absf(target.x - origin.x) / 350, 0.45, 1.4)
	var velocity := (target - origin) / flight - Vector2(0, 0.5 * 750 * flight)
	spawn_shot(SHOT.Kind.SCOOP, origin, velocity, 750)
	volley_serial += 1
	world.game.audio.sfx("shot")

func spawn_shot(kind: int, pos: Vector2, velocity: Vector2, gravity: float = 0) -> void:
	var shot = SHOT.new()
	shot.kind = kind
	shot.position = pos
	shot.velocity = velocity
	shot.fall_acceleration = gravity
	shot.world = world
	world.add_child(shot)

func core_rect() -> Rect2:
	return Rect2(global_position + CORE_CENTER - Vector2.ONE * CORE_RADIUS, Vector2.ONE * CORE_RADIUS * 2)

func check_contact(was_exposed: bool = false) -> void:
	var p: IcePlayer = world.player
	var body := Rect2(global_position - Vector2(58, 80), Vector2(116, 160))
	# A dash that entered the opening remains valid until its actual last movement.
	# This avoids the shield closing halfway through a correctly timed attack.
	if p.dashed_this_step and (exposed or was_exposed):
		accepted_dash_serial = p.dash_serial
	elif not p.dashed_this_step:
		accepted_dash_serial = -1
	var valid_dash := p.dashed_this_step and accepted_dash_serial == p.dash_serial
	if valid_dash and p.dash_hits_rect(core_rect()):
		take_hit(true)
	elif body_grace <= 0 and body.intersects(p.collision_rect()) and not (exposed or was_exposed or valid_dash):
		p.die("Contato com o chefe.")

func take_hit(valid_open_dash: bool = false) -> void:
	if not active or defeated or not (exposed or valid_open_dash):
		return
	hp -= 1
	accepted_dash_serial = -1
	exposed = false
	body_grace = 0.6
	stagger = 1.3
	cycle = -0.3
	fired.clear()
	clear_attacks()
	world.player.rebound_from_boss()
	world.burst(global_position + Vector2(0, 40), Color("b8efff"), 36)
	world.game.audio.sfx("key")
	world.game.register_boss_progress(MAX_HP - hp)
	if hp == 0:
		defeated = true
		world.burst(global_position, Color("ffdd9f"), 65)

func clear_attacks() -> void:
	for attack in get_tree().get_nodes_in_group("boss_attacks"):
		attack.queue_free()

func _draw() -> void:
	if defeated:
		var shrink := maxf(0, 1 - defeat_time / 0.7)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * shrink)
		if shrink <= 0:
			return
	var tint := Color("b7ecff") if phase() == 1 else (Color("c8b4ff") if phase() == 2 else Color("ffa4c7"))
	draw_colored_polygon(PackedVector2Array([Vector2(-43, 45), Vector2(43, 45), Vector2(0, 101)]), Color("b78e68"))
	for i in 6:
		draw_line(Vector2(-35 + i * 12, 49), Vector2(-8 + i * 3, 83), Color("805f55"), 2)
	draw_texture_rect(texture, Rect2(-66, -86, 132, 132), false, tint)
	draw_colored_polygon(PackedVector2Array([Vector2(-46, -72), Vector2(-48, -112), Vector2(-24, -91), Vector2(0, -126), Vector2(24, -91), Vector2(48, -112), Vector2(46, -72)]), Color("ffd993"))
	draw_circle(Vector2(0, -100), 6, Color("ed84b3"))
	for x in [-24, 24]:
		draw_line(Vector2(x - 9, -30), Vector2(x + 9, -24 if x < 0 else -36), Color("34243c"), 5)
		draw_circle(Vector2(x, -17), 5, Color("34243c"))
	draw_arc(Vector2(0, 4), 17, 0.2, PI - 0.2, 16, Color("34243c"), 4)
	var core_color := Color("fff4b7") if exposed else Color("62577c")
	draw_circle(Vector2(0, 40), 26, Color("34243c"))
	draw_circle(Vector2(0, 40), 21, core_color)
	if exposed:
		draw_arc(Vector2(0, 40), CORE_RADIUS + sin(cycle * 13) * 2, 0, TAU, 32, Color("aef5ff"), 3)
		draw_line(Vector2(-11, 40), Vector2(11, 40), Color("fffef3"), 4)
