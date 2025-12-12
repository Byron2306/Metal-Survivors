extends Area2D
class_name RuneAxeSlice

@export var damage:    int   = 3
@export var swing_time: float = 0.6

enum SwingDir { LEFT, RIGHT }

@onready var sprite:    Sprite2D          = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

# **Always** use a _pure_ vertical offset here.
#  X must be zero, Y is how far up from the player's origin you want the blade.
const AXE_SPAWN_OFFSET := Vector2(0, -40)

func _ready() -> void:
	# 1) Enable the Area2D to detect bodies
	monitoring = true
	# 2) Make sure the CollisionShape2D is active
	col_shape.disabled = false
	# 3) Hook up the collision callback
	connect("body_entered", Callable(self, "_on_body_entered"))

func start_swing(dir: int) -> void:
	position = AXE_SPAWN_OFFSET
	var target_angle = PI/2 if dir == SwingDir.RIGHT else -PI/2

	var tw = create_tween()
	tw.tween_method(
		Callable(self, "orbit_to_angle"),
		0.0,
		target_angle,
		swing_time
	)
	tw.tween_callback(Callable(self, "queue_free"))
	tw.play()


func orbit_to_angle(a: float) -> void:
	# 1) Move the slice around that fixed spawn point
	position = AXE_SPAWN_OFFSET.rotated(a)
	# 2) Rotate the blade so it always “points” along its path
	rotation = a

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		var dir_vec = (position - AXE_SPAWN_OFFSET).normalized()
		body._on_hurt_box_hurt(damage, dir_vec, 0)
	elif body.is_in_group("wall"):
		queue_free()
