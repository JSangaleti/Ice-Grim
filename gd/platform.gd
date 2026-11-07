@tool
extends StaticBody2D

@export var size := Vector2(160, 56)
@export_range(0, 3, 1) var flavor := 0
@export var crumble := false
@export var camouflage := false
@export var collapse_delay := 0.48
var remaining := -1.0
var collapsed := false
var atlas: Texture2D
var collision: CollisionShape2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	atlas = load("res://assets/sprites/plataformas.png")
	if Engine.is_editor_hint():
		queue_redraw()
		return
	collision_layer = 1
	collision_mask = 0
	collision = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	collision.shape = rect
	collision.position = size / 2
	add_child(collision)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	var game = get_tree().root.get_node_or_null("IceGrim")
	if game == null or game.state != game.Screen.PLAYING:
		return
	var player = game.world.player if game.world != null else null
	if crumble and not collapsed and remaining < 0 and player != null and player.is_on_floor() and player.global_position.x > global_position.x - 10 and player.global_position.x < global_position.x + size.x + 10 and absf(player.global_position.y - global_position.y) < 5:
		remaining = collapse_delay
		if not camouflage:
			game.audio.sfx("crumble")
	if remaining >= 0 and not collapsed:
		remaining -= delta
		if remaining <= 0:
			collapsed = true
			collision.set_deferred("disabled", true)
			game.world.burst(global_position + size / 2, Color("ffd6a5"), 18)
	if collapsed:
		position.y += 240 * delta
		modulate.a = maxf(0, modulate.a - delta * 2)
	queue_redraw()

func _draw() -> void:
	if atlas == null:
		return
	var shake: float = sin(remaining * 90) * 2 if remaining > 0 else 0.0
	draw_rect(Rect2(shake, 14, size.x, maxf(4, size.y - 14)), Color("d99760"))
	draw_rect(Rect2(shake + 3, 22, maxf(1, size.x - 6), maxf(3, size.y - 25)), Color("f2bf7c"))
	for x in range(0, int(size.x), 80):
		var width := minf(80, size.x - x)
		draw_texture_rect_region(atlas, Rect2(x + shake, 0, width, 32), Rect2(7, flavor * 32, width, 32))
	if crumble and not camouflage:
		for x in range(12, int(size.x), 28):
			draw_line(Vector2(x, 5), Vector2(x + 6, 13), Color("613b50"), 2)
			draw_line(Vector2(x + 6, 13), Vector2(x + 2, 20), Color("613b50"), 2)
