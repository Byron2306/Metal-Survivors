extends Area2D

# Always preload so we never get "node count is 0"
const IceSpearScene: PackedScene = preload("res://Player/Attack/ice_spear.tscn")

var spawn_extras: bool = true
var level: int = 1
var hp: int = 1             # pierce count
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var move_direction: Vector2 = Vector2.ZERO
var bounce_count: int = 0
var max_bounces: int = 0

@onready var player           = get_tree().get_first_node_in_group("player")
@onready var sprite: AnimatedSprite2D   = $Sprite2D
@ontml:parameter>
<parameter name="collision_shape: CollisionShape2D = $CollisionShape2D
@onready var despawn_timer: Timer       = $Timer

func _ready() -> void:
	_set_stats()
	sprite.scale = Vector2.ONE * attack_size
	_animate_size()
	
	# Calculate max bounces from duration passive
	if player:
		max_bounces = int(floor((player.effect_duration_multiplier - 1.0) * 10))

	# Connect signals once
	var body_c = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", body_c):
		connect("body_entered", body_c)
	var timer_c = Callable(self, "_on_timer_timeout")
	if not despawn_timer.is_connected("timeout", timer_c):
		despawn_timer.connect("timeout", timer_c)

	var enemies: Array = get_tree().get_nodes_in_group("enemy")

	# Multi‑spear for level > 1
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

	# Single‑spear path (level == 1)
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
	global_position += move_direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		var ang = global_position.direction_to(body.global_position)
		body._on_hurt_box_hurt(damage, ang, knockback_amount)
		
		if level < 4:
			# No pierce - check for bounce
			if bounce_count < max_bounces:
				bounce_count += 1
				# Random new direction
				var random_angle = randf_range(0, TAU)
				move_direction = Vector2(cos(random_angle), sin(random_angle))
				rotation = move_direction.angle() + deg_to_rad(135)
				collision_shape.set_deferred("disabled", false)
			else:
				collision_shape.set_deferred("disabled", true)
				queue_free()
		else:
			# Level 4 has pierce
			hp -= 1
			if hp <= 0:
				# Pierce exhausted - check for bounce
				if bounce_count < max_bounces:
					bounce_count += 1
					hp = 2  # Reset pierce
					var random_angle = randf_range(0, TAU)
					move_direction = Vector2(cos(random_angle), sin(random_angle))
					rotation = move_direction.angle() + deg_to_rad(135)
				else:
					collision_shape.set_deferred("disabled", true)
					queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func _set_stats() -> void:
	# Damage now scales 2 → 3 → 4 → 5 at levels 1–4
	if level == 1:
		damage = 2
	elif level == 2:
		damage = 3
	elif level == 3:
		damage = 4
	else:
		damage = 5

	# Pierce only at level 4
	if level >= 4:
		hp = 2
	else:
		hp = 1

	knockback_amount = 100
	speed = 100.0
	attack_size = 1.0
	
	# Apply all passive multipliers
	if player:
		damage = int(round(damage * player.damage_multiplier))
		speed *= player.projectile_speed_multiplier
		attack_size *= (1.0 + player.spell_size)

func _animate_size() -> void:
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * attack_size, 1.0) \
	  .set_trans(Tween.TRANS_QUINT) \
	  .set_ease(Tween.EASE_OUT)
	tw.play()
