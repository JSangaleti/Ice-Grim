extends "res://tests/traversal_test.gd"

func _ready() -> void:
	await frames(2)
	game.start_run(false)
	await frames(75)
	game.load_level(6)
	game.resume()
	await frames(3)
	var boss = game.world.boss
	if boss.hp != 9 or boss.active or game.world.has_node("Key"):
		fail("Boss did not start locked, intact and inactive")
		return
	game.pause()
	var clock: float = boss.cycle
	await frames(15)
	if boss.cycle != clock:
		fail("Boss does not pause")
	game.resume()
	await boss_route()
	if game.state != game.Screen.VICTORY or game.preferences.boss_best != 9:
		fail("Boss did not finish campaign or save progress")
		return
	game.load_level(6)
	game.resume()
	await frames(3)
	if game.world.boss.hp != 9 or game.world.arena_locked or game.world.key_spawned or not get_tree().get_nodes_in_group("boss_attacks").is_empty():
		fail("Boss encounter did not reset")
		return
	# Focused state tests use position injection; the complete route above never does.
	boss = game.world.boss
	game.world.arena_locked = true
	boss.active = true
	boss.cycle = 4.1
	boss.exposed = true
	var shot_position := Vector2(4160, 230)
	boss.spawn_shot(0, shot_position, Vector2(-50, 0))
	game.pause()
	clock = boss.cycle
	await frames(15)
	var attacks := get_tree().get_nodes_in_group("boss_attacks")
	if boss.cycle != clock or attacks.size() != 1 or attacks[0].position != shot_position:
		fail("Active boss or projectile moved during pause")
		return
	game.resume()
	player().position = boss.position + Vector2(0, 40)
	player().axis_override = 0
	await frames(3)
	if game.state != game.Screen.PLAYING or boss.hp != 9:
		fail("Open boss contact must be safe, but cannot deal damage without dash")
		return
	player().die("focused death rule test", true)
	game.retry()
	await frames(3)
	if game.level != 1:
		fail("Boss death must obey campaign restart rule")
		return
	game.load_level(6)
	game.resume()
	boss = game.world.boss
	game.world.arena_locked = true
	boss.active = true
	boss.cycle = 0.1
	player().position = boss.position + Vector2(-40, 40)
	player().axis_override = 1
	player().dash_override = true
	await frames(3)
	if game.state != game.Screen.PLAYING or game.world.player_lives != 2 or boss.hp != 9:
		fail("Closed boss must reject dash and consume one life")
		return
	game.load_level(6)
	game.resume()
	game.credits()
	var lines := ""
	for child in game.overlay.get_children():
		if child is Label:
			lines += child.text + "\n"
	if not "Arte do jogo e desenvolvimento dos sprites." in lines or not "Composição e desenvolvimento das músicas autorais." in lines or "provisória" in lines or "em breve" in lines:
		fail("Credits must attribute art/sprites to Maria and all included music to Juliano")
		return
	if not ResourceLoader.exists(game.audio.track_path(6)):
		fail("Included boss soundtrack must resolve to an existing audio resource")
		return
	print("BOSS_TEST_OK: long route, nine physical dash hits, three phases, reward, reset, active pause, damage gates, death rule, corrected art/music credits and soundtrack")
	game.quit(0)
