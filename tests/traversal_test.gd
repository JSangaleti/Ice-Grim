extends Node
var game
var failed := false

func player():
	return game.world.player

func _ready() -> void:
	await frames(2)
	game.start_run(false)
	await frames(75)
	await move(205)
	await jump_land(340)
	await move(365)
	await jump_land(445)
	require_key()
	await move(510)
	await jump_land(655)
	await move(674)
	await jump_land(800)
	await jump_land(914)
	await exit_phase(1)
	await move(190)
	await jump_land(335)
	await jump_land(460)
	require_key()
	await move(500)
	await jump_land(650)
	await move(705)
	await jump_land(835)
	await exit_phase(2)
	await move(145)
	await jump_land(275)
	await jump_land(425)
	await jump_land(580)
	require_key()
	await jump_land(713)
	await jump_land(835)
	await jump_land(914)
	await exit_phase(3)
	await move(205)
	await jump_land(315)
	await move(356)
	player().crouch_override = true
	await move(500, false)
	player().crouch_override = false
	await frames(4)
	await move(540)
	await jump_land(640)
	await jump_land(675)
	await jump_land(750)
	require_key()
	await jump_land(815)
	await jump_land(914)
	await exit_phase(4)
	await move(140)
	await jump_land(275)
	await jump_land(425)
	if player().has_key:
		fail("Escaping key was collected before moving")
	await jump_land(650)
	require_key()
	player().crouch_override = true
	await move(793, false)
	player().crouch_override = false
	await frames(3)
	await jump_land(861)
	player().crouch_override = true
	await move(912, false)
	await exit_phase(5)
	await boss_route()
	if game.state != game.Screen.VICTORY:
		fail("Victory was not reached")
		return
	game.start_run(true)
	await frames(75)
	await move(190)
	await jump_land(330)
	await move(348)
	player().crouch_override = true
	await move(500, false)
	player().crouch_override = false
	await frames(4)
	await jump_land(590)
	require_key()
	await move(680)
	await jump_land(790)
	await move(920)
	for i in 100:
		if game.state == game.Screen.MENU:
			break
		await frames(1)
	if game.state != game.Screen.MENU:
		fail("Tutorial did not return to menu")
		return
	if not failed:
		print("TRAVERSAL_OK: six phases, nine boss hits and tutorial completed with physical movement, key and exit collisions (GDScript)")
		game.quit(0)

func move(x: float, run: bool = true) -> void:
	player().run_override = run
	for i in 300:
		if failed:
			return
		if game.state != game.Screen.PLAYING:
			player().axis_override = 0
			return
		var p = player()
		var dist: float = x - p.position.x
		if absf(dist) < 3 and absf(p.velocity.x) < 25:
			p.axis_override = 0
			return
		var maximum: float = 80 if p.crouching else (260 if run else 175)
		var desired := signf(dist) * minf(maximum, sqrt(2 * 1600 * absf(dist)))
		p.axis_override = desired / maximum
		await frames(1)
		alive()
	fail("Could not walk to %s" % x)

func jump_land(x: float) -> void:
	player().axis_override = 0
	for i in 60:
		if player().is_on_floor() or failed:
			break
		await frames(1)
		alive()
	var distance: float = absf(x - player().position.x)
	player().run_override = true
	player().jump_override = true
	for i in 120:
		if failed:
			return
		var p = player()
		var dist: float = x - p.position.x
		var desired := signf(dist) * minf(260, sqrt(2 * 950 * absf(dist)))
		p.axis_override = 0 if absf(dist) < 2 else desired / 260
		if distance > 135 and i == 18:
			p.dash_override = true
		await frames(1)
		alive()
		if game.state != game.Screen.PLAYING:
			player().axis_override = 0
			return
		if i > 8 and player().is_on_floor():
			player().axis_override = 0
			print("LAND %d %s key=%s" % [game.level, player().position, player().has_key])
			if absf(player().position.x - x) > 22:
				fail("Landed short of %s" % x)
			return
	fail("Failed to land at %s" % x)

func exit_phase(previous: int) -> void:
	player().crouch_override = false
	if game.state == game.Screen.PLAYING:
		await move(920)
	for i in 80:
		if game.state != game.Screen.TRANSITION and game.level != previous:
			break
		await frames(1)
	if previous < 6 and game.level != previous + 1:
		fail("Exit did not advance phase")
	print("TRAVERSAL_PHASE_OK %d" % previous)

func alive() -> void:
	if game.state == game.Screen.DEAD:
		fail("Player died during replay")

func require_key() -> void:
	if not player().has_key:
		fail("Route missed the physical key")

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func fail(message: String) -> void:
	failed = true
	push_error("TRAVERSAL_FAILED phase %d at %s: %s" % [game.level, player().position, message])
	get_tree().quit(1)

func boss_route() -> void:
	player().crouch_override = false
	await move(205)
	await jump_land(340)
	await move(365)
	await jump_land(445)
	await move(510)
	await jump_land(655)
	await move(674)
	await jump_land(800)
	await jump_land(914)
	await move(960 + 145)
	await jump_land(960 + 275)
	await jump_land(960 + 425)
	await jump_land(960 + 580)
	await jump_land(960 + 713)
	await jump_land(960 + 835)
	await jump_land(960 + 914)
	await move(1920 + 205)
	await jump_land(1920 + 315)
	await move(1920 + 356)
	player().crouch_override = true
	await move(1920 + 500, false)
	player().crouch_override = false
	await frames(4)
	await move(1920 + 540)
	await jump_land(1920 + 640)
	await jump_land(1920 + 675)
	await jump_land(1920 + 750)
	await jump_land(1920 + 815)
	await jump_land(1920 + 914)
	await move(2880 + 140)
	await jump_land(2880 + 275)
	await jump_land(2880 + 425)
	await jump_land(2880 + 650)
	player().crouch_override = true
	await move(2880 + 793, false)
	player().crouch_override = false
	await frames(3)
	await jump_land(2880 + 861)
	player().crouch_override = true
	await move(2880 + 955, false)
	player().crouch_override = false
	await move(3840 + 120)
	await jump_land(3840 + 240)
	await jump_land(3840 + 405)
	await jump_land(3840 + 600)
	await move(3840 + 635)
	await fight_boss()
	await frames(55)
	await move(3840 + 730)
	await frames(20)
	require_key()
	await move(4754)
	await frames(5)

func fight_boss() -> void:
	var boss = game.world.boss
	var destination := 3840.0 + 540
	var last_volley: int = boss.volley_serial
	var attack_frame := -1
	var last_hp: int = boss.hp
	for tick in 9000:
		if failed:
			return
		alive()
		var p = player()
		if boss.defeated:
			p.axis_override = 0
			p.crouch_override = false
			print("BOSS_PHYSICAL_CLEAR %.2fs" % (tick / 60.0))
			return
		if boss.hp != last_hp:
			print("BOSS_HIT hp=%d at %.2f pos=%s" % [boss.hp, tick / 60.0, p.position])
			last_hp = boss.hp
			attack_frame = -1
			destination = 3840 + 590
		if boss.volley_serial != last_volley:
			last_volley = boss.volley_serial
			destination = 3840 + (635 if p.position.x < 3840 + 590 else 540)
		p.run_override = true
		var duck := false
		for shot in get_tree().get_nodes_in_group("boss_attacks"):
			if shot.kind == shot.Kind.BEAM and shot.position.x > p.position.x - 35 and shot.position.x < p.position.x + 170:
				duck = true
		p.crouch_override = duck
		if boss.exposed and attack_frame < 0:
			destination = 3840 + 635
			if p.is_on_floor() and absf(p.position.x - destination) < 6 and not duck:
				attack_frame = 0
				p.jump_override = true
		if attack_frame >= 0:
			p.axis_override = 1
			if attack_frame == 6:
				p.dash_override = true
			attack_frame += 1
			if attack_frame > 65:
				fail("Dash missed exposed core")
		else:
			var dist: float = destination - p.position.x
			p.axis_override = 0 if duck or absf(dist) < 2 else signf(dist) * minf(260, sqrt(2 * 1200 * absf(dist))) / 260
		await frames(1)
	fail("Boss fight timed out")
