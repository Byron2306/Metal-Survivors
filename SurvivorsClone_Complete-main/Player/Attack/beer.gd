extends Area2D

@export var beer_sprite: Texture2D
@export var broken_sprite: Texture2D

# ==================================================
# BASE STATS
# ==================================================
var level: int = 1
var damage: int = 5
var speed: float = 200.0
var rotation_speed: float = 360.0
var direction: Vector2 = Vector2.UP
var horizontal_velocity: float = 0.0
var is_broken: bool = false
var viewport_bottom: float = 0.0
var hit_enemies: Array = []

# ==================================================
# PASSIVE-SCALED (CACHED)
# ==================================================
var final_damage: int
var final_speed: float

# ==================================================
# NODES
# ==================================================
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var break_sound: AudioStreamPlayer = $snd_break
@onready var break_timer: Timer = $BreakTimer
@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_array(object)

# ==================================================
# READY
# ==================================================
func _ready() -> void:
	add_to_group("beer")
	sprite.texture = beer_sprite

	if player == null:
		queue_free()
		return

	var viewport_rect: Rect2 = get_viewport_rect()
	var camera = get_tree().get_first_node_in_group("camera")
	if camera != null:
		viewport_bottom = camera.global_position.y + viewport_rect.size.y / 2.0
	else:
		viewport_bottom = global_position.y + viewport_rect.size.y / 2.0

	# Random horizontal drift
	horizontal_velocity = randf_range(50.0, 100.0) * (-1 if randi() % 2 == 0 else 1)

	_apply_level_stats()

	# ─── APPLY PASSIVES (ONCE) ─────────────────────

	# Power Chord (damage)
	final_damage = int(round(damage * player.damage_multiplier))

	# Shred Drive (throw speed)
	final_speed = speed * player.projectile_speed_multiplier

	# Tome (hitbox size)
	if collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size *= (1.0 + player.spell_size)

	get_tree().node_removed.connect(_on_node_removed)

# ==================================================
# LEVEL SCALING
# ==================================================
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

# ==================================================
# PHYSICS
# ==================================================
func _physics_process(delta: float) -> void:
	if not is_broken:
		sprite.rotation_degrees += rotation_speed * delta

		var vel: Vector2 = direction * final_speed
		vel.x += horizontal_velocity
		global_position += vel * delta

		# Simple gravity
		direction.y += 2.0 * delta

		if global_position.y >= viewport_bottom:
			break_bottle()

# ==================================================
# COLLISION / DAMAGE
# ==================================================
func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if not is_broken and enemy.is_in_group("enemy") and enemy.has_method("_on_hurt_box_hurt"):
		if hit_enemies.find(enemy) == -1:
			var angle = global_position.direction_to(enemy.global_position)
			enemy._on_hurt_box_hurt(final_damage, angle, 0)
			hit_enemies.append(enemy)

# ==================================================
# BREAK LOGIC
# ==================================================
func break_bottle() -> void:
	if not is_broken:
		is_broken = true
		sprite.texture = broken_sprite
		sprite.rotation_degrees = 0
		collision_shape.disabled = true
		break_sound.play()
		break_timer.start()

func _on_break_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func _on_node_removed(node: Node) -> void:
	if node == self:
		emit_signal("remove_from_array", self)
		queue_free()
