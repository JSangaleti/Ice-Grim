extends Node
var game
var checks := 0
var failed := false

func _ready() -> void:
	# Use the same menus and actual routed events as the player.
	game.splash()
	await frames(140)
	check(game.state == game.Screen.MENU, "opening advances to main menu")
	await mouse_button("Jogar")
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 1 and game.world != null, "mouse Jogar opens playable phase 1")
	var p = game.world.player
	var x: float = p.position.x
	await key(KEY_D, true)
	await frames(24)
	await key(KEY_D, false)
	check(p.position.x > x + 40, "keyboard moves the player after menu start")
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	await frames(2)
	check(game.state == game.Screen.PAUSED, "Escape opens pause")
	await mouse_button("Continuar")
	await frames(3)
	check(game.state == game.Screen.PLAYING, "mouse Continuar resumes gameplay")
	game.menu()
	await frames(4)
	await mouse_button("Tutorial")
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 0 and game.tutorial, "mouse Tutorial opens independent course")
	game.menu()
	await frames(4)
	await key(KEY_ENTER, true)
	await key(KEY_ENTER, false)
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 1, "Enter on Jogar opens phase 1")
	game.menu()
	await frames(4)
	await key(KEY_S, true)
	await key(KEY_S, false)
	await key(KEY_ENTER, true)
	await key(KEY_ENTER, false)
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 0, "keyboard navigates and opens Tutorial")
	game.menu()
	await frames(4)
	await mouse_button("Créditos")
	await frames(3)
	check(game.state == game.Screen.CREDITS, "mouse Credits works")
	await mouse_button("Voltar ao menu")
	await frames(3)
	check(game.state == game.Screen.MENU, "mouse return from Credits works")
	await mouse_button("Áudio e opções")
	await frames(3)
	check(game.state == game.Screen.SETTINGS, "mouse Settings works")
	await mouse_button("Voltar")
	await frames(3)
	check(game.state == game.Screen.MENU, "mouse return from Settings works")
	# Verify Enter also works when the window initially has no focused button.
	var focus := get_viewport().gui_get_focus_owner()
	if focus != null:
		focus.release_focus()
	await key(KEY_ENTER, true)
	await key(KEY_ENTER, false)
	await frames(70)
	check(game.state == game.Screen.PLAYING and game.level == 1, "Enter starts even without GUI focus")
	if not failed:
		print("UI_TEST_OK: %d routed mouse and keyboard checks" % checks)
		game.quit(0)

func frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames(2)

func find_button(node: Node, text: String) -> Button:
	if node is Button and node.text == text:
		return node
	for child in node.get_children():
		var result := find_button(child, text)
		if result != null:
			return result
	return null

func mouse_button(text: String) -> void:
	var button := find_button(game.overlay, text)
	if button == null:
		check(false, "button exists: " + text)
		return
	# parse_input_event receives physical window coordinates, including stretch.
	var pos: Vector2 = get_viewport().get_final_transform() * button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = pos
	motion.global_position = pos
	Input.parse_input_event(motion)
	await frames(1)
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = pos
	press.global_position = pos
	press.pressed = true
	Input.parse_input_event(press)
	await frames(1)
	press = press.duplicate()
	press.pressed = false
	Input.parse_input_event(press)
	await frames(3)

func check(condition: bool, label: String) -> void:
	if not condition:
		failed = true
		push_error("UI_TEST_FAILED: " + label)
		get_tree().quit(1)
		return
	checks += 1
	print("PASS UI %02d %s" % [checks, label])
