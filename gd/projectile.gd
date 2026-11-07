extends Area2D
var direction := -1.0
var life := 4.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 3
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 8)
	collision.shape = rect
	add_child(collision)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is IcePlayer:
		body.die("Abaixe para desviar do disparo alto.")
	queue_free()

func _physics_process(delta: float) -> void:
	var game = get_tree().root.get_node_or_null("IceGrim")
	if game == null or game.state != game.Screen.PLAYING:
		return
	position.x += direction * 250 * delta
	life -= delta
	if life < 0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-10, 0), Vector2(8, -5), Vector2(8, 5)]), Color("f8bf7b"))
