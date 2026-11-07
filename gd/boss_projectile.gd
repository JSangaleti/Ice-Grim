extends Area2D

enum Kind { SCOOP, WAVE, BEAM, RAIN }
var kind: Kind = Kind.SCOOP
var velocity := Vector2.ZERO
var fall_acceleration := 0.0
var lifetime := 7.0
var world
var texture: Texture2D

func _ready() -> void:
	add_to_group("boss_attacks")
	collision_layer = 4
	collision_mask = 3 if kind in [Kind.SCOOP, Kind.RAIN] else 2
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26, 24) if kind in [Kind.SCOOP, Kind.RAIN] else (Vector2(34, 26) if kind == Kind.WAVE else Vector2(40, 10))
	collision.shape = rect
	add_child(collision)
	texture = load("res://assets/generated/scoop.svg")
	body_entered.connect(_on_body)

func _on_body(body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	if body is IcePlayer:
		body.die("Ataque do chefe.")
	queue_free()

func _physics_process(delta: float) -> void:
	if world == null or world.game.state != world.game.Screen.PLAYING:
		return
	velocity.y += fall_acceleration * delta
	position += velocity * delta
	lifetime -= delta
	if lifetime <= 0 or position.y > 590 or position.x < world.ARENA_START - 80 or position.x > world.width + 80:
		queue_free()
	queue_redraw()

func _draw() -> void:
	match kind:
		Kind.SCOOP, Kind.RAIN:
			draw_texture_rect(texture, Rect2(-16, -16, 32, 32), false, Color("bfefff") if kind == Kind.RAIN else Color.WHITE)
		Kind.WAVE:
			draw_colored_polygon(PackedVector2Array([Vector2(-20, 12), Vector2(-10, -10), Vector2(0, 0), Vector2(10, -13), Vector2(20, 12)]), Color("a9e9ff"))
			draw_line(Vector2(-16, 10), Vector2(16, 10), Color("eafcff"), 3)
		Kind.BEAM:
			draw_colored_polygon(PackedVector2Array([Vector2(-22, 0), Vector2(14, -7), Vector2(22, 0), Vector2(14, 7)]), Color("fff0c4"))
			draw_line(Vector2(-8, 0), Vector2(12, 0), Color("92e8ff"), 3)
