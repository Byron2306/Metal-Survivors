extends Area2D

@export var speed: float = 150
@export var max_bounces: int = 3
@export var damage: int = 2

var direction: Vector2 = Vector2.ZERO
var bounces: int = 0
var shape_radius: float
var camera2d: Camera2D
var last_position: Vector2
var level: int = 0  # set by player.spawn_mosh()

@onready var sprite: Sprite2D               = $Sprite2D
@onready var collision: CollisionShape2D    = $CollisionShape2D
@onready var snd_bounce: AudioStreamPlayer  = $snd_bounce

func _ready() -> void:
	sprite.position    = Vector2.ZERO
	collision.position = Vector2.ZERO

	# Level 1 bounces twice; others thrice
	if level == 1:
		max_bounces = 2
	else:
		max_bounces = 3	
	# Apply passives
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Damage scaling by level
		match level:
			1: damage = 2
			2: damage = 3
			3: damage = 4
			4: damage = 5
		
		damage = int(round(damage * player.damage_multiplier))
		speed *= player.projectile_speed_multiplier
		# Duration adds MORE screen bounces
		max_bounces += int(floor((player.effect_duration_multiplier - 1.0) * 10))
	# Capture radius
	if collision.shape is CircleShape2D:
		shape_radius = collision.shape.radius
	else:
		shape_radius = 16

	last_position = position
	set_physics_process(true)

	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

func _physics_process(delta: float) -> void:
	var view_size: Vector2
	var cam_center: Vector2
	if camera2d:
		view_size   = get_viewport().get_visible_rect().size * camera2d.zoom
		cam_center  = camera2d.global_position
	else:
		view_size   = Vector2(1280, 720)
		cam_center  = view_size * 0.5

	var bounds   = Rect2(cam_center - view_size * 0.5, view_size).grow(-shape_radius)
	var movement = direction.normalized() * speed * delta
	var next_pos = position + movement
	var collided = false

	if (next_pos - last_position).length() < shape_radius * 0.5:
		position = next_pos
		return

	# Bounce on X
	if next_pos.x < bounds.position.x:
		position.x  = bounds.position.x
		direction.x = abs(direction.x)
		collided     = true
	elif next_pos.x > bounds.end.x:
		position.x  = bounds.end.x
		direction.x = -abs(direction.x)
		collided     = true
	else:
		position.x = next_pos.x

	# Bounce on Y
	if next_pos.y < bounds.position.y:
		position.y  = bounds.position.y
		direction.y = abs(direction.y)
		collided     = true
	elif next_pos.y > bounds.end.y:
		position.y  = bounds.end.y
		direction.y = -abs(direction.y)
		collided     = true
	else:
		position.y = next_pos.y

	if collided:
		bounces += 1
		last_position = position
		snd_bounce.play()
		if bounces >= max_bounces:
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, direction, 50)
		# **NO** queue_free here—projectile always pierces
