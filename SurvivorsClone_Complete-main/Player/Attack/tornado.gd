extends Area2D

# ─── Base designer values ─────────────────────────────
@export var base_speed: float = 100.0
@export var base_damage: int = 2
@export var base_knockback: int = 100
@export var max_time_alive: float = 5.0
@export var homing_radius: float = 300.0
@export var camera_path: NodePath

# ─── Runtime cached stats ─────────────────────────────
var level: int = 1
var speed: float
var damage: int
var knockback_amount: int
var size_multiplier: float = 1.0

# Movement
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO
var last_movement: Vector2 = Vector2.RIGHT
var age: float = 0.0

var cam: Camera2D = null

@onready var player          = get_tree().get_first_node_in_group("player")
@onready var sprite          = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var snd_attack      = $snd_attack

# Capture base scales
@onready var base_sprite_scale: Vector2 = sprite.scale

func _ready() -> void:
	add_to_group("enemy_tornado")

	if player == null:
		queue_free()
		return

	# Camera
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()

	# ─── LEVEL ─────────────────────────────
	level = player.tornado_level

	# ─── DAMAGE (Power Chord) ──────────────
	match level:
		1: base_damage = 2
		2: base_damage = 3
		3: base_damage = 4
		4: base_damage = 5

	damage = int(round(base_damage * player.damage_multiplier))

	# ─── KNOCKBACK ─────────────────────────
	knockback_amount = base_knockback
	if level == 4:
		knockback_amount = int(knockback_amount * 1.25)

	# ─── SIZE (Tome / Spell Size) ──────────
	size_multiplier = 1.0 + player.spell_size
	sprite.scale = base_sprite_scale * size_multiplier

	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size *= size_multiplier

	# ─── SPEED ─────────────────────────────
	speed = max(base_speed, player.movement_speed * 1.5)

	# ─── COLLISION ─────────────────────────
	collision_layer = 0
	collision_mask = 2
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	# ─── MOVEMENT ──────────────────────────
	_compute_angles()
	_start_tweens()

	if snd_attack and not snd_attack.playing:
		snd_attack.play()

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
	angle = angle_less if randf() < 0.5 else angle_more

func _start_tweens() -> void:
	var grow = create_tween().set_parallel(true)
	grow.tween_property(self, "scale", Vector2.ONE, 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

	var final_speed = speed
	speed /= 5.0
	grow.tween_property(self, "speed", final_speed, 6.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	grow.play()

	var zig = create_tween()
	for i in range(6):
		zig.tween_property(self, "angle", angle_more if i % 2 == 0 else angle_less, 2.0)
	zig.play()

func _physics_process(delta: float) -> void:
	age += delta
	if age > max_time_alive:
		queue_free()
		return

	# Off-screen cull
	if cam:
		var half = get_viewport_rect().size * 0.5 * cam.zoom
		var bounds = Rect2(cam.global_position - half, half * 2).grow(100)
		if not bounds.has_point(global_position):
			queue_free()
			return

	# Homing at level 3+
	if level >= 3:
		var nearest: Node = null
		var best_d: float = homing_radius
		for e in get_tree().get_nodes_in_group("enemy"):
			var d = e.global_position.distance_to(global_position)
			if d < best_d:
				best_d = d
				nearest = e
		if nearest:
			angle = angle.lerp((nearest.global_position - global_position).normalized(), 0.1)

	position += angle * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, angle, knockback_amount)
