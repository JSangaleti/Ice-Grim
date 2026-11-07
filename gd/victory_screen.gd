extends Control
signal play_again
signal main_menu
const PALETTE := [Color("a7edda"), Color("ffb2cb"), Color("ffda91"), Color("a9dfff")]
var result: Dictionary = {}
var time := 0.0
var hero: Texture2D
var floor_texture: Texture2D
var replay_button: Button
var menu_button: Button
var badge: Label

func _ready() -> void:
	name = "VictoryScreen"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hero = load("res://assets/sprites/personagem-principal.png")
	floor_texture = load("res://assets/sprites/plataformas.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_label("ICE GRIM  /  FINAL", Vector2(62, 44), 13, Color("a7edda"))
	_label("A NEVASCA", Vector2(62, 82), 31)
	_label("ACABOU.", Vector2(62, 117), 44, Color("ffb2cb"))
	_label("REI DA NEVASCA DERROTADO", Vector2(430, 47), 12, Color("a7edda"))
	_label("DOCE VITÓRIA.", Vector2(425, 70), 45)
	_label("Seis fases. Nove golpes. Você conseguiu.", Vector2(430, 132), 16, Color("d4c8dc"))
	var status: String = "PRIMEIRA VITÓRIA" if result.first_win else ("NOVO RECORDE" if result.new_record else "CAMPANHA CONCLUÍDA")
	badge = _label(status, Vector2(447, 182), 13, Color("ffda91") if result.first_win or result.new_record else Color("a7edda"))
	_stat("TEMPO DESTA CORRIDA", result.time_text, Vector2(430, 231), 215)
	_stat("SEU MELHOR TEMPO", result.best_text, Vector2(659, 231), 215)
	_stat("FASES CONCLUÍDAS", "%d / %d" % [result.stages, result.stages], Vector2(430, 310), 215)
	_stat("VIDAS NO BOSS", "%d / %d" % [result.lives, result.max_lives], Vector2(659, 310), 215)
	_label("TENTATIVA %02d  •  CAMPANHA COMPLETA" % result.attempts, Vector2(430, 387), 11, Color("b7a7c6"))
	var message: String = "Sem perder vidas no boss. Que tal bater seu tempo?" if result.lives == result.max_lives else "Você venceu. Na próxima, tente manter as três vidas."
	var caption := _label(message, Vector2(62, 439), 13, Color("d4c8dc"), 305)
	caption.name = "ChallengeCaption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var record_message := "Sua primeira marca. O próximo desafio é seu." if result.first_win else ("%.1f s mais rápido que o recorde anterior." % (result.previous_best - result.run_time) if result.new_record else "Seu recorde continua de pé. Tente mais uma vez.")
	var record := _label(record_message, Vector2(430, 507), 11, Color("b7a7c6"))
	record.size.x = 444
	replay_button = _button("Jogar novamente", Vector2(430, 415), true)
	menu_button = _button("Menu principal", Vector2(430, 464), false)
	replay_button.pressed.connect(func(): play_again.emit())
	menu_button.pressed.connect(func(): main_menu.emit())
	for button in [replay_button, menu_button]:
		var other: Button = menu_button if button == replay_button else replay_button
		button.focus_neighbor_top = button.get_path_to(other)
		button.focus_neighbor_bottom = button.get_path_to(other)
		button.focus_neighbor_left = button.get_path_to(other)
		button.focus_neighbor_right = button.get_path_to(other)
	var first := replay_button
	(func():
		if is_instance_valid(first) and first.is_inside_tree():
			first.grab_focus()).call_deferred()

func _label(text: String, at: Vector2, font_size: int, color: Color = Color("fff2d9"), wrap_width: float = 0) -> Label:
	var label := Label.new()
	if wrap_width > 0:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size = Vector2(wrap_width, 48)
	label.text = text
	label.position = at
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label

func _stat(title: String, value: String, at: Vector2, width: float) -> void:
	var panel := Panel.new()
	panel.position = at
	panel.size = Vector2(width, 66)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _box(Color("29243d"), Color("51435f")))
	add_child(panel)
	_label(title, at + Vector2(15, 9), 10, Color("bcb0ce"))
	_label(value, at + Vector2(15, 26), 26)

func _button(text: String, at: Vector2, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = Vector2(444, 40)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("1c2832") if primary else Color("eee5f4"))
	button.add_theme_color_override("font_focus_color", Color("1c2832") if primary else Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("1c2832") if primary else Color("ffffff"))
	button.add_theme_color_override("font_hover_color", Color("1c2832") if primary else Color("ffffff"))
	button.add_theme_stylebox_override("normal", _box(Color("a7edda") if primary else Color("302740"), Color("a7edda") if primary else Color("67516f")))
	button.add_theme_stylebox_override("hover", _box(Color("c7ffef") if primary else Color("51405b"), Color("ffda91")))
	button.add_theme_stylebox_override("pressed", _box(Color("8ccfbd") if primary else Color("705168"), Color("fff2d9")))
	button.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), Color("ffda91"), 2))
	add_child(button)
	button.mouse_entered.connect(button.grab_focus)
	return button

func _box(background: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(8)
	return box

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("181526"))
	draw_rect(Rect2(398, 25, 512, 505), Color("201b30"))
	draw_line(Vector2(398, 25), Vector2(398, 518), Color("56435f"), 1)
	var center := Vector2(215, 285)
	for i in 12:
		var angle := i * TAU / 12 + time * 0.035
		var a := center + Vector2.from_angle(angle) * 255
		var b := center + Vector2.from_angle(angle + 0.13) * 255
		draw_colored_polygon(PackedVector2Array([center, a, b]), Color(0.34, 0.27, 0.43, 0.12))
	draw_circle(center, 120, Color("29203b"))
	draw_circle(center, 93, Color("362843"))
	draw_arc(center, 129, -PI * 0.9 + time * 0.08, PI * 0.5 + time * 0.08, 64, Color("5a456a"), 2)
	# A bounded, deterministic celebration: no accumulating particle nodes.
	for i in 65:
		var x := fmod(i * 137.0 + sin(time * 1.4 + i) * 13, 960)
		var y := fmod(i * 79.0 + time * (24 + i % 6 * 8), 555) - 10
		if x > 410 and y > 165:
			continue
		draw_set_transform(Vector2(x, y), sin(i + time) * 0.65)
		draw_rect(Rect2(-2, -4, 4, 8), PALETTE[i % PALETTE.size()])
	draw_set_transform(Vector2.ZERO)
	# Podium and hero reuse Maria Vitória's original sprite sheets.
	draw_rect(Rect2(97, 361, 238, 28), Color("624059"))
	draw_rect(Rect2(128, 337, 176, 24), Color("b9798c"))
	draw_texture_rect_region(floor_texture, Rect2(112, 330, 208, 32), Rect2(7, 0, 80, 32))
	var bounce := sin(time * 3) * 4
	var frame := 2 + int(time * 5) % 2
	draw_texture_rect_region(hero, Rect2(161, 222 + bounce, 112, 112), Rect2((frame % 2) * 16, floori(frame / 2.0) * 16, 16, 16))
	var crown := Vector2(217, 214 + bounce)
	draw_colored_polygon(PackedVector2Array([crown + Vector2(-24, 0), crown + Vector2(-26, -22), crown + Vector2(-12, -12), crown + Vector2(0, -30), crown + Vector2(12, -12), crown + Vector2(26, -22), crown + Vector2(24, 0)]), Color("ffda91"))
	draw_circle(crown + Vector2(0, -13), 3, Color("e68bb2"))
	for i in int(result.get("stages", 6)):
		var at := Vector2(85 + i * 51, 407)
		draw_circle(at, 16, Color("3a304b"))
		draw_arc(at, 16, -PI / 2, TAU - PI / 2, 24, Color("a7edda"), 1.5)
		draw_string(get_theme_default_font(), at + Vector2(-7, 5), "%02d" % (i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("a7edda"))
	var badge_color := Color("4d3d34") if result.get("first_win", false) or result.get("new_record", false) else Color("253c3b")
	draw_rect(Rect2(430, 174, 444, 35), badge_color)
	draw_circle(Vector2(859, 192), 3 + sin(time * 3) * 0.8, Color("ffda91"))
