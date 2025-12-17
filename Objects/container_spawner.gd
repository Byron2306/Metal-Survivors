# container_spawner.gd
extends Node2D

@export var container_scene: PackedScene = preload("res://Objects/breakable_container.tscn")
@export var spawn_count: int = 50  # Total containers to spawn
@export var spawn_radius: float = 3000.0  # How far from origin to spawn
@export var min_distance_between: float = 200.0  # Minimum spacing
@export var respawn_time: float = 30.0  # Seconds to respawn containers

var spawned_positions: Array[Vector2] = []
var active_containers: Array[Node] = []

@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.wait_time = respawn_time
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	# Initial spawn
	spawn_containers()

func spawn_containers() -> void:
	for i in range(spawn_count):
		var attempts = 0
		var spawn_pos: Vector2
		var valid_position = false
		
		# Try to find a valid spawn position
		while attempts < 50 and not valid_position:
			# Random position in a circle
			var angle = randf() * TAU
			var distance = randf() * spawn_radius
			spawn_pos = Vector2(cos(angle), sin(angle)) * distance
			
			# Check if far enough from other containers
			valid_position = true
			for pos in spawned_positions:
				if spawn_pos.distance_to(pos) < min_distance_between:
					valid_position = false
					break
			
			attempts += 1
		
		if valid_position:
			spawn_container_at(spawn_pos)
			spawned_positions.append(spawn_pos)

func spawn_container_at(pos: Vector2) -> void:
	if not container_scene:
		push_error("Container scene not set in spawner!")
		return
	
	var container = container_scene.instantiate()
	add_child(container)
	container.global_position = pos
	active_containers.append(container)
	
	# Connect to know when it breaks
	container.tree_exiting.connect(_on_container_destroyed.bind(container, pos))

func _on_container_destroyed(container: Node, original_pos: Vector2) -> void:
	active_containers.erase(container)
	# Remove from spawned positions to allow respawn
	spawned_positions.erase(original_pos)

func _on_spawn_timer_timeout() -> void:
	# Respawn containers that were destroyed
	var containers_to_spawn = spawn_count - active_containers.size()
	
	for i in range(containers_to_spawn):
		var attempts = 0
		var spawn_pos: Vector2
		var valid_position = false
		
		while attempts < 50 and not valid_position:
			var angle = randf() * TAU
			var distance = randf() * spawn_radius
			spawn_pos = Vector2(cos(angle), sin(angle)) * distance
			
			valid_position = true
			for pos in spawned_positions:
				if spawn_pos.distance_to(pos) < min_distance_between:
					valid_position = false
					break
			
			attempts += 1
		
		if valid_position:
			spawn_container_at(spawn_pos)
			spawned_positions.append(spawn_pos)
