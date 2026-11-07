@tool
extends Area2D
const PROJECTILE = preload("res://gd/projectile.gd")
enum Type { SPIKES, JELLY, FALLING_SCOOP, MOVING_SPIKE, CONE_LAUNCHER, POP_SPIKES }
@export var kind: Type = Type.SPIKES
@export var size := Vector2(48, 20)
@export var travel := 100.0
@export var speed := 65.0
@export var trigger_distance := 72.0
@export var variant := 0
@export var release_delay := 0.55
@export var concealed_until_triggered := false
@export var activation_distance := 80.0
@export var rise_duration := 0.14
var triggered := false
var falling := false
var origin := Vector2.ZERO
var time := 0.0
var drop_timer := 0.0
var fall_velocity := 0.0
var emergence := 0.0
var lethal := false
var texture: Texture2D
var hit_shape: CollisionShape2D
var game

func _ready() -> void:
	origin = position
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if kind == Type.JELLY:
		texture = load("res://assets/sprites/inimigo-%s.png" % ["rosa", "roxo", "verde"][variant % 3])
	else:
		texture = load("res://assets/generated/%s.svg" % ("scoop" if kind == Type.FALLING_SCOOP else "spike"))
	if Engine.is_editor_hint():
		queue_redraw()
		return
	game = get_tree().root.get_node_or_null("IceGrim")
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	var hit_size := size - Vector2(6, 4)
	if kind == Type.JELLY:
		hit_size = Vector2(23, 19)
	elif kind == Type.FALLING_SCOOP:
		hit_size = Vector2(33, 33)
	hit_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = hit_size
	hit_shape.shape = rect
	hit_shape.position = size / 2 if kind in [Type.SPIKES, Type.POP_SPIKES] else Vector2(0, -hit_size.y / 2)
	hit_shape.disabled = kind == Type.POP_SPIKES
	add_child(hit_shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is IcePlayer or kind == Type.CONE_LAUNCHER:
		return
	if kind == Type.FALLING_SCOOP and not falling:
		return
	if kind == Type.POP_SPIKES and not lethal:
		return
	body.die("Contato com armadilha.")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if game == null or game.state != game.Screen.PLAYING:
		return
	if game.world.width > 960 and game.world.player.position.x < origin.x - 240:
		return
	time += delta
	if kind == Type.JELLY:
		position = origin + Vector2((1 - cos(time * speed / maxf(travel, 1))) * travel / 2, 0)
	elif kind == Type.MOVING_SPIKE:
		position = origin + Vector2(0, sin(time * speed / maxf(travel, 1)) * travel)
	elif kind == Type.FALLING_SCOOP:
		var player = game.world.player if game.world != null else null
		if not triggered and player != null and absf(player.position.x - origin.x) < trigger_distance:
			triggered = true
			drop_timer = release_delay
		if triggered and not falling:
			drop_timer -= delta
			if drop_timer <= 0:
				falling = true
		if falling:
			fall_velocity += 950 * delta
			position.y += fall_velocity * delta
			if position.y > 650:
				queue_free()
	elif kind == Type.POP_SPIKES:
		var player = game.world.player if game.world != null else null
		if not triggered and player != null and player.position.x >= origin.x - activation_distance and player.position.x <= origin.x + size.x + 32:
			triggered = true
		if triggered:
			emergence = minf(1, emergence + delta / maxf(rise_duration, 0.01))
			if emergence >= 0.6 and not lethal:
				lethal = true
				hit_shape.set_deferred("disabled", false)
	elif kind == Type.CONE_LAUNCHER and time >= 2.2:
		time = 0
		var shot = PROJECTILE.new()
		shot.position = position + Vector2(-20, -15)
		get_parent().add_child(shot)
		game.audio.sfx("shot")
	queue_redraw()

func _draw() -> void:
	if texture == null:
		return
	match kind:
		Type.JELLY:
			draw_texture_rect_region(texture, Rect2(-16, -26, 32, 32), Rect2(0, 8 * (int(time * 7) % 4), 8, 8))
		Type.SPIKES:
			for x in range(0, int(size.x), 20):
				draw_texture_rect(texture, Rect2(x, 0, 20, size.y), false)
		Type.POP_SPIKES:
			var progress := 1.0 if Engine.is_editor_hint() else emergence
			if progress > 0:
				for x in range(0, int(size.x), 20):
					draw_texture_rect(texture, Rect2(x, size.y * (1 - progress), 20, size.y * progress), false)
		Type.FALLING_SCOOP:
			if not concealed_until_triggered or falling or Engine.is_editor_hint():
				draw_texture_rect(texture, Rect2(-22, -44, 44, 44), false)
		Type.CONE_LAUNCHER:
			draw_rect(Rect2(-15, -32, 30, 32), Color("704864"))
			draw_circle(Vector2(-16, -15), 10, Color("ffa9bd"))
		_:
			draw_texture_rect(texture, Rect2(-13, -26, 26, 26), false)
