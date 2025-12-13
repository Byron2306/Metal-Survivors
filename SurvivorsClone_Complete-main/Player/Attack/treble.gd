extends Area2D

# ─── Base designer values ─────────────────────────────
@export var level: int = 1
@export var base_damage: int = 2
@export var speed: float = 150.0
@export var pierce_count: int = 0
@export var camera_path: NodePath

# ─── Runtime state ───────────────────────────────────
var damage: int
var hits: int = 0
var direction: Vector2 = Vector2(1, -1).normalized()

var cam: Camera2D = null
var viewport_size: Vector2 = Vector2.ZERO

@onready var player          = get_tree().get_first_node_in_group("player")
@onready var sprite          = $Sprite2D
@onready var collision_shape = $CollisionShape2D

# Capture base scale for Tome scaling
@onready var base_sprite_scale: Vector2 = sprite.scale

func _ready() -> void:
	set_physics_process(true)

	# Resolve camera
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()

	viewport_size = get_viewport_rect().size

	# ─── DAMAGE (Power Chord) ─────────────────────────
	if player:
		damage = int(round(base_damage * player.damage_multiplier))
	else:
		damage = base_damage

	# ─── SIZE (Tome / Spell Size) ─────────────────────
	if player:
		var size_mul := 1.0 + player.spell_size
		sprite.scale = base_sprite_scale * size_mul
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius *= size_mul

	# ─── ROTATION ─────────────────────────────────────
	rotation = direction.angle()

	# ─── COLLISION ────────────────────────────────────
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	# Off-screen culling
	if cam:
		var half = viewport_size * 0.5 * cam.zoom
		var center = cam.global_position
		var bounds = Rect2(center - half, half * 2)
		if not bounds.has_point(global_position):
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, direction, 0)
		hits += 1
		if hits > pierce_count:
			queue_free()
	elif body.is_in_group("wall"):
		queue_free()
