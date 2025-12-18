extends Area2D

@export var beer_sprite: Texture2D
@export var broken_sprite: Texture2D

signal remove_from_array(object)

var level: int = 1

var damage: int = 5
var rotation_speed_deg: float = 360.0

var velocity: Vector2 = Vector2.ZERO
var gravity_accel: float = 1200.0

var is_broken: bool = false
var bounce_count: int = 0
var max_bounces: int = 0
var _removed_emitted: bool = false

var _hit_enemies: Array = []

var _base_scale: Vector2 = Vector2.ONE

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var break_sound: AudioStreamPlayer = $snd_break
@onready var break_timer: Timer = $BreakTimer
@onready var player: Node = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	_base_scale = scale
	add_to_group("beer")
	if beer_sprite:
		sprite.texture = beer_sprite

	# Ensure signals are connected even if the scene wiring changes.
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if break_timer and not break_timer.timeout.is_connected(_on_break_timer_timeout):
		break_timer.timeout.connect(_on_break_timer_timeout)
	if break_timer:
		break_timer.one_shot = true

	_apply_level_stats()
	_configure_max_bounces()
	_init_throw_velocity()
	_apply_size_scale()

func _apply_size_scale() -> void:
	if not player:
		return
	var spell_size_val = player.get("spell_size")
	var spell_size := float(spell_size_val) if spell_size_val != null else 0.0
	scale = _base_scale * (1.0 + spell_size)

func _apply_level_stats() -> void:
	# Base stats by weapon level
	match level:
		1:
			damage = 5
		2:
			damage = 7
		3:
			damage = 7
		4:
			damage = 10
		_:
			damage = 10

	# Apply passives
	if player:
		var dmg_mult_val = player.get("damage_multiplier")
		if dmg_mult_val != null:
			damage = int(round(damage * float(dmg_mult_val)))
		var proj_speed_val = player.get("projectile_speed_multiplier")
		if proj_speed_val != null:
			rotation_speed_deg *= float(proj_speed_val)
			gravity_accel *= float(proj_speed_val)

func _configure_max_bounces() -> void:
	max_bounces = 0
	if player:
		var dur_val = player.get("effect_duration_multiplier")
		if dur_val != null:
			# +0.10 duration => +1 bounce (scaled)
			max_bounces = max(0, int(floor((float(dur_val) - 1.0) * 10.0)))

func _init_throw_velocity() -> void:
	# Stable arc: fixed upward impulse + modest horizontal drift.
	# (Player code currently only sets position + level.)
	var base_up: float = -520.0
	var base_side: float = randf_range(140.0, 220.0) * (-1.0 if randi() % 2 == 0 else 1.0)
	velocity = Vector2(base_side, base_up)

	# Apply projectile speed passive to throw speed too.
	if player:
		var proj_speed_val = player.get("projectile_speed_multiplier")
		if proj_speed_val != null:
			velocity *= float(proj_speed_val)

func _physics_process(delta: float) -> void:
	if is_broken:
		return

	sprite.rotation_degrees += rotation_speed_deg * delta

	velocity.y += gravity_accel * delta
	global_position += velocity * delta

	var floor_y := _get_floor_y()
	if global_position.y >= floor_y:
		if bounce_count < max_bounces:
			bounce_count += 1
			global_position.y = floor_y - 2.0
			velocity.y = -abs(velocity.y) * 0.65
			velocity.x *= 0.85
			if break_sound:
				break_sound.play()
			_hit_enemies.clear()
		else:
			call_deferred("break_bottle")

func _get_floor_y() -> float:
	# Bottom of the *current* view area (active Camera2D).
	var viewport := get_viewport()
	var view_size: Vector2 = viewport.get_visible_rect().size if viewport else get_viewport_rect().size

	var cam: Camera2D = viewport.get_camera_2d() if viewport else null
	if cam == null and player:
		cam = player.get_node_or_null("Camera2D") as Camera2D

	if cam:
		var zoomed_size := view_size * cam.zoom
		return cam.global_position.y + zoomed_size.y * 0.5

	var anchor_y: float = player.global_position.y if player else global_position.y
	return anchor_y + view_size.y * 0.5

func break_bottle() -> void:
	if is_broken:
		return

	is_broken = true
	velocity = Vector2.ZERO
	rotation_degrees = 0.0
	visible = true
	sprite.visible = true
	sprite.rotation_degrees = 0.0
	if broken_sprite:
		sprite.texture = broken_sprite

	# Avoid "flushing queries" errors by deferring collision/monitoring changes.
	call_deferred("_disable_collisions")
	break_sound.play()
	if break_timer:
		break_timer.start()
	else:
		_die()

func _disable_collisions() -> void:
	monitoring = false
	monitorable = false
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	if collision_shape:
		collision_shape.call_deferred("set_disabled", true)

func _on_area_entered(area: Area2D) -> void:
	if is_broken:
		return

	var enemy := area.get_parent()
	if enemy == null:
		return
	var enemy_node2d := enemy as Node2D
	if enemy_node2d == null:
		return
	if not enemy.is_in_group("enemy"):
		return
	if not enemy.has_method("_on_hurt_box_hurt"):
		return
	if _hit_enemies.has(enemy):
		return

	var hit_dir := global_position.direction_to(enemy_node2d.global_position)
	enemy._on_hurt_box_hurt(damage, hit_dir, 0)
	_hit_enemies.append(enemy)
	# Infinite pierce: no bounce, no break on enemies.

func _on_break_timer_timeout() -> void:
	_die()

func _die() -> void:
	if not _removed_emitted:
		_removed_emitted = true
		emit_signal("remove_from_array", self)
	queue_free()
