extends Sprite2D

@export var camera_path: NodePath
@onready var cam: Camera2D = get_node(camera_path) as Camera2D

func _process(delta: float) -> void:
	# Shift the region rect so the texture scrolls under the view.
	# We floor() to keep pixel‑perfect alignment.
	region_rect.position = cam.global_position.floor()
