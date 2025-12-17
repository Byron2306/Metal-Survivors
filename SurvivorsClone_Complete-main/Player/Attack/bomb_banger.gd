# BombBanger.gd
extends Area2D

@export var level: int = 1
@export var base_damage: int = 5
@export var base_radius: float = 50.0
@export var base_tick_rate: float = 0.1   # seconds between damage ticks

var damage: int
var damage_radius: float
var tick_rate: float

var player
var has_exploded: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D   = $CollisionShape2D
@onready var damage_timer: Timer                 = $DamageTimer
@onready var audio_player: AudioStreamPlayer2D   = $AudioStreamPlayer2D

func _ready() -> void:
	# Fetch Player for passives
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		push_error("BombBanger: no Player in group 'player'")
		return
	player = players[0]

	# Base stats by level
	match level:
		1:
			base_damage = 5
			base_radius = 50.0
		2:
			base_damage = 7
			base_radius = 60.0
		3:
			base_damage = 9
			base_radius = 70.0
		4:
			base_damage = 12
			base_radius = 80.0

	# Apply passives
	damage        = int(round(base_damage * player.damage_multiplier))         # Power Chord
	damage_radius = base_radius * (1.0 + player.spell_size)                   # Tome
	tick_rate     = base_tick_rate / player.projectile_speed_multiplier       # Shred Drive

	# Configure collision shape radius
	var circle = collision_shape.shape as CircleShape2D
	circle.radius = damage_radius

	# Visual: scale the AnimatedSprite2D to match radius
	animated_sprite.scale = Vector2.ONE * (damage_radius / base_radius)

	# Configure damage timer
	damage_timer.wait_time = tick_rate
	damage_timer.one_shot  = false
	damage_timer.autostart = false

	# Play the “pre‐explosion” animation
	animated_sprite.play("banger")

	# Connect signals
	connect("body_entered", Callable(self, "_on_body_entered"))
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	damage_timer.connect("timeout", Callable(self, "_on_DamageTimer_timeout"))

func _on_body_entered(body: Node) -> void:
	if has_exploded:
		return
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		_trigger_explosion()

func _trigger_explosion() -> void:
	has_exploded = true
	# Switch to bomb animation
	animated_sprite.play("bomb", true)
	# Play the sound effect exactly when the bomb animation starts
	audio_player.play()
	# Begin ticking damage
	damage_timer.start()

func _on_DamageTimer_timeout() -> void:
	# Deal tick damage during explosion window
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
			var dir = (body.global_position - global_position).normalized()
			body._on_hurt_box_hurt(damage, dir, 0)

func _on_animation_finished() -> void:
	# Once the bomb animation finishes, stop ticking and free
	damage_timer.stop()
	queue_free()
