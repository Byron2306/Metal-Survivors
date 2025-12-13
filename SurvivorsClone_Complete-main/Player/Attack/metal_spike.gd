extends Node2D

# Pure orbit + hit logic — no spawning in here
var level: int = 1
var damage: int
var knockback_amount: int
var rotation_speed: float
var orbit_radius: float

# Passive-scaled (cached)
var final_damage: int
var final_rotation_speed: float
var final_orbit_radius: float

# Each spike carries its own starting angle
var angle: float = 0.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if player == null:
		queue_free()
		return

	# 1) Read weapon level
	level = player.metalSpike_level

	# 2) Base weapon stats
	match level:
		1:
			damage = 4
			rotation_speed = 1.0
			orbit_radius = 100.0
		2:
			damage = 5
			rotation_speed = 1.2
			orbit_radius = 100.0
		3:
			damage = 6
			rotation_speed = 1.5
			orbit_radius = 100.0
		4:
			damage = 8
			rotation_speed = 2.0
			orbit_radius = 120.0
		_:
			damage = 4
			rotation_speed = 1.0
			orbit_radius = 100.0

	knockback_amount = 100

	# ─── APPLY PASSIVES (ONCE) ────────────────────

	# Power Chord → damage
	final_damage = int(round(damage * player.damage_multiplier))

	# Shred Drive → rotation speed
	final_rotation_speed = rotation_speed * player.projectile_speed_multiplier

	# Tome → orbit radius + hitbox size
	final_orbit_radius = orbit_radius * (1.0 + player.spell_size)

	var shape := collision_shape.shape as RectangleShape2D
	if shape:
		shape.size *= (1.0 + player.spell_size)

	# 3) Hook up collision once
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

func _physics_process(delta: float) -> void:
	# Orbit around the player
	angle += final_rotation_speed * delta
	var offset = Vector2(cos(angle), sin(angle)) * final_orbit_radius
	global_position = player.global_position + offset
	rotation = angle + PI * 0.5  # face outward

func _on_body_entered(body: Node) -> void:
	# Deal damage, but never destroy the spike
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		var dir = (body.global_position - global_position).normalized()
		body._on_hurt_box_hurt(final_damage, dir, knockback_amount)
