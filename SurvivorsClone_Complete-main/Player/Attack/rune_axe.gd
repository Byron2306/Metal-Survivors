extends Area2D
class_name RuneAxeSlice

# --- Base stats (designer values) ---
@export var damage: int = 3
@export var swing_time: float = 0.6

enum SwingDir { LEFT, RIGHT }

# --- Runtime (cached after passives) ---
var final_damage: int
var size_multiplier: float = 1.0

@onready var player      = get_tree().get_first_node_in_group("player")
@onready var sprite      = $Sprite2D
@onready var col_shape   = $CollisionShape2D
@onready var snd_slice   = $AudioStreamPlayer

# Capture designer scale so Tome works correctly
@onready var base_scale: Vector2 = sprite.scale

# Fixed vertical offset relative to player
const AXE_SPAWN_OFFSET := Vector2(0, -40)

func _ready() -> void:
	if player == null:
		queue_free()
		return

	monitoring = true
	col_shape.disabled = false

	# ─── APPLY PASSIVES (ONCE) ─────────────────────

	# Power Chord → damage
	final_damage = int(round(damage * player.damage_multiplier))

	# Tome → size (sprite + hitbox)
	size_multiplier = 1.0 + player.spell_size
	sprite.scale = base_scale * size_multiplier

	if col_shape.shape is RectangleShape2D:
		col_shape.shape.size *= size_multiplier

	# Connect collision safely
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

	# Play slice sound once
	if snd_slice and not snd_slice.playing:
		snd_slice.play()

func start_swing(dir: int) -> void:
	position = AXE_SPAWN_OFFSET

	var target_angle := PI / 2 if dir == SwingDir.RIGHT else -PI / 2

	var tw = create_tween()
	tw.tween_method(
		Callable(self, "orbit_to_angle"),
		0.0,
		target_angle,
		swing_time
	)
	tw.tween_callback(Callable(self, "queue_free"))
	tw.play()

func orbit_to_angle(a: float) -> void:
	# Orbit around fixed offset
	position = AXE_SPAWN_OFFSET.rotated(a)
	# Rotate blade along arc
	rotation = a

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		var dir_vec := (position - AXE_SPAWN_OFFSET).normalized()
		body._on_hurt_box_hurt(final_damage, dir_vec, 0)
	elif body.is_in_group("wall"):
		queue_free()
