extends Area2D

# Runtime stats (updated each volley)
var level: int
var damage: int
var knockback_amount: int
var paths: int
var speed: float = 200.0

# Passive-scaled
var final_damage: int
var final_speed: float

# Firing state
var targets: Array = []
var direction: Vector2 = Vector2.ZERO
var fired: bool = false

# Resources
var spr_attack = preload("res://Textures/Items/Weapons/javelin.png")
var spr_normal = preload("res://Textures/Items/Weapons/javelin.png")

# Nodes
@onready var player        = get_tree().get_first_node_in_group("player")
@onready var sprite        = $Sprite2D
@onready var collider      = $CollisionShape2D
@onready var attack_timer  = $AttackTimer
@onready var snd_attack    = $snd_attack
@onready var camera        = get_tree().get_first_node_in_group("camera2d")
@onready var viewport_size = get_viewport_rect().size

func _ready() -> void:
	# Connect collision once
	var cb = Callable(self, "_on_body_entered")
	if not is_connected("body_entered", cb):
		connect("body_entered", cb)

	attack_timer.one_shot = false
	attack_timer.autostart = true

	# Scroll affects fire rate
	attack_timer.wait_time = (5.0 / max(player.javelin_level, 1)) * (1.0 - player.spell_cooldown)

func _on_attack_timer_timeout() -> void:
	# Refresh weapon level
	level = player.javelin_level

	# ─── WEAPON-LEVEL STATS ───────────────────────
	match level:
		1:
			paths = 1; damage = 5;  knockback_amount = 100
		2:
			paths = 2; damage = 5;  knockback_amount = 100
		3:
			paths = 3; damage = 7;  knockback_amount = 100
		4:
			paths = 3; damage = 9;  knockback_amount = 120

	# ─── APPLY PASSIVES (ONCE PER VOLLEY) ─────────
	final_damage = int(round(damage * player.damage_multiplier))
	final_speed  = speed * player.projectile_speed_multiplier

	# Tome → hitbox size
	var shape := collider.shape as RectangleShape2D
	if shape:
		shape.size *= (1.0 + player.spell_size)

	# Manual selection of closest enemies
	var avail = get_tree().get_nodes_in_group("enemy").duplicate()
	targets.clear()

	for i in range(paths):
		if avail.size() > 0:
			var best_idx: int = 0
			var best_dist: float = avail[0].global_position.distance_to(global_position)
			for j in range(1, avail.size()):
				var d: float = avail[j].global_position.distance_to(global_position)
				if d < best_dist:
					best_dist = d
					best_idx = j
			targets.append(avail[best_idx].global_position)
			avail.remove_at(best_idx)
		else:
			targets.append(player.global_position)

	_fire_next()

func _fire_next() -> void:
	if targets.is_empty():
		fired = false
		collider.set_deferred("disabled", true)
		sprite.texture = spr_normal
		return

	snd_attack.play()
	direction = (targets.pop_front() - global_position).normalized()
	rotation = direction.angle() + deg_to_rad(135)

	collider.set_deferred("disabled", false)
	sprite.texture = spr_attack
	fired = true

func _physics_process(delta: float) -> void:
	if fired:
		global_position += direction * final_speed * delta
		_clamp_to_screen()

func _on_body_entered(body: Node) -> void:
	if fired and body.is_in_group("enemy") and body.has_method("_on_hurt_box_hurt"):
		body._on_hurt_box_hurt(final_damage, direction, knockback_amount)

		fired = false
		collider.set_deferred("disabled", true)
		sprite.texture = spr_normal

		await get_tree().create_timer(0.1).timeout
		_fire_next()

func _clamp_to_screen() -> void:
	if not camera:
		return
	var half = viewport_size * 0.5
	var cp = camera.global_position
	global_position.x = clamp(global_position.x, cp.x - half.x, cp.x + half.x)
	global_position.y = clamp(global_position.y, cp.y - half.y, cp.y + half.y)
