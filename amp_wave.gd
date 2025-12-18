extends Node2D

# ==================================================
# BASE STATS (set by level)
# ==================================================
var level: int = 1
var damage: int = 2
var tick_speed: float = 1.0
var aura_size: float = 114.039

# ==================================================
# ANIMATION STATE
# ==================================================
var frame: int = 0
var max_frames: int = 42
var is_animating: bool = false

# ==================================================
# COMBAT STATE
# ==================================================
var hits: int = 0
var enemies_in_range: Array = []

# ==================================================
# PASSIVE-SCALED (CACHED)
# ==================================================
var final_damage: int
var final_tick_speed: float
var final_duration: float

# ==================================================
# NODES
# ==================================================
@onready var amp_sprite = $AmpSprite
@onready var wave_sprite = $AmpWaveSprite
@onready var animation_timer = $AnimationTimer
@onready var damage_timer = $DamageTimer
@onready var area_2d = $Area2D
@onready var player = get_tree().get_first_node_in_group("player")

var _base_scale: Vector2 = Vector2.ONE

# ==================================================
# READY
# ==================================================
func _ready():
	if player == null:
		queue_free()
		return
	_base_scale = scale

	# Start with amp.png visible
	amp_sprite.visible = true
	wave_sprite.visible = false

	# Update base stats from level
	update_stats()

	# ─── APPLY PASSIVES (ONCE) ─────────────────────

	# Power Chord (damage)
	final_damage = int(round(damage * player.damage_multiplier))

	# Tome (size) - apply via node scaling so sprite + collision scale together
	scale = _base_scale * (1.0 + player.spell_size)

	# Shred Drive (tick speed)
	final_tick_speed = tick_speed / max(player.projectile_speed_multiplier, 0.01)

	# Resonance Pedal (duration)
	final_duration = (max_frames * animation_timer.wait_time) * player.effect_duration_multiplier

	# Apply to collision + timers (radius remains authored-by-level; node scale handles size)
	area_2d.get_node("CollisionShape2D").shape.radius = aura_size
	damage_timer.wait_time = final_tick_speed

	# Debug
	print("🔊 [AMP DEBUG] AmpWave initialized at position: ", global_position)
	print("🔊 [AMP DEBUG] Damage: ", final_damage,
		" Tick speed: ", final_tick_speed,
		" Aura size: ", aura_size,
		" Level: ", level)

	# Start damage ticking
	damage_timer.start()

	# Start animation shortly after
	await get_tree().create_timer(0.5).timeout
	start_animation()

	# Stop everything after duration (Resonance Pedal)
	get_tree().create_timer(final_duration).timeout.connect(queue_free)

# ==================================================
# ANIMATION
# ==================================================
func start_animation():
	is_animating = true
	amp_sprite.visible = true
	wave_sprite.visible = true
	wave_sprite.frame = 0
	frame = 0
	animation_timer.start()
	print("🔊 [AMP DEBUG] AmpWave animation started")

func _on_AnimationTimer_timeout():
	if frame < max_frames:
		wave_sprite.frame = frame
		frame += 1
		animation_timer.start()
	else:
		print("🔊 [AMP DEBUG] AmpWave animation complete, hits: ", hits)
		queue_free()

# ==================================================
# DAMAGE TICKS
# ==================================================
func _on_damage_timer_timeout():
	print("🔊 [AMP DEBUG] Damage tick, enemies in range: ", enemies_in_range.size())
	for enemy in enemies_in_range:
		if enemy and enemy.has_method("_on_hurt_box_hurt"):
			var dir = (enemy.global_position - global_position).normalized()
			print("🔊 [AMP DEBUG] Applying damage: ", final_damage, " to enemy: ", enemy.name)
			enemy._on_hurt_box_hurt(final_damage, dir, 0)
			hits += 1

# ==================================================
# AREA2D TRACKING
# ==================================================
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)
		print("🔊 [AMP DEBUG] Enemy entered: ", body.name)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)
		print("🔊 [AMP DEBUG] Enemy exited: ", body.name)

# ==================================================
# LEVEL SCALING (UNCHANGED)
# ==================================================
func update_stats():
	print("🔊 [AMP DEBUG] Updating stats for level: ", level)
	match level:
		1:
			damage = 2
			tick_speed = 1.0
			aura_size = 114.039
		2:
			damage = 3
			tick_speed = 0.8
			aura_size = 150.0
		3:
			damage = 4
			tick_speed = 0.6
			aura_size = 175.0
		4:
			damage = 5
			tick_speed = 0.4
			aura_size = 200.0

	print("🔊 [AMP DEBUG] Base damage:", damage,
		" Base tick:", tick_speed,
		" Base aura:", aura_size)
