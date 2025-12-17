extends Area2D

const IceSpikesScene = preload("res://Player/Attack/ice_spikes.tscn")

signal remove_from_array(object: Node)

@export var level: int = 1
var spawn_extra: bool = true
var damage: int
var tick_speed: float
var zone_size: float
var knockback_amount: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_tick_timer: Timer   = $DamageTickTimer
@onready var lifetime_timer: Timer      = $LifetimeTimer
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	update_stats()

	if level == 1 and spawn_extra:
		spawn_extra = false
		var extra = IceSpikesScene.instantiate() as Area2D
		extra.level = level
		extra.spawn_extra = false
		get_parent().add_child(extra)
		extra.global_position = global_position

	var circle := collision_shape.shape as CircleShape2D
	circle.radius = zone_size
	scale = Vector2(0.5, 0.5) * (zone_size / 30.0)
	damage_tick_timer.wait_time = tick_speed
	
	# Apply duration multiplier to lifetime
	lifetime_timer.wait_time = 5.0 * player.effect_duration_multiplier

	if not damage_tick_timer.is_connected("timeout", Callable(self, "_on_damage_tick_timer_timeout")):
		damage_tick_timer.connect("timeout", Callable(self, "_on_damage_tick_timer_timeout"))
	if not lifetime_timer.is_connected("timeout", Callable(self, "_on_lifetime_timer_timeout")):
		lifetime_timer.connect("timeout", Callable(self, "_on_lifetime_timer_timeout"))

	damage_tick_timer.start()
	lifetime_timer.start()

func update_stats() -> void:
	# 1) Weapon‐level stats
	var base_size: float
	match level:
		1:
			damage = 1
			tick_speed = 0.5
			base_size = 30.0
		2:
			damage = 3
			tick_speed = 0.5
			base_size = 35.0
		3:
			damage = 3
			tick_speed = 0.4
			base_size = 35.0
		_:
			damage = 4
			tick_speed = 0.4
			base_size = 40.0

	# apply spell_size bonus (already applied above)
	
	# Apply passives
	damage = int(round(damage * player.damage_multiplier))
	tick_speed /= player.projectile_speed_multiplier  # Faster ticks
	base_size *= (1 + player.spell_size)

	# 2) Character-level shrink, but stop at base_size when char lvl >= 4
	var char_lvl: int = player.experience_level
	var factor: float
	if char_lvl == 1:
		factor = 2.0
	elif char_lvl == 2:
		factor = 2.0 * pow(0.75, 1)   # 1.5
	elif char_lvl == 3:
		factor = 2.0 * pow(0.75, 2)   # ~1.125
	else:
		factor = 1.0                  # no further shrinking

	zone_size = base_size * factor

func _on_damage_tick_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
			var angle = global_position.direction_to(body.global_position)
			body._on_hurt_box_hurt(damage, angle, knockback_amount)

func _on_lifetime_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
