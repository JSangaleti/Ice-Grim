extends "res://tests/ui_test.gd"

func _ready() -> void:
	await frames(2)
	game.preview_victory()
	await frames(4)
	var screen = game.overlay.get_node_or_null("VictoryScreen")
	check(game.state == game.Screen.VICTORY and screen != null, "preview opens actual victory screen")
	check(not game.hud.visible and not game.art.visible, "campaign HUD and title artwork do not overlap victory")
	check(screen.result.new_record and not screen.result.first_win and screen.badge.text == "NOVO RECORDE", "improved result gets record badge")
	check(screen.result.time_text == "02:17.4" and screen.result.best_text == "02:17.4", "actual time and new best are displayed")
	check(screen.result.lives == 2 and screen.result.max_lives == 3 and screen.result.stages == 6 and screen.result.attempts == 3, "victory summarizes lives, stages and attempt")
	check(get_viewport().gui_get_focus_owner() == screen.replay_button, "replay receives initial keyboard focus")
	var time: float = game.run_time
	var position: Vector2 = game.world.player.position
	var animation: float = screen.time
	var count: int = screen.get_child_count()
	await frames(70)
	check(game.run_time == time and game.world.player.position == position, "victory freezes campaign timer and physics")
	check(screen.time > animation and screen.get_child_count() == count, "celebration animates without accumulating particle nodes")
	check(within_viewport(screen) and screen.get_node("ChallengeCaption").get_global_rect().end.x <= 367.5, "labels and buttons fit viewport and caption stays in its column")
	var same_screen = screen
	game.on_exit()
	check(game.overlay.get_node("VictoryScreen") == same_screen, "duplicate exit cannot rebuild victory or erase record badge")
	await key(KEY_S, true)
	await key(KEY_S, false)
	check(get_viewport().gui_get_focus_owner() == screen.menu_button, "keyboard moves focus to menu")
	await key(KEY_ENTER, true)
	await key(KEY_ENTER, false)
	await frames(4)
	check(game.state == game.Screen.MENU and game.world == null, "Enter activates menu action and cleans world")
	check(game.overlay.get_node_or_null("VictoryScreen") == null, "leaving victory removes its animation")
	await fixture(0, 145.2, 3)
	screen = game.overlay.get_node("VictoryScreen")
	check(screen.result.first_win and screen.badge.text == "PRIMEIRA VITÓRIA", "first completion has its own celebration badge")
	check(is_equal_approx(game.preferences.best, 145.2), "first completion sets campaign record")
	await mouse_button("Jogar novamente")
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 1 and game.attempts == 1, "mouse replay starts a fresh campaign in phase one")
	await fixture(120, 158.6, 1)
	screen = game.overlay.get_node("VictoryScreen")
	check(not screen.result.new_record and not screen.result.first_win and screen.badge.text == "CAMPANHA CONCLUÍDA", "slower victory does not invent a new record")
	check(is_equal_approx(game.preferences.best, 120.0) and screen.result.best_text == "02:00.0", "slower run preserves and displays previous best")
	check(screen.result.lives == 1, "remaining life count is taken from the actual encounter")
	await mouse_button("Menu principal")
	await frames(4)
	check(game.state == game.Screen.MENU, "mouse menu action works")
	await fixture(120, 119.4, 2)
	screen = game.overlay.get_node("VictoryScreen")
	check(screen.result.new_record and is_equal_approx(game.preferences.best, 119.4), "faster run updates record")
	await key(KEY_ENTER, true)
	await key(KEY_ENTER, false)
	await frames(70)
	check(game.level == 1 and game.state == game.Screen.PLAYING, "Enter on initial replay button starts gameplay")
	if not failed:
		print("VICTORY_TEST_OK: %d checks; first/new/slower records, real stats, bounded animation, mouse/keyboard replay/menu, cleanup and frozen campaign" % checks)
		game.quit(0)

func fixture(best: float, run: float, lives: int) -> void:
	game.transition_time = 0
	game.after_transition = Callable()
	game.tutorial = false
	game.load_level(6)
	game.resume()
	game.preferences.best = best
	game.run_time = run
	game.world.player_lives = lives
	game.world.boss.hp = 0
	game.world.boss.active = true
	game.world.boss.defeated = true
	game.world.player.has_key = true
	game.on_exit()
	await frames(4)

func within_viewport(node: Node) -> bool:
	if node is Label or node is Button:
		var rect: Rect2 = node.get_global_rect()
		if rect.position.x < 0 or rect.position.y < 0 or rect.end.x > 960.5 or rect.end.y > 540.5:
			print("OUT_OF_BOUNDS ", node.name, " ", rect)
			return false
	for child in node.get_children():
		if not within_viewport(child):
			return false
	return true
