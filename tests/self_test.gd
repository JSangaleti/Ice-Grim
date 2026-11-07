extends Node
const PROJECTILE = preload("res://gd/projectile.gd")
var game
var checks := 0
var failed := false

func _ready() -> void:
	await frames(2)
	game.start_run(false)
	await frames(90)
	check(game.state == game.Screen.PLAYING and game.level == 1, "campaign starts at phase 1")
	var p = game.world.player
	p.axis_override = 0
	await frames(8)
	check(p.is_on_floor(), "spawn rests on physical floor")
	var x: float = p.position.x
	p.axis_override = 1
	await frames(30)
	p.axis_override = 0
	check(p.position.x > x + 65, "walking accelerates and moves")
	await frames(10)
	var y: float = p.position.y
	p.jump_override = true
	await frames(15)
	check(p.position.y < y - 55, "jump rises under real gravity")
	await frames(55)
	p.dash_override = true
	await frames(2)
	check(not p.dash_ready, "dash consumes charge")
	await frames(25)
	check(p.dash_ready, "landing restores dash")
	var time: float = game.run_time
	game.pause()
	var before: Vector2 = p.position
	await frames(10)
	check(p.position == before and game.run_time == time, "pause freezes physics and timer")
	game.resume()
	p.position = Vector2(682, 484)
	p.axis_override = 1
	p.dash_override = true
	await frames(5)
	check(game.state == game.Screen.DEAD, "dash does not grant invulnerability against spikes")
	game.retry()
	await frames(4)
	check(game.level == 1 and not game.world.player.has_key and game.attempts == 2, "death restores campaign, key and attempt")
	game.start_run(true)
	await frames(75)
	p = game.world.player
	p.axis_override = 1
	p.crouch_override = true
	p.position = Vector2(340, 484)
	await frames(55)
	check(p.crouching and p.position.x > 400 and p.position.x < 470, "crouching traverses low tunnel")
	p.crouch_override = false
	p.axis_override = 0
	await frames(5)
	check(p.crouching, "ceiling prevents standing inside tunnel")
	p.axis_override = 1
	await frames(65)
	p.axis_override = 0
	await frames(5)
	check(not p.crouching and p.position.x > 480, "standing restored after tunnel")
	p.die("test tutorial")
	game.retry()
	await frames(4)
	check(game.level == 0 and game.tutorial, "tutorial death stays outside campaign")
	game.load_level(3)
	game.resume()
	p = game.world.player
	p.axis_override = 0
	p.position = Vector2(275, 454)
	await frames(42)
	check(game.world.get_node("Platform01").collapsed, "crumble support collapses after stepping on it")
	game.load_level(3)
	game.resume()
	await frames(3)
	check(not game.world.get_node("Platform01").collapsed, "scene reload restores crumble platform")
	game.load_level(4)
	game.resume()
	p = game.world.player
	p.axis_override = 0
	p.position = Vector2(340, 484)
	await frames(8)
	var scoop = game.world.get_node("Hazard00")
	check(scoop.triggered and not scoop.falling, "falling scoop uses a consistent internal delay without advance warning")
	p.position = Vector2(505, 484)
	await frames(40)
	check(scoop.falling, "scoop falls after deterministic delay")
	game.start_run(false)
	await frames(75)
	game.load_level(2)
	game.resume()
	p = game.world.player
	p.axis_override = 0
	p.position = Vector2(350, 479)
	await frames(6)
	check(game.state == game.Screen.DEAD, "jelly contact is lethal")
	game.retry()
	await frames(3)
	check(game.level == 1, "later-phase death resets to phase 1")
	game.load_level(5)
	game.resume()
	p = game.world.player
	p.axis_override = 0
	p.crouch_override = true
	p.position = Vector2(885, 484)
	await frames(3)
	var shot = PROJECTILE.new()
	shot.position = Vector2(920, 443)
	game.world.add_child(shot)
	await frames(20)
	check(game.state == game.Screen.PLAYING, "crouching avoids a high cone projectile")
	p.crouch_override = false
	await frames(3)
	shot = PROJECTILE.new()
	shot.position = Vector2(920, 443)
	game.world.add_child(shot)
	await frames(20)
	check(game.state == game.Screen.DEAD, "standing is vulnerable to high cone projectile")
	game.retry()
	await frames(3)
	# State isolation; the other suite validates actual collection/exit collisions.
	for level in range(1, 6):
		check(game.level == level, "phase %d loaded in order" % level)
		p = game.world.player
		p.axis_override = 0
		var exit = game.world.get_node("Exit")
		exit.interact(p)
		check(game.state == game.Screen.PLAYING and game.level == level, "phase %d exit rejects missing key" % level)
		var key_item = game.world.get_node("Key")
		key_item.interact(p)
		if key_item.escape_once:
			check(key_item.escaped and not p.has_key, "key escapes once before collection")
			key_item.interact(p)
		check(p.has_key, "phase %d key collected" % level)
		exit.interact(p)
		await frames(65)
	check(game.level == 6 and game.state == game.Screen.PLAYING, "fifth exit opens boss stage")
	var boss = game.world.boss
	p = game.world.player
	p.axis_override = 0
	p.has_key = true
	game.on_exit()
	check(game.state == game.Screen.PLAYING, "boss blocks victory even with an injected key")
	p.has_key = false
	boss.active = true
	boss.exposed = true
	boss.hp = 1
	boss.take_hit()
	await frames(55)
	check(game.world.key_spawned and boss.defeated, "defeated boss releases final key")
	game.world.get_node("Key").interact(p)
	game.world.get_node("Exit").interact(p)
	check(game.state == game.Screen.VICTORY, "sixth exit after boss ends in victory")
	game.start_run(true)
	await frames(75)
	p = game.world.player
	game.world.get_node("Key").interact(p)
	game.world.get_node("Exit").interact(p)
	await frames(90)
	check(game.state == game.Screen.MENU, "tutorial completion returns to menu")
	check(InputMap.action_get_events("dash").size() >= 2 and InputMap.action_get_events("jump").size() >= 2, "keyboard and gamepad bindings installed")
	if not failed:
		print("SELF_TEST_OK: %d integration checks (GDScript)" % checks)
		game.quit(0)

func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame

func check(condition: bool, label: String) -> void:
	if not condition:
		failed = true
		push_error("SELF_TEST_FAILED: " + label)
		get_tree().quit(1)
		return
	checks += 1
	print("PASS %02d %s" % [checks, label])
