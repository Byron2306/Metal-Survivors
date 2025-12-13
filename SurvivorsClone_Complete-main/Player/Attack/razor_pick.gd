extends Area2D

# --- Configuration ---
@export var level: int = 1
@export var damage: int = 2
@export var speed: float = 200.0
@export var pierce_count: int = 0
@export var textures: Array[Texture2D] = []
@export var camera_path: NodePath

# --- Runtime state ---
var direction: Vector2 = Vector2.ZERO
var hits: int = 0
var cam: Camera2D = null
var viewport_size: Vector2 = Vector2.ZERO

# Passive-scaled (cached)
var final_damage: int
var final_speed: float
var final_scale: Vector2
var final_radius: float

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var initial_scale: Vector2 = sprite.scale
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	set_physics_process(true)

	if player == null:
		queue_free()
		return

	# Resolve camera
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()

	viewport_size = get_viewport_rect().size

	# ─── APPLY PASSIVES (ONCE) ────────────────────

	# Power Chord → damage
	final_damage = int(round(damage * player.damage_multiplier))

	# Shred Drive → speed
	final_speed = speed * player.projectile_speed_multiplier

	# Tome → size (sprite + collision)
	final_scale = initial_scale * (1.0 + player.spell_size)
	sprite.scale = final_scale

	if collision_shape.shape is CircleShape2D:
		final_radius = collision_shape.shape.radius * (1.0 + player.spell_size)
		collision_shape.shape.radius = final_radius

	# Connect collision once
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

func initialize(dir: Vector2, pick_index: int = 0) -> void:
	# Reset pierce counter & movement
	direction = dir.normalized()
	hits = 0

	# Rotate so point faces movement (default sprite points down)
	sprite.rotation = direction.angle() - PI / 2

	# Assign texture safely
	if textures.size() > 0:
		sprite.texture = textures[pick_index % textures.size()]

	# Restore passive-scaled size (important!)
	sprite.scale = final_scale

	# Reset offsets
	sprite.position = Vector2.ZERO
	collision_shape.position = Vector2.ZERO
	sprite.z_index = 1

func _physics_process(delta: float) -> void:
	position += direction * final_speed * delta

	# Offscreen culling
	if cam:
		var half = viewport_size * 0.5 * cam.zoom
		var center = cam.global_position
		var bounds = Rect2(center - half, half * 2)
		if not bounds.has_point(global_position):
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(final_damage, direction, 0)
		hits += 1
		if hits > pierce_count:
			queue_free()
	elif body.is_in_group("wall"):
		queue_free()

func get_last_movement() -> Vector2:
	return direction
