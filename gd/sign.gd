@tool
extends Node2D
@export var title := ""
@export var body := ""
var font: Font

func _ready() -> void:
	font = load("res://assets/fonts/Interface.ttf")
	queue_redraw()

func _draw() -> void:
	if font == null:
		return
	draw_string(font, Vector2.ZERO, title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ffe2b5"))
	draw_string(font, Vector2(0, 23), body, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("bfabbf"))
