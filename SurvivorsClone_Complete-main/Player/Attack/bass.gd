extends Node2D

# ==================================================
# BASE STATS (PER LEVEL)
# ==================================================
var level: int = 1
var damage: int = 3
var tick_speed: float = 0.8
var radius: float = 90.0
var duration: float = 3.0

# ==================================================
# PASSIVE-SCALED (CACHED)
# ==================================================
var final_damage: int
var final_tick_speed: float
var final_duration: float

# ==================================================
# COMBAT
# ==================================================
var enemies_in_range: Array = []

# ==================================================
# NODES
# ==================================================
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var damage_timer: Timer = $DamageTimer
@onready var sprite: Sprite2D = $BassSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var player = get_tree().get_first_node_in_group("player")

# ==================================================
# READY
# ==================================================
func _ready():
	if player == null:
		queue_free()
		return

	update_stats()

	# ─── APPLY PASSIVES ────────────────────────────
	final_damage = int(round(damage * player.damage_multiplier))
	final_tick_speed = tick_speed / max(player.projectile_speed_multiplier, 0.01)
	final_duration = duration * player.effect_duration_multiplier

	# Tome (size)
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius * (1.0 + player.spell_size)

	# Timers
	damage_timer.wait_time = final_tick_speed
	damage_timer.start()

	# Lifetime
	get_tree().create_timer(final_duration).timeout.connect(queue_free)

	# Visuals / sound
	if audio_player:
		audio_player.play()

# ==================================================
# DAMAGE
# ==================================================
func _on_DamageTimer_timeout():
	for enemy in enemies_in_range:
		if enemy and enemy.has_method("_on_hurt_box_hurt"):
			var dir = (enemy.global_position - global_position).normalized()
			enemy._on_hurt_box_hurt(final_damage, dir, 0)

# ==================================================
# AREA TRACKING
# ==================================================
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)

# ==================================================
# LEVEL SCALING (KEEP YOUR BALANCE)
# ==================================================
func update_stats():
	match level:
		1:
			damage = 3
			tick_speed = 0.8
			radius = 90.0
			duration = 3.0
		2:
			damage = 4
			tick_speed = 0.7
			radius = 110.0
			duration = 3.5
		3:
			damage = 5
			tick_speed = 0.6
			radius = 130.0
			duration = 4.0
		4:
			damage = 6
			tick_speed = 0.5
			radius = 150.0
			duration = 4.5
