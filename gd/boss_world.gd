@tool
extends "res://gd/world.gd"
const BOSS = preload("res://gd/boss.gd")
const ITEM = preload("res://gd/item.gd")
const PLATFORM = preload("res://gd/platform.gd")
const MAX_PLAYER_LIVES := 3
var player_lives := MAX_PLAYER_LIVES
const ARENA_START := 3840.0
var boss
var camera: Camera2D
var key_spawned := false
var arena_locked := false

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	boss = BOSS.new()
	boss.name = "Boss"
	boss.world = self
	boss.position = Vector2(ARENA_START + 730, 292)
	add_child(boss)
	camera = Camera2D.new()
	camera.position = Vector2(480, 270)
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_right = int(width)
	camera.limit_top = 0
	camera.limit_bottom = 540
	add_child(camera)
	camera.make_current()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or player == null:
		return
	if not arena_locked and player.position.x >= ARENA_START + 90:
		arena_locked = true
		var gate = PLATFORM.new()
		gate.name = "ArenaGate"
		gate.position = Vector2(ARENA_START - 20, 100)
		gate.size = Vector2(20, 440)
		add_child(gate)
		boss.start()
	if arena_locked:
		camera.position = Vector2(ARENA_START + 480, 270)
	else:
		camera.position = Vector2(clampf(player.position.x, 480, width - 480), 270)

func spawn_reward() -> void:
	key_spawned = true
	var key = ITEM.new()
	key.name = "Key"
	key.position = Vector2(ARENA_START + 730, 446)
	add_child(key)

func _draw() -> void:
	super._draw()
	for x in range(int(ARENA_START), int(width), 120):
		draw_rect(Rect2(x, 160, 28, 324), Color("34334e"))
		draw_line(Vector2(x - 12, 160), Vector2(x + 40, 160), Color("668598"), 5)
	draw_arc(Vector2(ARENA_START + 730, 292), 155, PI, TAU, 48, Color("4c526d"), 7)

func receive_player_hit(reason: String) -> void:
	if game.state != game.Screen.PLAYING or player.dead or player.damage_protection > 0:
		return
	player_lives = maxi(0, player_lives - 1)
	boss.clear_attacks()
	if player_lives == 0:
		player.die(reason, true)
		return
	# Protection is immediate, including other contacts in this same physics step.
	player.damage_protection = 1.5
	burst(player.position - Vector2(0, 20), Color("f492bc"), 24)
	game.audio.sfx("death")
	# Keep boss HP and attack phase. Return to safe footing outside its body.
	player.recover_boss_life.call_deferred(Vector2(ARENA_START + 590, 402))
