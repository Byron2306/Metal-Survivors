extends Area2D

# ——— Exports ———
@export var level: int = 1
@export var hp: int = 9999
@export var speed: float = 100.0
@export var damage: int = 2
@export var attack_size: float = 1.0
@export var knockback_amount: int = 100

@export var max_time_alive: float = 5.0
@export var homing_radius: float = 300.0
@export var camera_path: NodePath

# ——— Runtime state ———
var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO
var _age: float = 0.0
var cam: Camera2D = null

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	# Tag for global culling/counting
	add_to_group("enemy_tornado")

	# Resolve camera
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()

	# 1) Pull in real level & adjust speed
	if player:
		level = player.tornado_level
		var p_speed = player.movement_speed
		speed = max(speed, p_speed * 1.5)

	# 2) Damage scales 2–5
	match level:
		1:
			damage = 2
		2:
			damage = 3
		3:
			damage = 4
		4:
			damage = 5
		_:
			damage = 2

	# 3) Tier 4 gets +25% knockback
	if level == 4:
		knockback_amount = int(knockback_amount * 1.25)

	# 4) Collision setup
	collision_layer = 0
	collision_mask = 2
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	# 5) Precompute zig-zag angles
	_compute_angles()

	# 6) Play size & speed tweens
	_start_tweens()

func _compute_angles() -> void:
	var move_to_less: Vector2
	var move_to_more: Vector2
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.LEFT, Vector2.RIGHT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		_:
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500

	angle_less = (move_to_less - global_position).normalized()
	angle_more = (move_to_more - global_position).normalized()
	# choose initial angle
	if randf() < 0.5:
		angle = angle_less
	else:
		angle = angle_more

func _start_tweens() -> void:
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2.ONE * attack_size, 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed /= 5.0
	initial_tween.tween_property(self, "speed", final_speed, 6.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initial_tween.play()

	var zig_tween = create_tween()
	var flips = 6
	for i in range(flips):
		var target: Vector2
		if i % 2 == 0:
			target = angle_more
		else:
			target = angle_less
		zig_tween.tween_property(self, "angle", target, 2.0)
	zig_tween.play()

func _physics_process(delta: float) -> void:
	# 1) Age out
	_age += delta
	if _age > max_time_alive:
		queue_free()
		return

	# 2) Off-screen cull with margin
	if cam:
		var half = get_viewport_rect().size * 0.5 * cam.zoom
		var bounds = Rect2(cam.global_position - half, half * 2).grow(100)
		if not bounds.has_point(global_position):
			queue_free()
			return

	# 3) Conditional homing
	if level >= 3:
		var nearest: Node = null
		var best_d: float = homing_radius
		for e in get_tree().get_nodes_in_group("enemy"):
			var d: float = e.global_position.distance_to(global_position)
			if d < best_d:
				best_d = d
				nearest = e
		if nearest:
			var target_dir = (nearest.global_position - global_position).normalized()
			angle = angle.lerp(target_dir, 0.1)

	# 4) Movement
	position += angle * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, angle, knockback_amount)

func _on_timer_timeout() -> void:
	queue_free()
