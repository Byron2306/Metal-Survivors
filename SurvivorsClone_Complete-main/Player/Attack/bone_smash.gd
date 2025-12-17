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

func _ready():
	# ─── Tome (size) ──────────────────────────────────────────────
	collision_shape.shape.radius = BASE_RADIUS * (1 + player.spell_size)
	smash_sprite.scale           = Vector2.ONE * (1 + player.spell_size)

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
		smash_sprite.position = Vector2(0, -65.45)
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
