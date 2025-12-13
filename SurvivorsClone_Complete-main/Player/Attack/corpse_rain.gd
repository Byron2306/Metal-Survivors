extends Area2D

@export var sprite_type: String = "head"  # head, arm, foot, torso, hand
@export var level: int = 1
@export var damage: int = 5
@export var fall_speed: float = 200.0
@export var rotation_speed: float = 1.0
@export var bounce_speed: float = 100.0

var hits_remaining: int = 2
var velocity: Vector2 = Vector2.ZERO
var sprite_size_scale: float = 1.0
var viewport_rect: Rect2
var is_bouncing: bool = false
var enemies_in_range: Array = []

# ─── PASSIVE-SCALED (CACHED) ─────────────────────
var final_damage: int
var final_fall_speed: float
var final_bounce_speed: float

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
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	if player == null:
		queue_free()
		return

	# Apply level stats first
	update_stats()

	# ─── APPLY PASSIVES (ONCE) ─────────────────────
	final_damage = int(round(damage * player.damage_multiplier))
	final_fall_speed = fall_speed * player.projectile_speed_multiplier
	final_bounce_speed = bounce_speed * player.projectile_speed_multiplier

	# Tome (size)
	sprite_size_scale *= (1.0 + player.spell_size)

	# Init velocity
	velocity = Vector2(0, final_fall_speed)

	# Camera bounds
	var camera = get_tree().get_first_node_in_group("player_camera")
	if camera:
		viewport_rect = camera.get_viewport_rect()
		viewport_rect.position += camera.global_position - viewport_rect.size / 2
	else:
		viewport_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)

	# Sprite visibility
	var sprite_nodes = {
		"head": head_sprite,
		"arm": arm_sprite,
		"foot": foot_sprite,
		"torso": torso_sprite,
		"hand": hand_sprite
	}

	for key in sprite_nodes:
		sprite_nodes[key].visible = (key == sprite_type)
		sprite_nodes[key].scale = base_scales[key] * sprite_size_scale

	# Collision size
	var shape := collision_shape.shape as CircleShape2D
	if shape:
		shape.radius = 10.0 * sprite_size_scale

	if audio_player:
		audio_player.play()

	print("💀 [CORPSE DEBUG] Init type=", sprite_type,
		" level=", level,
		" damage=", final_damage,
		" fall_speed=", final_fall_speed,
		" scale=", sprite_size_scale)

func update_stats() -> void:
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

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	rotation += rotation_speed * delta

	if global_position.y > viewport_rect.position.y + viewport_rect.size.y + 50:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(final_damage, Vector2.ZERO, 0.0)
		hits_remaining -= 1

		print("💀 [CORPSE DEBUG] Hit enemy:", body.name,
			" remaining=", hits_remaining)

		if hits_remaining <= 0:
			queue_free()
		elif not is_bouncing:
			velocity = Vector2(0, -final_bounce_speed)
			is_bouncing = true

func _on_body_exited(body: Node) -> void:
	pass
