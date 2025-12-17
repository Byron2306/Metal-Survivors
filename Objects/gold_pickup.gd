# gold_pickup.gd
extends Area2D

enum GoldType { SMALL, MEDIUM, LARGE }
@export var gold_type: GoldType = GoldType.SMALL

var gold_values = {
	GoldType.SMALL: 10,
	GoldType.MEDIUM: 50,
	GoldType.LARGE: 200
}

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 300.0
var is_collected: bool = false
var target_player: Node = null
var magnet_speed: float = 200.0

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
	
	if target_player:
		# Move toward player (magnet effect)
		var direction = (target_player.global_position - global_position).normalized()
		position += direction * magnet_speed * delta
	else:
		# Apply gravity
		velocity.y += gravity * delta
		position += velocity * delta
		
		# Slow down horizontal movement
		velocity.x *= 0.95

func _on_body_entered(body: Node) -> void:
	if is_collected:
		return
	
	if body.is_in_group("player"):
		collect()

func _on_area_entered(area: Node) -> void:
	if is_collected:
		return
	
	# Magnet effect from grab area
	if area.name == "GrabArea":
		target_player = area.get_parent()
	
	# Collect from collect area
	if area.name == "CollectArea":
		collect()

func collect() -> void:
	if is_collected:
		return
	
	is_collected = true
	
	# Add gold to global
	var gold_amount = gold_values[gold_type]
	Global.add_gold(gold_amount)
	
	# Play sound and remove
	if collect_sound:
		collect_sound.play()
		sprite.visible = false
		collision_shape.set_deferred("disabled", true)
		await collect_sound.finished
	
	queue_free()
