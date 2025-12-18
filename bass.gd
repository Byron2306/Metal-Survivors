extends Area2D

@export var level: int = 1
@export var damage: int = 2
@export var speed: float = 150.0
@export var pierce_count: int = 0
@export var camera_path: NodePath

var hits: int = 0
var direction: Vector2 = Vector2.ZERO
var cam: Camera2D = null
var viewport_size: Vector2 = Vector2.ZERO
var bounce_count: int = 0
var max_bounces: int = 0
var _base_scale: Vector2 = Vector2.ONE

func _ready() -> void:
	set_physics_process(true)
	_base_scale = scale
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()
	viewport_size = get_viewport().get_visible_rect().size if get_viewport() else get_viewport_rect().size
	
	# Apply passives
	var player = get_tree().get_first_node_in_group("player")
	if player:
		damage = int(round(damage * player.damage_multiplier))
		speed *= player.projectile_speed_multiplier
		max_bounces = int(floor((player.effect_duration_multiplier - 1.0) * 10))
		scale = _base_scale * (1.0 + player.spell_size)
	
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)
	direction = Vector2(-1, -1).normalized()
	rotation = direction.angle()  # Face movement

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if cam:
		viewport_size = get_viewport().get_visible_rect().size if get_viewport() else viewport_size
		var half = (viewport_size * cam.zoom) * 0.5
		var center = cam.global_position
		var bounds = Rect2(center - half, half * 2)
		if not bounds.has_point(global_position):
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, Vector2(-1, -1).normalized(), 0)
		hits += 1
		
		if hits > pierce_count:
			if bounce_count < max_bounces:
				bounce_count += 1
				hits = 0  # Reset pierce
				var random_angle = randf_range(0, TAU)
				direction = Vector2(cos(random_angle), sin(random_angle))
				rotation = direction.angle()
			else:
				queue_free()
	elif body.is_in_group("wall"):
		queue_free()
