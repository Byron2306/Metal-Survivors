extends Area2D

@export var sprite_type: String = "head"  # head, arm, foot, torso, hand
@export var level: int = 1
@export var damage: int = 5
@export var fall_speed: float = 200.0
@export var rotation_speed: float = 1.0  # Radians per second
@export var bounce_speed: float = 100.0  # Speed after bounce

var hits_remaining: int = 2  # Hit two enemies before despawning
var velocity: Vector2 = Vector2.ZERO
var sprite_size_scale: float = 1.0  # Modified by level
var viewport_rect: Rect2
var is_bouncing: bool = false
var enemies_in_range: Array = []
var bounce_count: int = 0
var max_bounces: int = 0
var hit_enemies: Array = []  # Track to prevent multi-hit before bounce
var base_scales: Dictionary = {
	"head": Vector2(0.12, 0.18),
	"arm": Vector2(0.11, 0.12),
	"foot": Vector2(0.13, 0.19),
	"torso": Vector2(0.14, 0.11),
	"hand": Vector2(0.14, 0.15)
}

@onready var head_sprite: Sprite2D = $HeadSprite
@onready var arm_sprite: Sprite2D = $ArmSprite
@onready var foot_sprite: Sprite2D = $FootSprite
@onready var torso_sprite: Sprite2D = $TorsoSprite
@onready var hand_sprite: Sprite2D = $HandSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Set collision layer and mask
	collision_layer = 3  # Match amp_wave.tscn
	collision_mask = 2   # Hit enemies
	
	# Initialize velocity (fall downward)
	velocity = Vector2(0, fall_speed)
	
	# Get viewport rect from camera
	var camera = get_tree().get_first_node_in_group("player_camera")
	if camera:
		viewport_rect = camera.get_viewport_rect()
		viewport_rect.position += camera.global_position - viewport_rect.size / 2
	else:
		viewport_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)
	
	# Set sprite visibility and base scale based on sprite_type
	var sprite_nodes = {
		"head": head_sprite,
		"arm": arm_sprite,
		"foot": foot_sprite,
		"torso": torso_sprite,
		"hand": hand_sprite
	}
	if sprite_type in sprite_nodes and sprite_type in base_scales:
		for key in sprite_nodes:
			sprite_nodes[key].visible = (key == sprite_type)
			sprite_nodes[key].scale = base_scales[key]  # Set base scale
		if not sprite_nodes[sprite_type].texture:
			push_error("No texture set for " + sprite_type + " sprite in CorpseRain")
	else:
		push_error("Invalid sprite_type: " + sprite_type + " in CorpseRain")
		sprite_type = "head"
		for key in sprite_nodes:
			sprite_nodes[key].visible = (key == "head")
			sprite_nodes[key].scale = base_scales["head"]
	
	# Update stats based on level
	update_stats()
	
	# Calculate max bounces from duration
	var player = get_tree().get_first_node_in_group("player")
	if player:
		max_bounces = int(floor((player.effect_duration_multiplier - 1.0) * 10))
	
	# Connect collision signals
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func update_stats() -> void:
	# Update damage and size based on level
	match level:
		1:
			damage = 5
			sprite_size_scale = 1.0
		2:
			damage = 6
			sprite_size_scale = 1.1
		3:
			damage = 7
			sprite_size_scale = 1.2
		4:
			damage = 8
			sprite_size_scale = 1.3
	
	# Apply passives
	var player = get_tree().get_first_node_in_group("player")
	if player:
		damage = int(round(damage * player.damage_multiplier))
		sprite_size_scale *= (1.0 + player.spell_size)
		fall_speed *= player.projectile_speed_multiplier
		rotation_speed *= player.projectile_speed_multiplier
	
	# Apply size scale to each sprite's base scale
	var sprite_nodes = {
		"head": head_sprite,
		"arm": arm_sprite,
		"foot": foot_sprite,
		"torso": torso_sprite,
		"hand": hand_sprite
	}
	for key in sprite_nodes:
		if key in base_scales:
			sprite_nodes[key].scale = base_scales[key] * sprite_size_scale
	
	# Update collision shape
	var shape = collision_shape.shape as CircleShape2D
	if shape:
		shape.radius = 10.0 * sprite_size_scale  # Adjust collision size
	else:
		push_error("CollisionShape2D has no CircleShape2D in CorpseRain")
	
	print("💀 [CORPSE DEBUG] Updated stats, type=", sprite_type, ", level=", level, ", damage=", damage, ", sprite_size_scale=", sprite_size_scale, ", sprite_scale=", sprite_nodes[sprite_type].scale)

func _physics_process(delta: float) -> void:
	# Apply gravity when falling
	if not is_bouncing:
		velocity.y += 400 * delta  # Gravity
	
	# Move
	global_position += velocity * delta
	
	# Rotate
	rotation += rotation_speed * delta
	
	# Ground bounce check
	var camera = get_tree().get_first_node_in_group("player_camera")
	var viewport_bottom = viewport_rect.position.y + viewport_rect.size.y
	if camera:
		viewport_bottom = camera.global_position.y + 360
	
	if global_position.y >= viewport_bottom:
		if bounce_count < max_bounces:
			bounce_count += 1
			velocity.y = -abs(velocity.y) * 0.6  # Bounce upward
			velocity.x = randf_range(-100, 100)  # Random horizontal
			is_bouncing = true
			hit_enemies.clear()  # Allow re-hitting after bounce
		else:
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		# Prevent double-hitting same enemy before bounce
		if hit_enemies.find(body) != -1:
			return
		
		var angle = global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(damage, angle, 0)
		hit_enemies.append(body)
		
		# Enemy bounce
		if bounce_count < max_bounces:
			bounce_count += 1
			# Bounce away from enemy with upward component
			velocity = -angle * bounce_speed
			velocity.y = -abs(velocity.y)  # Ensure upward
			velocity.x += randf_range(-50, 50)  # Add randomness
			is_bouncing = true
			hit_enemies.clear()  # Allow re-hitting after this bounce
		else:
			hits_remaining -= 1
			if hits_remaining <= 0:
				queue_free()


