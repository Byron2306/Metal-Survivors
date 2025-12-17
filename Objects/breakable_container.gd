# breakable_container.gd
extends StaticBody2D

@export var hp: int = 3
@export var drop_chances: Dictionary = {
	"health": 0.35,      # 35% chance
	"gold_small": 0.40,  # 40% chance
	"gold_medium": 0.20, # 20% chance
	"gold_large": 0.05   # 5% chance (rare!)
}

var is_broken: bool = false

# Preload pickup scenes
var health_pickup_scene = preload("res://Objects/health_pickup.tscn")
var gold_small_scene = preload("res://Objects/gold_small.tscn")
var gold_medium_scene = preload("res://Objects/gold_medium.tscn")
var gold_large_scene = preload("res://Objects/gold_large.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_box: Area2D = $HurtBox
@onready var break_particles: CPUParticles2D = $BreakParticles
@onready var break_sound: AudioStreamPlayer2D = $BreakSound

func _ready() -> void:
	add_to_group("container")
	
	# Connect hurt box signals
	if hurt_box:
		hurt_box.add_to_group("container_hurtbox")
		hurt_box.body_entered.connect(_on_hurt_box_body_entered)

func _on_hurt_box_body_entered(body: Node) -> void:
	# Container can be damaged by weapons
	if body.is_in_group("weapon_projectile"):
		take_damage(1)

func take_damage(amount: int) -> void:
	if is_broken:
		return
	
	hp -= amount
	
	# Visual feedback - flash white
	_flash_damage()
	
	if hp <= 0:
		break_container()

func _flash_damage() -> void:
	if sprite:
		sprite.modulate = Color(1.5, 1.5, 1.5)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE

func break_container() -> void:
	if is_broken:
		return
	
	is_broken = true
	
	# Play break effects
	if break_particles:
		break_particles.emitting = true
	if break_sound:
		break_sound.play()
	
	# Hide sprite and collision
	if sprite:
		sprite.visible = false
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hurt_box:
		hurt_box.monitoring = false
	
	# Drop loot
	_drop_loot()
	
	# Remove after particles finish
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _drop_loot() -> void:
	# Randomly determine what to drop based on chances
	var roll = randf()
	var cumulative = 0.0
	var drop_type = ""
	
	for type in drop_chances:
		cumulative += drop_chances[type]
		if roll <= cumulative:
			drop_type = type
			break
	
	# Spawn the pickup
	var pickup = null
	match drop_type:
		"health":
			pickup = health_pickup_scene.instantiate()
		"gold_small":
			pickup = gold_small_scene.instantiate()
		"gold_medium":
			pickup = gold_medium_scene.instantiate()
		"gold_large":
			pickup = gold_large_scene.instantiate()
	
	if pickup:
		get_parent().add_child(pickup)
		pickup.global_position = global_position
		# Add slight upward velocity
		if pickup.has_method("set_initial_velocity"):
			pickup.set_initial_velocity(Vector2(randf_range(-50, 50), -100))
