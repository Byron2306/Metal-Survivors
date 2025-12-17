# health_pickup.gd
extends Area2D

@export var heal_amount: int = 10
var velocity: Vector2 = Vector2.ZERO
var gravity: float = 300.0
var is_collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound

func _ready() -> void:
	add_to_group("pickup")
	add_to_group("loot")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func set_initial_velocity(vel: Vector2) -> void:
	velocity = vel

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	# Apply gravity
	velocity.y += gravity * delta
	position += velocity * delta
	
	# Slow down horizontal movement
	velocity.x *= 0.95

func _on_body_entered(body: Node) -> void:
	if is_collected:
		return
	
	if body.is_in_group("player"):
		collect(body)

func _on_area_entered(area: Node) -> void:
	if is_collected:
		return
	
	# Check if player's collect area
	if area.name == "CollectArea" or area.get_parent().is_in_group("player"):
		var player = area.get_parent() if area.get_parent().is_in_group("player") else get_tree().get_first_node_in_group("player")
		if player:
			collect(player)

func collect(player: Node) -> void:
	if is_collected:
		return
	
	is_collected = true
	
	# Heal player
	if player.has_method("heal"):
		player.heal(heal_amount)
	elif player.has("hp") and player.has("maxhp"):
		player.hp = min(player.hp + heal_amount, player.maxhp)
		if player.has_node("HealthBar"):
			player.get_node("HealthBar").value = player.hp
	
	# Play sound and remove
	if collect_sound:
		collect_sound.play()
		sprite.visible = false
		collision_shape.set_deferred("disabled", true)
		await collect_sound.finished
	
	queue_free()
