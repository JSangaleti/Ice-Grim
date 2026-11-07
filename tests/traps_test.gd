extends Node
var game
var failed := false
var checks := 0

func player():
	return game.world.player

func _ready() -> void:
	await frames(2)
	game.start_run(false)
	await frames(75)
	for id in range(1, 6):
		game.load_level(id)
		game.resume()
		await frames(2)
		var hints: Array = game.world.get_children().filter(func(n): return str(n.name).begins_with("Hint"))
		check(hints.is_empty(), "phase %d has no advance instruction signs" % id)
	game.load_level(1)
	game.resume()
	await frames(2)
	var spikes = game.world.get_node("ExitSurprise")
	check(not spikes.triggered and spikes.emergence == 0 and spikes.hit_shape.disabled, "surprise spikes start hidden and harmless")
	player().axis_override = 0
	player().position = Vector2(800, 484)
	await frames(2)
	check(spikes.triggered and spikes.emergence > 0, "approach reveals surprise spikes")
	var progress: float = spikes.emergence
	game.pause()
	await frames(12)
	check(spikes.emergence == progress, "pause freezes spike emergence")
	game.resume()
	await frames(12)
	check(spikes.lethal and not spikes.hit_shape.disabled, "emerged spikes enable real lethal collision")
	player().position = Vector2(858, 478)
	await frames(4)
	check(game.state == game.Screen.DEAD, "emerged surprise spikes kill by actual contact")
	game.retry()
	await frames(2)
	spikes = game.world.get_node("ExitSurprise")
	check(not spikes.triggered and spikes.hit_shape.disabled, "retry restores concealed spikes")
	game.load_level(3)
	game.resume()
	var fake_floor = game.world.get_node("Platform04")
	check(fake_floor.crumble and fake_floor.camouflage, "deceptive floor uses normal appearance")
	player().axis_override = 0
	player().position = Vector2(700, 478)
	await frames(28)
	check(fake_floor.collapsed and fake_floor.collision.disabled, "deceptive floor actually collapses when stepped on")
	game.load_level(3)
	game.resume()
	check(not game.world.get_node("Platform04").collapsed, "reload restores deceptive floor")
	game.load_level(5)
	game.resume()
	player().axis_override = 0
	player().position = Vector2(427, 420)
	await frames(5)
	var key_item = game.world.get_node("Key")
	check(key_item.escaped and not player().has_key and key_item.position == Vector2(645, 448), "key escapes on first real contact")
	player().position = Vector2(645, 484)
	await frames(5)
	check(player().has_key and not key_item.visible, "escaped key is reachable and collectible by real contact")
	game.load_level(5)
	game.resume()
	check(not game.world.get_node("Key").escaped and game.world.get_node("Key").position == Vector2(427, 384), "reload resets escaping key")
	game.on_death("TESTE_DE_DICA_QUE_NAO_DEVE_APARECER")
	check(not labels_contain(game.overlay, "TESTE_DE_DICA"), "Game Over does not reveal hazard hints")
	# Walk-speed traversal: no dash, no run and no teleports within the course.
	for wait_frames in [0, 24, 72]:
		game.load_level(4)
		game.resume()
		await frames(3)
		await move(205)
		await jump_land(315)
		await move(356)
		player().crouch_override = true
		await move(500)
		player().crouch_override = false
		await frames(4)
		await move(540)
		await jump_land(640)
		await frames(wait_frames)
		await jump_land(675)
		await jump_land(750)
		check(player().has_key, "phase 4 key reachable without run/dash, wait=%d" % wait_frames)
		await jump_land(815)
		await jump_land(914)
		await exit_phase(4)
		check(game.level == 5, "phase 4 clears at walk speed, wait=%d" % wait_frames)
		print("PHASE4_WALK_ONLY_OK: wait=%d, no dash, no run, physical key and exit" % wait_frames)
	if not failed:
		print("TRAPS_TEST_OK: %d checks; phase 4 physically cleared at walk speed in three timing variants" % checks)
		game.quit(0)

func labels_contain(node: Node, needle: String) -> bool:
	if node is Label and needle in node.text:
		return true
	for child in node.get_children():
		if labels_contain(child, needle):
			return true
	return false

func check(condition: bool, label: String) -> void:
	if not condition:
		fail(label)
		return
	checks += 1
	print("PASS TRAP %02d %s" % [checks, label])

func move(x: float) -> void:
	player().run_override = false
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
		var maximum: float = 80 if p.crouching else 175
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
	player().run_override = false
	player().jump_override = true
	for i in 120:
		if failed:
			return
		var p = player()
		var dist: float = x - p.position.x
		var desired := signf(dist) * minf(175, sqrt(2 * 950 * absf(dist)))
		p.axis_override = 0 if absf(dist) < 2 else desired / 175
		await frames(1)
		alive()
		if game.state != game.Screen.PLAYING:
			player().axis_override = 0
			return
		if i > 8 and player().is_on_floor():
			player().axis_override = 0
			if absf(player().position.x - x) > 22:
				fail("Landed short of %s: %s" % [x,player().position])
			return
	fail("Failed to land at %s" % x)

func exit_phase(previous: int) -> void:
	if game.state == game.Screen.PLAYING:
		await move(920)
	for i in 80:
		if game.state != game.Screen.TRANSITION and game.level != previous:
			break
		await frames(1)
	if game.level != previous + 1:
		fail("Exit did not advance phase")

func alive() -> void:
	if game.state == game.Screen.DEAD:
		fail("Player died at %s" % player().position)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func fail(message: String) -> void:
	failed = true
	push_error("TRAPS_TEST_FAILED: " + message)
	get_tree().quit(1)
