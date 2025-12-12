extends Node2D

func _ready() -> void:
	print("── All Camera2D nodes in this stage ──")
	_list_cameras(get_tree().get_root())
	print("──────────────────────────────────────")

func _list_cameras(node: Node) -> void:
	if node is Camera2D:
		print(" • ", node.get_path(),
			  "  | current=", node.is_current(),
			  "  | pos=", node.global_position)
	for child in node.get_children():
		_list_cameras(child)
