extends Area2D

# No longer using remove_from_array for persistent javelin

# Runtime stats (updated each volley from player.javelin_level)
var level: int
var damage: int
var knockback_amount: int
var paths: int
var speed: float = 200.0
const BASE_SPEED: float = 200.0
const LEASH_FRACTION: float = 0.60

# Firing state
var targets: Array = []
var direction: Vector2 = Vector2.ZERO
var fired: bool = false
var flights_remaining: int = 0  # Additional targeting flights from duration passive

# Resources
var spr_attack = preload("res://Textures/Items/Weapons/javelin.png")
var spr_normal = preload("res://Textures/Items/Weapons/javelin.png")

# Nodes
@onready var player       = get_tree().get_first_node_in_group("player")
@onready var sprite       = $Sprite2D
@onready var collider     = $CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var snd_attack   = $snd_attack
@onready var camera2d: Camera2D = get_viewport().get_camera_2d()
@onready var viewport_size: Vector2 = get_viewport().get_visible_rect().size

func _ready() -> void:
	# Connect collision once
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)
	
	if player:
		flights_remaining = int(floor((player.effect_duration_multiplier - 1.0) * 10))
	else:
		attack_timer.stop()
		return

	# Configure the timer to repeat
	attack_timer.one_shot = false
	attack_timer.autostart = true
	attack_timer.wait_time = 5.0 / max(player.javelin_level, 1)
	# AttackTimer → _on_attack_timer_timeout is connected in the TSCN

func _on_attack_timer_timeout() -> void:
	if not player:
		return

	# Refresh upgrade stats
	level = player.javelin_level
	match level:
		1:
			paths = 1; damage = 5;  knockback_amount = 100
		2:
			paths = 2; damage = 5;  knockback_amount = 100
		3:
			paths = 3; damage = 7;  knockback_amount = 100
		4:
			paths = 3; damage = 9;  knockback_amount = 120
	
	# Apply passives (reset per volley so it doesn't multiply forever)
	damage = int(round(damage * player.damage_multiplier))
	speed = BASE_SPEED * player.projectile_speed_multiplier
	
	# Reset flights for new volley
	flights_remaining = int(floor((player.effect_duration_multiplier - 1.0) * 10))

	# Manual selection of closest `paths` enemies (anchored to player, and prefer in-view)
	var avail: Array = get_tree().get_nodes_in_group("enemy").duplicate()
	avail = _filter_targets_near_player(avail)
	targets.clear()
	for i in range(paths):
		if avail.size() > 0:
			var best_idx: int = 0
			var best_dist: float = avail[0].global_position.distance_to(player.global_position)
			for j in range(1, avail.size()):
				var d: float = avail[j].global_position.distance_to(player.global_position)
				if d < best_dist:
					best_dist = d
					best_idx = j
			targets.append(avail[best_idx].global_position)
			avail.remove_at(best_idx)
		else:
			# fallback if no enemies
			targets.append(player.global_position)

	_fire_next()

func _fire_next() -> void:
	if targets.is_empty():
		# Check if we have additional flights remaining
		if flights_remaining > 0:
			flights_remaining -= 1
			# Acquire NEW targets for another flight
			_acquire_new_targets()
			return
		
		# No more flights - reset state
		fired = false
		collider.set_deferred("disabled", true)
		sprite.texture = spr_normal
		return

	snd_attack.play()
	direction = (targets.pop_front() - global_position).normalized()
	rotation = direction.angle() + deg_to_rad(135)
	collider.set_deferred("disabled", false)
	sprite.texture = spr_attack
	fired = true

func _physics_process(delta: float) -> void:
	if fired:
		global_position += direction * speed * delta
		_pull_back_if_too_far()
		_clamp_to_screen()

func _on_body_entered(body: Node) -> void:
	if fired and body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		# damage the enemy
		body._on_hurt_box_hurt(damage, direction, knockback_amount)
		# prepare next shot
		fired = false
		collider.set_deferred("disabled", true)
		sprite.texture = spr_normal
		await get_tree().create_timer(0.1).timeout
		_fire_next()

func _acquire_new_targets() -> void:
	# Same logic as _on_attack_timer_timeout but for mid-flight retargeting
	var avail: Array = get_tree().get_nodes_in_group("enemy").duplicate()
	avail = _filter_targets_near_player(avail)
	targets.clear()
	for i in range(paths):
		if avail.size() > 0:
			var best_idx: int = 0
			var best_dist: float = avail[0].global_position.distance_to(player.global_position)
			for j in range(1, avail.size()):
				var d: float = avail[j].global_position.distance_to(player.global_position)
				if d < best_dist:
					best_dist = d
					best_idx = j
			targets.append(avail[best_idx].global_position)
			avail.remove_at(best_idx)
		else:
			# fallback if no enemies
			targets.append(player.global_position)
	
	_fire_next()

func _clamp_to_screen() -> void:
	if camera2d == null:
		camera2d = get_viewport().get_camera_2d()
	if camera2d == null:
		return
	viewport_size = get_viewport().get_visible_rect().size
	var view_size := viewport_size * camera2d.zoom
	var half := view_size * 0.5
	var cp := camera2d.global_position
	global_position.x = clamp(global_position.x, cp.x - half.x, cp.x + half.x)
	global_position.y = clamp(global_position.y, cp.y - half.y, cp.y + half.y)

func _pull_back_if_too_far() -> void:
	if not player:
		return
	var leash := _get_leash_distance()
	if global_position.distance_to(player.global_position) > leash:
		direction = (player.global_position - global_position).normalized()
		rotation = direction.angle() + deg_to_rad(135)

func _get_leash_distance() -> float:
	if camera2d == null:
		camera2d = get_viewport().get_camera_2d()
	viewport_size = get_viewport().get_visible_rect().size
	if camera2d:
		var view_size := viewport_size * camera2d.zoom
		return min(view_size.x, view_size.y) * LEASH_FRACTION
	return 600.0

func _filter_targets_near_player(all_enemies: Array) -> Array:
	if not player:
		return all_enemies
	# Prefer enemies in the current camera view; fallback to all if none.
	var in_view: Array = []
	if camera2d == null:
		camera2d = get_viewport().get_camera_2d()
	if camera2d:
		viewport_size = get_viewport().get_visible_rect().size
		var view_size := viewport_size * camera2d.zoom
		var half := view_size * 0.5
		var cp := camera2d.global_position
		for e in all_enemies:
			if e == null:
				continue
			var p: Vector2 = e.global_position
			if abs(p.x - cp.x) <= half.x and abs(p.y - cp.y) <= half.y:
				in_view.append(e)
	if in_view.size() > 0:
		return in_view
	return all_enemies
