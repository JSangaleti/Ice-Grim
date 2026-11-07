extends Node2D
var time := 0.0
var hero: Texture2D
var floor_texture: Texture2D

func _ready() -> void:
	hero = load("res://assets/sprites/personagem-principal.png")
	floor_texture = load("res://assets/sprites/plataformas.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("191526"))
	draw_circle(Vector2(475, 225), 170, Color("251c33"))
	draw_circle(Vector2(475, 225), 130, Color("302139"))
	for i in 60:
		draw_rect(Rect2((i * 137) % 960, (i * 83) % 540, 2, 2), Color("61445e"))
	draw_texture_rect_region(floor_texture, Rect2(409, 379, 170, 64), Rect2(6, 0, 85, 32))
	draw_texture_rect_region(hero, Rect2(430, 240 + sin(time * 2) * 5, 112, 112), Rect2(0, 0, 16, 16))
	draw_line(Vector2(566, 72), Vector2(566, 471), Color("674659"), 1)
