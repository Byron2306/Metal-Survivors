# bone_smash.gd
extends Area2D

@export var level: int = 1
@export var damage: int = 8
@export var speed: float = 600.0
@export var target_position: Vector2 = Vector2.ZERO

const BASE_RADIUS: float       = 100.045
const BASE_TICK_INTERVAL: float = 0.1
const BASE_DURATION: float      = 1.4

@onready var bone_sprite: AnimatedSprite2D     = $BoneSprite
@onready var smash_sprite: AnimatedSprite2D    = $SmashSprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player = get_tree().get_first_node_in_group("player")

var has_reached_target: bool = false
var _base_scale: Vector2 = Vector2.ONE

func _ready():
	_base_scale = scale
	# ─── Tome (size) ──────────────────────────────────────────────
	if player:
		var size_mult = (1.0 + player.spell_size)
		scale = _base_scale * size_mult
		# Scale both sprites to match
		bone_sprite.scale = Vector2.ONE * size_mult
		smash_sprite.scale = Vector2.ONE * size_mult
	# Keep the authored collision radius; scaling handles growth.
	var circle := collision_shape.shape as CircleShape2D
	if circle:
		circle.radius = BASE_RADIUS

func _physics_process(delta: float) -> void:
	if has_reached_target:
		return

	# ─── Movement (Shred Drive) ──────────────────────────────────
	var direction = Vector2.DOWN
	var move_dist = speed * player.projectile_speed_multiplier * delta
	var dist_to_target = abs(global_position.y - target_position.y)

	if dist_to_target <= move_dist:
		# Arrive
		global_position.y = target_position.y
		bone_sprite.visible = false
		smash_sprite.visible = true
		# Position accounts for scaled sprite size
		var offset_y = -65.45 * smash_sprite.scale.y
		smash_sprite.position = Vector2(0, offset_y)
		collision_shape.position = smash_sprite.position
		audio_player.play()
		has_reached_target = true

		# ─── Tick-based damage setup ────────────────────────────────
		var damage_timer = Timer.new()
		damage_timer.wait_time = BASE_TICK_INTERVAL / player.projectile_speed_multiplier  # Shred Drive
		damage_timer.one_shot  = false
		add_child(damage_timer)
		damage_timer.start()
		damage_timer.connect("timeout", Callable(self, "_on_damage_tick"))

		# Stop ticking after full duration (Resonance Pedal)
		var stop_timer = get_tree().create_timer(BASE_DURATION * player.effect_duration_multiplier)
		stop_timer.connect("timeout", Callable(damage_timer, "stop"))

		# Free the damage_timer once it stops
		damage_timer.connect("timeout", Callable(damage_timer, "queue_free"), CONNECT_ONE_SHOT)

		# ─── Smash animation & cleanup ──────────────────────────────
		smash_sprite.connect("animation_finished", Callable(self, "_on_smash_animation_finished"), CONNECT_ONE_SHOT)
		smash_sprite.play("smash")
	else:
		# Keep moving
		global_position += direction * move_dist

func _on_damage_tick() -> void:
	# ─── Power Chord (damage) ─────────────────────────────────────
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
			body._on_hurt_box_hurt(damage * player.damage_multiplier, Vector2.ZERO, 0.0)

func _on_smash_animation_finished() -> void:
	queue_free()
