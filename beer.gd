extends Area2D

@export var beer_sprite: Texture2D
@export var broken_sprite: Texture2D

var level: int = 1
var damage: int = 5
var speed: float = 200.0
var rotation_speed: float = 360.0
var direction: Vector2 = Vector2.UP
var horizontal_velocity: float = 0.0
var is_broken: bool = false
var viewport_bottom: float = 0.0
var hit_enemies: Array = []  # track which foes you’ve already hitvar bounce_count: int = 0
var max_bounces: int = 0
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var break_sound: AudioStreamPlayer = $snd_break
@onready var break_timer: Timer = $BreakTimer
@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_array(object)

func _ready() -> void:
	add_to_group("beer")
	sprite.texture = beer_sprite

	var viewport_rect: Rect2 = get_viewport_rect()
	var camera = get_tree().get_first_node_in_group("camera")
	if camera != null:
		viewport_bottom = camera.global_position.y + viewport_rect.size.y / 2.0
	else:
		viewport_bottom = global_position.y + viewport_rect.size.y / 2.0

	# proper GDScript ternary for random horizontal drift
	horizontal_velocity = randf_range(50.0, 100.0) * (-1 if randi() % 2 == 0 else 1)

	_apply_level_stats()
	
	# Calculate max bounces from duration
	if player:
		max_bounces = int(floor((player.effect_duration_multiplier - 1.0) * 10))

	get_tree().node_removed.connect(_on_node_removed)

func _apply_level_stats() -> void:
	match level:
		1:
			damage = 5
			speed = 200.0
		2:
			damage = 7
			speed = 220.0
		3:
			damage = 7
			speed = 240.0
		4:
			damage = 10
			speed = 260.0
	
	# Apply passives
	if player:
		damage = int(round(damage * player.damage_multiplier))
		speed *= player.projectile_speed_multiplier
		rotation_speed *= player.projectile_speed_multiplier

func increase_damage(amount: int) -> void:
	damage += amount
	print("Beer damage now:", damage)

func _physics_process(delta: float) -> void:
	if not is_broken:
		sprite.rotation_degrees += rotation_speed * delta
		var vel: Vector2 = direction * speed
		vel.x += horizontal_velocity
		global_position += vel * delta

		# simple gravity
		direction.y += 2.0 * delta

		if global_position.y >= viewport_bottom:
			if bounce_count < max_bounces:
				bounce_count += 1
				direction.y = -abs(direction.y) * 0.7  # Bounce upward
				horizontal_velocity *= 0.8  # Dampen horizontal
				global_position.y = viewport_bottom - 5
				break_sound.play()
			else:
				break_bottle()

func break_bottle() -> void:
	if not is_broken:
		is_broken = true
		sprite.texture = broken_sprite
		sprite.rotation_degrees = 0
		collision_shape.disabled = true
		break_sound.play()
		break_timer.start()

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if not is_broken and enemy.is_in_group("enemy") and enemy.has_method("_on_hurt_box_hurt"):
		if hit_enemies.find(enemy) == -1:
			var angle = global_position.direction_to(enemy.global_position)
			enemy._on_hurt_box_hurt(damage, angle, 0)
			hit_enemies.append(enemy)
			
			# Enemy bounce
			if bounce_count < max_bounces:
				bounce_count += 1
				# Bounce away from enemy
				direction = -angle
				direction.y = -abs(direction.y) * 0.6  # Add upward component
				horizontal_velocity = randf_range(-100, 100)  # Random horizontal
				break_sound.play()
				# Clear hit list on bounce to allow re-hitting
				hit_enemies.clear()
			else:
				break_bottle()

func _on_break_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func _on_node_removed(node: Node) -> void:
	if node == self:
		emit_signal("remove_from_array", self)
		queue_free()
