extends Node

const CONTROLS = preload("res://gd/controls.gd")
const AUDIO = preload("res://gd/audio.gd")
const VICTORY_SCREEN = preload("res://gd/victory_screen.gd")
const TITLE_ART = preload("res://gd/title_art.gd")
enum Screen { SPLASH, MENU, PLAYING, PAUSED, TRANSITION, DEAD, VICTORY, CREDITS, SETTINGS }
const NAMES := ["Tutorial", "Travessia", "Patrulha", "Passos de açúcar", "Chuva de sorvete", "Última colherada", "Rei da Nevasca"]
@export var iniciar_na_fase_1 := false
const TOTAL_LEVELS := 6
const TEST_SUITES := {
	"--ui-test": "res://tests/ui_test.gd",
	"--self-test": "res://tests/self_test.gd",
	"--traps-test": "res://tests/traps_test.gd",
	"--boss-input-test": "res://tests/boss_input_test.gd",
	"--boss-test": "res://tests/boss_test.gd",
	"--traversal-test": "res://tests/traversal_test.gd",
	"--music-lives-test": "res://tests/music_lives_test.gd",
	"--victory-test": "res://tests/victory_test.gd",
}
var state := Screen.SPLASH
var world
var audio
var level := 0
var attempts := 1
var tutorial := false
var run_time := 0.0
var preferences := {"music": 0.65, "sfx": 0.8, "deaths": 0, "best": 0.0, "legacy_best_five": 0.0, "boss_best": 0}
var test_mode := false
var layer: CanvasLayer
var ui: Control
var hud: Control
var overlay: Control
var phase_label: Label
var key_label: Label
var clock_label: Label
var dash_label: Label
var boss_bar: ProgressBar
var boss_name: Label
var lives_label: Label
var toast_label: Label
var art: Node2D
var font: Font
var toast_time := 0.0
var transition_time := 0.0
var after_transition: Callable
var settings_from_pause := false
var quitting := false
var args: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	CONTROLS.setup()
	args = Array(OS.get_cmdline_user_args())
	test_mode = TEST_SUITES.keys().any(func(flag): return flag in args) or "--dev-victory" in args or args.any(func(a): return str(a).begins_with("--capture"))
	_load_preferences()
	font = load("res://assets/fonts/Interface.ttf")
	audio = AUDIO.new()
	audio.name = "Audio"
	audio.silent_for_tests = test_mode
	add_child(audio)
	audio.set_volume(preferences.music, preferences.sfx)
	audio.track(0)
	art = TITLE_ART.new()
	add_child(art)
	layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	ui = Control.new()
	ui.name = "Interface"
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.theme = _build_theme()
	hud = Control.new()
	hud.name = "HUD"
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = Control.new()
	overlay.name = "Screens"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	phase_label = _text(hud, "", Vector2(24, 15), 20)
	key_label = _text(hud, "", Vector2(410, 18), 15)
	clock_label = _text(hud, "", Vector2(705, 18), 15)
	dash_label = _text(hud, "", Vector2(24, 46), 12)
	toast_label = _text(hud, "", Vector2(200, 88), 15, Color("ffddac"))
	lives_label = _text(hud, "", Vector2(24, 76), 15, Color("ffb5cc"))
	boss_name = _text(hud, "REI DA NEVASCA", Vector2(284, 50), 13, Color("b8efff"))
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(284, 74)
	boss_bar.size = Vector2(392, 14)
	boss_bar.min_value = 0
	boss_bar.max_value = 9
	boss_bar.show_percentage = false
	boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar.add_theme_stylebox_override("background", _box("201b33", "765675"))
	boss_bar.add_theme_stylebox_override("fill", _box("9ad9ee", "b8efff"))
	hud.add_child(boss_bar)
	for flag in TEST_SUITES:
		if flag in args:
			var suite = load(TEST_SUITES[flag]).new()
			suite.game = self
			add_child(suite)
			return

	print("[Ice Grim v1.3.3] Cena principal carregada: ", ProjectSettings.globalize_path(scene_file_path if not scene_file_path.is_empty() else "res://scenes/Main.tscn"))
	if "--dev-victory" in args:
		preview_victory()
		return
	if "--play" in args or "--tutorial" in args:
		start_run("--tutorial" in args)
		return
	if "--capture-menu" in args:
		menu()
		return
	for flag in ["--dev-level", "--capture-level"]:
		var index: int = args.find(flag)
		if index >= 0 and index + 1 < args.size() and str(args[index + 1]).is_valid_int():
			var id := int(args[index + 1])
			if id >= 0 and id <= TOTAL_LEVELS:
				start_run(id == 0)
				load_level(id)
				resume()
				transition_time = 0
				after_transition = Callable()
				return
	var screen_index: int = args.find("--capture-screen")
	if screen_index >= 0 and screen_index + 1 < args.size():
		var screen: String = args[screen_index + 1]
		menu()
		if screen == "credits":
			credits()
		elif screen == "settings":
			settings(false)
		elif screen == "victory":
			preview_victory()
		else:
			start_run(false)
			load_level(5)
			resume()
			transition_time = 0
			after_transition = Callable()
			if screen == "pause":
				pause()
			elif screen == "death":
				on_death("A geleinha é perigosa por todos os lados.")
			else:
				world.player.has_key = true
				on_exit()
		return
	if iniciar_na_fase_1:
		start_run(false)
		return
	splash()

func _process(delta: float) -> void:
	if state == Screen.PLAYING:
		run_time += delta
	if transition_time > 0:
		transition_time -= delta
		if transition_time <= 0:
			var callback := after_transition
			after_transition = Callable()
			if callback.is_valid():
				callback.call()
	if toast_time > 0:
		toast_time -= delta
		if toast_time <= 0:
			toast_label.text = ""
	hud.visible = world != null and state != Screen.VICTORY
	var encounter = world.boss if world != null and level == TOTAL_LEVELS else null
	boss_bar.visible = encounter != null and encounter.active and not encounter.defeated
	boss_name.visible = boss_bar.visible
	lives_label.visible = encounter != null and world.arena_locked
	if lives_label.visible:
		lives_label.text = "VIDAS  %d / %d" % [world.player_lives, world.MAX_PLAYER_LIVES]
	if boss_bar.visible:
		boss_bar.value = encounter.hp
		boss_name.text = "REI DA NEVASCA    %d / %d" % [encounter.hp, encounter.MAX_HP]
	if world != null:
		phase_label.text = "TUTORIAL" if tutorial else "%02d / %02d   %s" % [level, TOTAL_LEVELS, world.level_name.to_upper()]
		key_label.text = "CHAVE  •  COLETADA" if world.player.has_key else "CHAVE  •  PENDENTE"
		key_label.modulate = Color("a9ffd4") if world.player.has_key else Color("ffda9e")
		if level == TOTAL_LEVELS and not world.boss.defeated:
			key_label.text = "CHEFE  •  %d / %d" % [world.boss.hp, world.boss.MAX_HP]
		clock_label.text = "%s    TENTATIVA %02d" % [time_text(run_time), attempts]
		dash_label.text = "DASH • PRONTO" if world.player.dash_ready else "DASH • ESGOTADO"
	if args.any(func(a): return str(a).begins_with("--capture")) and Engine.get_process_frames() == 90:
		var path := OS.get_environment("ICE_GRIM_SCREENSHOT")
		if path.is_empty():
			path = "user://capture.png"
		get_viewport().get_texture().get_image().save_png(path)
		quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()

func quit(code: int = 0) -> void:
	if OS.has_feature("web"):
		menu()
		return
	if quitting:
		return
	quitting = true
	audio.stop_all()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit(code)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F11:
			_toggle_fullscreen()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_M:
			audio.toggle_mute()
			return
	if state == Screen.SPLASH and event.is_action_pressed("ui_accept"):
		transition_time = 0
		menu()
		return
	if state == Screen.MENU and event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		start_run(false)
		get_viewport().set_input_as_handled()
		return
	if state == Screen.PLAYING:
		if event.is_action_pressed("pause"):
			pause()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("restart"):
			on_death("Tentativa reiniciada.")
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if state == Screen.PAUSED:
			resume()
		elif state == Screen.SETTINGS:
			if settings_from_pause:
				pause()
			else:
				menu()
		elif state == Screen.CREDITS:
			menu()
		get_viewport().set_input_as_handled()

func _toggle_fullscreen() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (!document.fullscreenElement) { document.documentElement.requestFullscreen(); } else { document.exitFullscreen(); }", true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func start_run(is_tutorial: bool) -> void:
	tutorial = is_tutorial
	attempts = 1
	run_time = 0
	load_level(0 if tutorial else 1)
	_banner("A PRIMEIRA COLHERADA" if tutorial else "01  /  TRAVESSIA", "", 0.9, resume)

func load_level(id: int) -> void:
	if world != null:
		remove_child(world)
		world.queue_free()
	level = id
	var path := "res://levels/%02d.tscn" % id
	print("[Ice Grim] Abrindo ", path)
	world = load(path).instantiate()
	world.game = self
	add_child(world)
	art.visible = false
	audio.track(id)
	toast_label.text = ""
	toast_time = 0

func on_exit() -> void:
	if state != Screen.PLAYING:
		return
	audio.sfx("finish")
	if tutorial:
		_banner("TUTORIAL CONCLUÍDO", "Agora você conhece o caminho. A campanha espera por você.", 1.4, menu)
		return
	if level == TOTAL_LEVELS and not world.boss.defeated:
		return
	if level == TOTAL_LEVELS:
		var previous_best: float = preferences.best
		var first_win := previous_best <= 0
		var new_record := first_win or run_time < previous_best
		if new_record:
			preferences.best = run_time
			_save_preferences()
		state = Screen.VICTORY
		transition_time = 0
		after_transition = Callable()
		_clear_overlay()
		var screen = VICTORY_SCREEN.new()
		screen.result = {
			"run_time": run_time, "previous_best": previous_best,
			"time_text": time_text(run_time), "best_text": time_text(preferences.best),
			"first_win": first_win, "new_record": new_record,
			"stages": TOTAL_LEVELS, "attempts": attempts,
			"lives": world.player_lives, "max_lives": world.MAX_PLAYER_LIVES,
		}
		overlay.add_child(screen)
		screen.play_again.connect(func():
			audio.sfx("ui")
			start_run(false))
		screen.main_menu.connect(func():
			audio.sfx("ui")
			menu())
		return

	var next := level + 1
	_banner("FASE %02d CONCLUÍDA" % level, "A seguir: " + NAMES[next], 1.0, func():
		load_level(next)
		resume())

func on_death(_reason: String) -> void:
	if state != Screen.PLAYING:
		return
	state = Screen.DEAD
	preferences.deaths += 1
	_save_preferences()
	audio.sfx("death")
	world.burst(world.player.position - Vector2(0, 20), Color("f492bc"), 30)
	_clear_overlay()
	_dim()
	_text(overlay, "UMA DOCE ARMADILHA", Vector2(110, 82), 16, Color("f3b5c8"))
	_text(overlay, "GAME OVER", Vector2(110, 117), 64)
	if level == TOTAL_LEVELS and world.boss.active:
		_text(overlay, "Chefe: %d / %d golpes  •  Seu melhor: %d / %d" % [world.boss.MAX_HP - world.boss.hp, world.boss.MAX_HP, preferences.boss_best, world.boss.MAX_HP], Vector2(114, 213), 17, Color("a9dced"))
	_text(overlay, "O tutorial recomeça do início." if tutorial else "Você chegou à fase %d. A campanha volta para a fase 1." % level, Vector2(114, 252), 17, Color("bdaac2"))
	var box := _buttons(Vector2(114, 320), 360)
	_button(box, "Repetir tutorial" if tutorial else "Tentar novamente — fase 1", retry)
	_button(box, "Menu principal", menu)
	_focus_first(box)

func retry() -> void:
	attempts += 1
	run_time = 0
	load_level(0 if tutorial else 1)
	resume()

func pause() -> void:
	state = Screen.PAUSED
	_clear_overlay()
	_dim()
	_text(overlay, "RESPIRA. OBSERVA. TENTA.", Vector2(110, 70), 16, Color("99e4d1"))
	_text(overlay, "PAUSA", Vector2(110, 105), 64)
	var box := _buttons(Vector2(114, 220), 340)
	_button(box, "Continuar", resume)
	_button(box, "Áudio e opções", func(): settings(true))
	_button(box, "Reiniciar tutorial" if tutorial else "Reiniciar campanha", func():
		attempts += 1
		run_time = 0
		load_level(0 if tutorial else 1)
		resume())
	_button(box, "Menu principal", menu)
	_focus_first(box)

func resume() -> void:
	state = Screen.PLAYING
	_clear_overlay()

func menu() -> void:
	transition_time = 0
	after_transition = Callable()
	if world != null:
		remove_child(world)
		world.queue_free()
		world = null
	state = Screen.MENU
	art.visible = true
	audio.track(0)
	_clear_overlay()
	_text(overlay, "UM MUNDO DOCE. UM CAMINHO CRUEL.", Vector2(66, 66), 13, Color("a3e9d3"))
	_text(overlay, "ICE", Vector2(60, 90), 88)
	_text(overlay, "GRIM", Vector2(60, 172), 88, Color("f69dbc"))
	_text(overlay, "Cinco fases e um chefe final.\nAprenda o caminho a cada recomeço.", Vector2(66, 297), 18, Color("d3c1cf"))
	_text(overlay, "Maria Vitória Polido de Souza\nJuliano Rubio Sangaleti", Vector2(66, 421), 13, Color("ac96b2"))
	var box := _buttons(Vector2(594, 155), 290)
	_button(box, "Jogar", func(): start_run(false))
	_button(box, "Tutorial", func(): start_run(true))
	_button(box, "Áudio e opções", func(): settings(false))
	_button(box, "Créditos", credits)
	if not OS.has_feature("web"):
		_button(box, "Sair", quit)
	_focus_first(box)
	_text(overlay, "W / S  NAVEGAR     ENTER  CONFIRMAR     F11  TELA CHEIA", Vector2(66, 505), 11, Color("ac96b2"))
	_text(overlay, "v1.3.3 • GDSCRIPT • 6 FASES", Vector2(594, 505), 11, Color("a3e9d3"))
	if preferences.best > 0:
		_text(overlay, "RECORDE   " + time_text(preferences.best), Vector2(594, 119), 13, Color("ffda9e"))

func splash() -> void:
	state = Screen.SPLASH
	_clear_overlay()
	_text(overlay, "UTFPR", Vector2(300, 150), 72)
	_text(overlay, "UNIVERSIDADE TECNOLÓGICA FEDERAL DO PARANÁ\nCAMPUS CAMPO MOURÃO", Vector2(212, 254), 17)
	_text(overlay, "Desenvolvimento de jogos  •  2026", Vector2(300, 330), 16, Color("ae97b5"))
	transition_time = 2
	after_transition = menu

func credits() -> void:
	state = Screen.CREDITS
	art.visible = false
	_clear_overlay()
	_text(overlay, "QUEM FEZ ESTE MUNDO", Vector2(70, 46), 16, Color("9fe2d4"))
	_text(overlay, "CRÉDITOS", Vector2(65, 74), 52)
	_text(overlay, "Maria Vitória Polido de Souza", Vector2(70, 155), 24)
	_text(overlay, "Arte do jogo e desenvolvimento dos sprites.", Vector2(70, 194), 17, Color("cbb8cc"))
	_text(overlay, "Juliano Rubio Sangaleti", Vector2(70, 244), 24)
	_text(overlay, "Composição e desenvolvimento das músicas autorais.", Vector2(70, 284), 17, Color("cbb8cc"))
	_text(overlay, "Todas as músicas incluídas no jogo são autorais.", Vector2(70, 312), 13, Color("a3e9d3"))
	_text(overlay, "UTFPR Campo Mourão  •  Prof. Dr. Marcos Silvano Almeida\nProgramação com assistência de IA.\nFonte DejaVu Sans: licença em assets/fonts/LICENSE.txt.", Vector2(70, 350), 13, Color("ac96b2"))
	var box := _buttons(Vector2(70, 447), 250)
	_button(box, "Voltar ao menu", menu)
	_focus_first(box)

func settings(paused: bool) -> void:
	settings_from_pause = paused
	state = Screen.SETTINGS
	art.visible = false
	_clear_overlay()
	if paused:
		_dim()
	_text(overlay, "DO SEU JEITO", Vector2(110, 63), 16, Color("a3e9d3"))
	_text(overlay, "OPÇÕES", Vector2(105, 94), 56)
	var box := _buttons(Vector2(114, 200), 440)
	_slider(box, "Música", preferences.music, func(value):
		preferences.music = value
		audio.set_volume(value, preferences.sfx)
		_save_preferences())
	_slider(box, "Efeitos", preferences.sfx, func(value):
		preferences.sfx = value
		audio.set_volume(preferences.music, value)
		_save_preferences())
	_button(box, "Alternar tela cheia", _toggle_fullscreen)
	_button(box, "Voltar", func():
		if paused:
			pause()
		else:
			menu())
	_focus_first(box)
	_text(overlay, "A/D: mover   W: pular   S: abaixar   Shift: correr\nEspaço: dash   Esc: pausa   R: reiniciar   M: silenciar\nControle: direcional/analógico, A: pular, baixo: abaixar, B: dash, X: correr. Start: pausa.", Vector2(114, 435), 13, Color("bdaac2"))

func _slider(box: VBoxContainer, title: String, value: float, change: Callable) -> void:
	var label := Label.new()
	label.text = title
	box.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size = Vector2(420, 24)
	slider.focus_mode = Control.FOCUS_ALL
	box.add_child(slider)
	slider.value_changed.connect(change)

func toast(message: String) -> void:
	toast_label.text = message
	toast_time = 3

func _banner(title: String, subtitle: String, seconds: float, callback: Callable) -> void:
	state = Screen.TRANSITION
	_clear_overlay()
	_dim()
	_text(overlay, title, Vector2(100, 178), 40)
	_text(overlay, subtitle, Vector2(105, 244), 18, Color("d2bbc9"))
	transition_time = seconds
	after_transition = callback

func _clear_overlay() -> void:
	for child in overlay.get_children():
		overlay.remove_child(child)
		child.queue_free()

func _dim() -> void:
	var rect := ColorRect.new()
	rect.color = Color(0.06, 0.04, 0.12, 0.9)
	rect.size = Vector2(960, 540)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(rect)

func _text(parent: Control, value: String, pos: Vector2, size: int, color: Color = Color("fff0d6")) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _buttons(pos: Vector2, width: float) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.position = pos
	box.size = Vector2(width, 0)
	box.add_theme_constant_override("separation", 9)
	overlay.add_child(box)
	return box

func _button(box: VBoxContainer, title: String, action: Callable) -> void:
	var button := Button.new()
	button.name = "Botao" + title.validate_node_name().replace(" ", "")
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.text = title
	button.custom_minimum_size = Vector2(box.size.x, 42)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(button)
	button.pressed.connect(func():
		audio.sfx("ui")
		action.call())
	button.mouse_entered.connect(button.grab_focus)

func _focus_first(box: VBoxContainer) -> void:
	var controls: Array[Control] = []
	for child in box.get_children():
		if child is Control and child.focus_mode != Control.FOCUS_NONE:
			controls.append(child)
	for i in controls.size():
		controls[i].focus_neighbor_top = controls[i].get_path_to(controls[(i + controls.size() - 1) % controls.size()])
		controls[i].focus_neighbor_bottom = controls[i].get_path_to(controls[(i + 1) % controls.size()])
	if not controls.is_empty():
		var first := controls[0]
		(func():
			if is_instance_valid(first) and first.is_inside_tree():
				first.grab_focus()).call_deferred()

func _build_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = font
	theme.default_font_size = 16
	theme.set_stylebox("normal", "Button", _box("30263f", "635068"))
	theme.set_stylebox("hover", "Button", _box("594052", "edabc0"))
	theme.set_stylebox("pressed", "Button", _box("855566", "fff0d6"))
	theme.set_stylebox("focus", "Button", _box("00000000", "b0efda", 2))
	theme.set_color("font_color", "Button", Color("fff0d6"))
	theme.set_color("font_focus_color", "Button", Color("b9f3df"))
	return theme

func _box(background: String, border: String, width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(background)
	box.border_color = Color(border)
	box.set_border_width_all(width)
	box.set_corner_radius_all(6)
	box.content_margin_left = 18
	box.content_margin_right = 18
	return box

static func time_text(time: float) -> String:
	return "%02d:%02d.%d" % [int(time) / 60, int(time) % 60, int(time * 10) % 10]

func _load_preferences() -> void:
	if test_mode:
		return
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return
	preferences.music = clampf(float(config.get_value("audio", "music", 0.65)), 0, 1)
	preferences.sfx = clampf(float(config.get_value("audio", "sfx", 0.8)), 0, 1)
	preferences.deaths = int(config.get_value("stats", "deaths", 0))
	var saved_best := float(config.get_value("stats", "best", 0.0))
	var version := int(config.get_value("stats", "campaign_size", 5))
	preferences.best = saved_best if version == TOTAL_LEVELS else 0.0
	preferences.legacy_best_five = float(config.get_value("stats", "legacy_best_five", saved_best if version == 5 else 0.0))
	preferences.boss_best = int(config.get_value("stats", "boss_best", 0))

func _save_preferences() -> void:
	if test_mode:
		return
	var config := ConfigFile.new()
	config.set_value("audio", "music", preferences.music)
	config.set_value("audio", "sfx", preferences.sfx)
	config.set_value("stats", "deaths", preferences.deaths)
	config.set_value("stats", "best", preferences.best)
	config.set_value("stats", "campaign_size", TOTAL_LEVELS)
	config.set_value("stats", "legacy_best_five", preferences.legacy_best_five)
	config.set_value("stats", "boss_best", preferences.boss_best)
	config.save("user://settings.cfg")

func register_boss_progress(hits: int) -> void:
	if hits > preferences.boss_best:
		preferences.boss_best = hits
		_save_preferences()

func preview_victory() -> void:
	# Development-only visual preview, never a saved campaign completion.
	test_mode = true
	tutorial = false
	transition_time = 0
	after_transition = Callable()
	load_level(TOTAL_LEVELS)
	resume()
	run_time = 137.4
	attempts = 3
	preferences.best = 155.2
	world.player_lives = 2
	world.boss.active = true
	world.boss.hp = 0
	world.boss.defeated = true
	world.player.has_key = true
	on_exit()
