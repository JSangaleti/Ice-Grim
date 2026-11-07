@tool
extends Area2D
@export var is_exit := false
@export var escape_once := false
@export var escape_to := Vector2.ZERO
var escaped := false
var taken := false
var time := 0.0
var texture: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture = load("res://assets/generated/%s.svg" % ("door" if is_exit else "key"))
	if Engine.is_editor_hint():
		return
	collision_layer = 8
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 64) if is_exit else Vector2(30, 30)
	collision.shape = rect
	collision.position = Vector2(0, -32) if is_exit else Vector2.ZERO
	add_child(collision)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is IcePlayer:
		interact(body)

func interact(player: IcePlayer) -> void:
	var game = player.game
	if taken or game == null or game.state != game.Screen.PLAYING:
		return
	if not is_exit and escape_once and not escaped:
		escaped = true
		game.world.burst(position, Color("ffda8b"), 10)
		set_deferred("position", escape_to)
		game.audio.sfx("dash")
		return
	if is_exit:
		if player.has_key:
			taken = true
			game.on_exit()
		else:
			game.audio.sfx("locked")
	else:
		taken = true
		visible = false
		player.has_key = true
		game.audio.sfx("key")
		game.world.burst(position, Color("ffda8b"), 18)

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	if texture == null:
		return
	if is_exit:
		draw_texture_rect(texture, Rect2(-24, -66, 48, 66), false)
		if not Engine.is_editor_hint():
			var game = get_tree().root.get_node_or_null("IceGrim")
			if game != null and game.world != null and game.world.player.has_key:
				draw_circle(Vector2(0, -32), 6, Color("a9ffd3"))
				draw_string(ThemeDB.fallback_font, Vector2(-28, -76), "SAÍDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("a9ffd3"))
	elif not taken:
		draw_texture_rect(texture, Rect2(-16, -16 + sin(time * 3) * 4, 32, 32), false)
