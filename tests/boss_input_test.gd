extends "res://tests/traversal_test.gd"
var checks := 0
var key_state: Dictionary = {}

func _ready() -> void:
	await frames(2)
	game.start_run(false)
	await frames(75)
	# Only fixture placement and HP/stage selection are injected. Every attack uses
	# physical keyboard events and the player's normal controller (axis_override=NAN).
	for health in [9, 6, 3]:
		for start in [630, 650]:
			for held in [3, 60]:
				for delay in [0, 3, 6, 10, 14, 18, 22]:
					var boss = await fixture(health, start)
					key(KEY_D, true)
					key(KEY_W, true)
					for tick in 70:
						if tick == delay:
							key(KEY_SPACE, true)
						if tick == delay + 1:
							key(KEY_SPACE, false)
						if tick == held:
							key(KEY_W, false)
						await frames(1)
						if boss.hp != health or game.state == game.Screen.DEAD:
							break
					check(boss.hp == health - 1 and not game.world.player.dead and game.world.player_lives == 3, "normal keyboard hit: hp=%d start=%d hold=%d delay=%d" % [health, start, held, delay])
					if failed:
						return
					release_keys()
					await frames(40)
					check(game.state == game.Screen.PLAYING and boss.hp == health - 1 and game.world.player_lives == 3, "one hit only and safe recoil after key release")
					if failed:
						return
	var boss = await fixture(3, 630)
	boss.cycle = 6.38
	key(KEY_W, true)
	key(KEY_D, true)
	var saw_close := false
	for tick in 35:
		if tick == 6:
			key(KEY_SPACE, true)
		if tick == 7:
			key(KEY_SPACE, false)
		await frames(1)
		if boss.hp == 3 and not boss.exposed:
			saw_close = true
		if boss.hp < 3 or game.state == game.Screen.DEAD:
			break
	check(saw_close and boss.hp == 2 and not game.world.player.dead, "dash started during opening finishes safely after shield closes")
	boss = await fixture(9, 650)
	game.world.player.position = boss.position + Vector2(-25, 55)
	await frames(5)
	check(game.state == game.Screen.PLAYING and boss.hp == 9, "open body contact is safe, no passive damage")
	boss = await fixture(9, 650)
	game.world.player.position = boss.position + Vector2(-71, 60)
	boss.cycle = 0.1
	boss.exposed = false
	key(KEY_D, true)
	key(KEY_SPACE, true)
	await frames(6)
	check(game.state == game.Screen.PLAYING and game.world.player_lives == 2 and boss.hp == 9, "dash into closed boss costs one life")
	boss = await fixture(9, 650)
	game.world.player.position = boss.position + Vector2(-65, 60)
	boss.cycle = 0.1
	boss.exposed = false
	await frames(3)
	check(game.state == game.Screen.PLAYING and game.world.player_lives == 2 and boss.hp == 9, "ordinary contact with closed boss costs one life")
	boss = await fixture(9, 650)
	game.world.player.position = Vector2(3945, 484)
	var spikes = load("res://gd/hazard.gd").new()
	spikes.position = Vector2(3930, 464)
	spikes.size = Vector2(50, 20)
	game.world.add_child(spikes)
	key(KEY_D, true)
	key(KEY_SPACE, true)
	await frames(5)
	check(game.state == game.Screen.PLAYING and game.world.player_lives == 2 and boss.hp == 9, "open core does not prevent losing a life to spikes")
	release_keys()
	game.load_level(6)
	game.resume()
	await frames(3)
	await boss_route()
	check(game.state == game.Screen.VICTORY and game.world.player_lives == 3, "complete boss route and nine keyboard hits with every attack enabled")
	if not failed:
		print("BOSS_INPUT_TEST_OK: %d checks; 84 real-keyboard attack variants across all three phases, recoil, opening boundary closed-body/spike damage and full nine-hit keyboard fight" % checks)
		game.quit(0)

func fixture(health: int, start: float):
	release_keys()
	game.load_level(6)
	game.resume()
	var world = game.world
	world.arena_locked = true
	var boss = world.boss
	boss.active = true
	boss.hp = health
	boss.cycle = 5.05
	boss.exposed = true
	# Isolate body/core contact; the full campaign suites keep all attacks enabled.
	boss.fired = {"aim0": true, "aim1": true, "aim2": true, "aim3": true, "aim4": true, "wave": true, "rain": true, "beam": true}
	world.player.position = Vector2(3840 + start, 402)
	await frames(3)
	check(is_nan(world.player.axis_override), "normal player input path")
	return boss

func key(code: int, pressed: bool) -> void:
	if key_state.get(code, false) == pressed:
		return
	key_state[code] = pressed
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func release_keys() -> void:
	for code in [KEY_A, KEY_D, KEY_W, KEY_S, KEY_SPACE, KEY_SHIFT]:
		key(code, false)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func check(condition: bool, label: String) -> void:
	if failed:
		return
	if not condition:
		failed = true
		push_error("BOSS_INPUT_TEST_FAILED: " + label)
		get_tree().quit(1)
		return
	checks += 1
	print("PASS BOSS_INPUT %03d %s" % [checks, label])

func horizontal(direction: float, run: bool = true) -> void:
	key(KEY_A, direction < 0)
	key(KEY_D, direction > 0)
	key(KEY_SHIFT, run)

func fight_boss() -> void:
	var boss = game.world.boss
	var p = player()
	p.axis_override = NAN
	p.run_override = false
	p.crouch_override = false
	var destination := 3840.0 + 540
	var last_volley: int = boss.volley_serial
	var last_hp: int = boss.hp
	var attack_frame := -1
	var dash_delay := 0
	for tick in 9000:
		if failed:
			return
		alive()
		if boss.defeated:
			release_keys()
			p.axis_override = 0
			print("BOSS_KEYBOARD_FIGHT_OK: nine keyboard hits, all attacks enabled, %.2fs" % (tick / 60.0))
			return
		if boss.hp != last_hp:
			print("KEYBOARD_BOSS_HIT hp=%d time=%.2f" % [boss.hp, tick / 60.0])
			last_hp = boss.hp
			attack_frame = -1
			destination = 3840 + 590
		if boss.volley_serial != last_volley:
			last_volley = boss.volley_serial
			destination = 3840 + (635 if p.position.x < 3840 + 590 else 540)
		var duck := false
		for shot in get_tree().get_nodes_in_group("boss_attacks"):
			if shot.kind == shot.Kind.BEAM and shot.position.x > p.position.x - 35 and shot.position.x < p.position.x + 170:
				duck = true
		key(KEY_S, duck)
		if boss.exposed and attack_frame < 0:
			destination = 3840 + 635
			if p.is_on_floor() and p.position.x >= 3840 + 630 and p.position.x <= 3840 + 650 and not duck:
				attack_frame = 0
				dash_delay = [0, 6, 12, 18][(9 - boss.hp) % 4]
		if attack_frame >= 0:
			horizontal(1)
			key(KEY_W, attack_frame < 3)
			key(KEY_SPACE, attack_frame == dash_delay)
			attack_frame += 1
			if attack_frame > 65:
				fail("Keyboard dash missed open core")
		else:
			key(KEY_W, false)
			key(KEY_SPACE, false)
			var dist: float = destination - p.position.x
			horizontal(0 if duck or absf(dist) < 8 else signf(dist), absf(dist) > 40)
		await frames(1)
	fail("Keyboard boss fight timed out")
