@tool
extends Node2D
const PLAYER = preload("res://gd/player.gd")
const SKIES := [Color("192c3e"), Color("352440"), Color("1c3442"), Color("3e263b"), Color("242342"), Color("28213c")]
@export var width := 960.0
@export var level_id := 0
@export var level_name := "Travessia"
@export var spawn := Vector2(48, 484)
var player: IcePlayer
var game
var time := 0.0
var particles: Array[Dictionary] = []

func _ready() -> void:
	z_index = -1
	if Engine.is_editor_hint():
		queue_redraw()
		return
	player = PLAYER.new()
	player.name = "Player"
	player.position = spawn
	player.game = game
	add_child(player)

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and (game == null or game.state != game.Screen.PLAYING):
		return
	time += delta
	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p.life -= delta
		if p.life <= 0:
			particles.remove_at(i)
			continue
		p.vel += Vector2(0, 480 * delta)
		p.pos += p.vel * delta
	queue_redraw()

func burst(pos: Vector2, color: Color, count: int) -> void:
	for i in count:
		var angle := i * 2.39996
		particles.append({"pos": pos, "vel": Vector2(cos(angle) * 90, sin(angle) * 80 - 60), "life": 0.4 + (i % 4) * 0.1, "color": color})

func _draw() -> void:
	var sky: Color = SKIES[clampi(level_id, 0, 5)]
	draw_rect(Rect2(0, 0, width, 540), sky)
	for i in int(32 * width / 960):
		draw_circle(Vector2((i * 127 + 31) % int(width), 104 + (i * 71) % 290), 2 if i % 3 == 0 else 1, Color(Color("fff0d6"), 0.19))
	for i in int(ceil(width / 145)) + 1:
		var x := i * 145 - 55
		draw_rect(Rect2(x - 44, 395, 88, 145), Color("46394e"))
		draw_circle(Vector2(x, 395), 44, Color("594556"))
		draw_circle(Vector2(x + 16, 380), 28, Color("654d5c"))
		for j in 5:
			draw_line(Vector2(x - 44, 435 + j * 22), Vector2(x + 44, 390 + j * 22), Color("61505b"), 2)
	var moon := Vector2(882, 235) if level_id == 0 else Vector2(840, 150)
	draw_circle(moon, 43, Color("ffd6ab"))
	draw_circle(moon + Vector2(15, -13), 39, sky)
	for p in particles:
		draw_rect(Rect2(p.pos, Vector2(4, 4)), Color(p.color, minf(1, p.life * 3)))
	if Engine.is_editor_hint():
		draw_rect(Rect2(spawn - Vector2(11, 38), Vector2(22, 38)), Color("99e4d1"), false, 2)
