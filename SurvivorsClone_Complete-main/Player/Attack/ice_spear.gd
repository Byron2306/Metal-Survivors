extends Area2D

# Always preload so we never get "node count is 0"
const IceSpearScene: PackedScene = preload("res://Player/Attack/ice_spear.tscn")

var spawn_extras: bool = true
var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var move_direction: Vector2 = Vector2.ZERO

# ─── PASSIVE-SCALED (CACHED) ─────────────────────
var final_damage: int
var final_speed: float

@onready var player           = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D   = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var despawn_timer: Timer       = $Timer

func _ready() -> void:
	_set_stats()

	# ─── APPLY PASSIVES (ONCE) ─────────────────────
	final_damage = int(round(damage * player.damage_multiplier))
	final_speed = speed * player.projectile_speed_multiplier

	attack_size = 1.0 * (1 + player.spell_size)
	sprite.scale = Vector2.ONE * attack_size
	_animate_size()

	# Connect signals once
	var body_c = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", body_c):
		connect("body_entered", body_c)

	var timer_c = Callable(self, "_on_timer_timeout")
	if not despawn_timer.is_connected("timeout", timer_c):
		despawn_timer.connect("timeout", timer_c)

	var enemies: Array = get_tree().get_nodes_in_group("enemy")

	# ─── MULTI-SPEAR (UNCHANGED) ───────────────────
	if level > 1 and spawn_extras:
		spawn_extras = false
		var spears: Array = [self]
		for i in range(level - 1):
			var extra = IceSpearScene.instantiate() as Area2D
			extra.level = level
			extra.spawn_extras = false
			get_parent().add_child(extra)
			spears.append(extra)

		var avail = enemies.duplicate()
		for spear in spears:
			spear.global_position = global_position
			var dir: Vector2
			if avail.size() > 0:
				var best_idx: int = 0
				var best_dist: float = avail[0].global_position.distance_to(global_position)
				for j in range(1, avail.size()):
					var d: float = avail[j].global_position.distance_to(global_position)
					if d < best_dist:
						best_dist = d
						best_idx = j
				dir = (avail[best_idx].global_position - global_position).normalized()
				avail.remove_at(best_idx)
			else:
				var a = randf_range(0, TAU)
				dir = Vector2(cos(a), sin(a))
			spear.move_direction = dir
			spear.rotation = dir.angle() + deg_to_rad(135)
		return

	# ─── SINGLE-SPEAR PATH ─────────────────────────
	if enemies.size() > 0:
		var best = enemies[0]
		var bestd: float = best.global_position.distance_to(global_position)
		for e in enemies:
			var d: float = e.global_position.distance_to(global_position)
			if d < bestd:
				bestd = d
				best = e
		move_direction = (best.global_position - global_position).normalized()
	else:
		var a = randf_range(0, TAU)
		move_direction = Vector2(cos(a), sin(a))

	rotation = move_direction.angle() + deg_to_rad(135)
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	global_position += move_direction * final_speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		var ang = global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(final_damage, ang, knockback_amount)
		collision_shape.set_deferred("disabled", true)

		if level < 4:
			queue_free()
		else:
			hp -= 1
			if hp <= 0:
				queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func _set_stats() -> void:
	# Damage scaling by level
	if level == 1:
		damage = 2
	elif level == 2:
		damage = 3
	elif level == 3:
		damage = 4
	else:
		damage = 5

	# Pierce only at level 4
	hp = 2 if level >= 4 else 1

	knockback_amount = 100
	speed = 100.0

func _animate_size() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * attack_size, 1.0) \
		.set_trans(Tween.TRANS_QUINT) \
		.set_ease(Tween.EASE_OUT)
	tw.play()
