extends Area2D

@export var level: int = 1
@export var damage: int = 2
@export var speed: float = 150.0
@export var pierce_count: int = 0
@export var camera_path: NodePath

var hits: int = 0
var cam: Camera2D = null
var viewport_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_physics_process(true)
	if camera_path and has_node(camera_path):
		cam = get_node(camera_path) as Camera2D
	else:
		cam = get_viewport().get_camera_2d()
	viewport_size = get_viewport_rect().size
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)
	rotation = deg_to_rad(135)  # Face North West
	print("🔊 [BASS DEBUG] Bass initialized, level=", level, ", damage=", damage, ", speed=", speed, ", pierce_count=", pierce_count, ", camera_path=", camera_path, ", cam=", cam)

func _physics_process(delta: float) -> void:
	position += Vector2(-1, -1).normalized() * speed * delta
	print("🔊 [BASS DEBUG] Bass moving, position=", global_position, ", speed=", speed, ", delta=", delta)
	if cam:
		var half = viewport_size * 0.5 * cam.zoom
		var center = cam.global_position
		var bounds = Rect2(center - half, half * 2)
		if not bounds.has_point(global_position):
			queue_free()
			print("🔊 [BASS DEBUG] Bass out of bounds, queue_free called, position=", global_position, ", bounds=", bounds)

func _on_body_entered(body: Node) -> void:
	print("🔊 [BASS DEBUG] Bass collided with ", body, ", body groups=", body.get_groups())
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(damage, Vector2(-1, -1).normalized(), 0)
		hits += 1
		print("🔊 [BASS DEBUG] Hit enemy, damage=", damage, ", hits=", hits, ", pierce_count=", pierce_count)
		if hits > pierce_count:
			queue_free()
			print("🔊 [BASS DEBUG] Bass exceeded pierce_count, queue_free called")
	elif body.is_in_group("wall"):
		queue_free()
		print("🔊 [BASS DEBUG] Hit wall, queue_free called")
