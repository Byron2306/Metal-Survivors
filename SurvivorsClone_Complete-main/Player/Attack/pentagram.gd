extends Area2D

# Overridden by player.pentagram_level
var level: int = 0
var damage: int = 1
var tick_speed: float = 1.0
var aura_size: float = 50.0

# Passive-scaled (cached)
var final_damage: int
var final_tick_speed: float
var final_aura_size: float

@onready var player          = get_tree().get_first_node_in_group("player")
@onready var collision_shape = $CollisionShape2D
@onready var sprite          = $AnimatedSprite2D
@onready var damage_timer    = $DamageTimer

var enemies_in_range: Array = []

func _ready() -> void:
	if player:
		level = player.pentagram_level

	update_stats()

	# ─── APPLY PASSIVES (ONCE) ────────────────────

	# Power Chord → damage
	final_damage = int(round(damage * player.damage_multiplier))

	# Shred Drive → tick speed
	final_tick_speed = tick_speed / max(player.projectile_speed_multiplier, 0.01)

	# Tome → aura size
	final_aura_size = aura_size * (1.0 + player.spell_size)

	# Apply size
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = final_aura_size
	sprite.scale = Vector2(final_aura_size / 100.0, final_aura_size / 100.0)

	# Apply timer
	damage_timer.wait_time = final_tick_speed
	damage_timer.start()

	# Connect signals once
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(_delta: float) -> void:
	if player:
		global_position = player.global_position

func _on_damage_timer_timeout() -> void:
	for enemy in enemies_in_range:
		if enemy and enemy.has_method("_on_hurt_box_hurt"):
			var dir = (enemy.global_position - global_position).normalized()
			enemy._on_hurt_box_hurt(final_damage, dir, 0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)

func update_stats() -> void:
	match level:
		1:
			damage     = 2
			tick_speed = 1.0
			aura_size  = 50.0
		2:
			damage     = 3
			tick_speed = 1.0
			aura_size  = 60.0
		3:
			damage     = 4
			tick_speed = 0.6
			aura_size  = 70.0
		4:
			damage     = 5
			tick_speed = 0.4
			aura_size  = 80.0
		_:
			damage     = 2
			tick_speed = 1.0
			aura_size  = 50.0

