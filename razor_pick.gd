extends Area2D

# --- Configuration ---
@export var level: int = 1
@export var damage: int = 2
@export var speed: float = 200.0
@export var pierce_count: int = 0
@export var textures: Array[Texture2D] = []   # List of pick textures to cycle through
@export var camera_path: NodePath              # Assigned at runtime to point at your follow camera

# --- Runtime state ---
var direction: Vector2 = Vector2.ZERO
var hits: int = 0
var cam: Camera2D = null
var viewport_size: Vector2 = Vector2.ZERO
var bounce_count: int = 0
var max_bounces: int = 0

# Capture the designer-set base scale so we can apply it consistently
@onready var sprite: Sprite2D = $Sprite2D
@onready var initial_scale: Vector2 = sprite.scale
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Enable movement
	set_physics_process(true)

	# Resolve camera via NodePath or fallback to viewport camera
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()

	viewport_size = get_viewport_rect().size
	
	# Calculate max bounces from duration
	var player = get_tree().get_first_node_in_group("player")
	if player:
		max_bounces = int(floor((player.effect_duration_multiplier - 1.0) * 10))

	# Connect collision signal
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

func initialize(dir: Vector2, pick_index: int = 0) -> void:
	# — reset pierce counter & set movement —
	direction = dir.normalized()
	hits = 0
	bounce_count = 0
	
	# Apply passives
	var player = get_tree().get_first_node_in_group("player")
	if player:
		damage = int(round(damage * player.damage_multiplier))
		speed *= player.projectile_speed_multiplier
	
	# Rotate sprite so its pointy end (default pointing down) faces `direction`
	sprite.rotation = direction.angle() - PI/2

	# Pick and assign texture based on pick_index
	if textures.size() > 0:
		var tex = textures[pick_index % textures.size()]
		sprite.texture = tex
		# Restore the designer's chosen scale
		sprite.scale = initial_scale

	# Reset offsets and z-index
	sprite.position = Vector2.ZERO
	collision_shape.position = Vector2.ZERO
	sprite.z_index = 1

func _physics_process(delta: float) -> void:
	# Move projectile
	position += direction * speed * delta

	# Offscreen culling
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
		
		# Bounce logic (separate from pierce)
		if hits > pierce_count:
			if bounce_count < max_bounces:
				bounce_count += 1
				hits = 0  # Reset pierce counter for next bounce
				var random_angle = randf_range(0, TAU)
				direction = Vector2(cos(random_angle), sin(random_angle))
				sprite.rotation = direction.angle() - PI/2
			else:
				queue_free()
	elif body.is_in_group("wall"):
		queue_free()

func get_last_movement() -> Vector2:
	return direction
