extends Node2D

var level: int = 1
var damage: int = 2
var tick_speed: float = 1.0
var aura_size: float = 114.039
var frame: int = 0
var max_frames: int = 42
var is_animating: bool = false
var hits: int = 0
var enemies_in_range: Array = []

@onready var amp_sprite = $AmpSprite
@onready var wave_sprite = $AmpWaveSprite
@onready var animation_timer = $AnimationTimer
@onready var damage_timer = $DamageTimer
@onready var area_2d = $Area2D

func _ready():
	# Start with amp.png visible
	amp_sprite.visible = true
	wave_sprite.visible = false
	# Update stats based on level
	update_stats()
	# Debug: Print initial setup
	print("🔊 [AMP DEBUG] AmpWave initialized at position: ", global_position)
	print("🔊 [AMP DEBUG] Collision layer: ", area_2d.collision_layer, " mask: ", area_2d.collision_mask)
	print("🔊 [AMP DEBUG] Damage: ", damage, " Tick speed: ", tick_speed, " Aura size: ", aura_size, " Level: ", level)
	print("🔊 [AMP DEBUG] Area2D monitoring: ", area_2d.monitoring, " monitorable: ", area_2d.monitorable)
	# Start damage timer
	damage_timer.start()
	# Wait briefly before starting animation
	await get_tree().create_timer(0.5).timeout
	start_animation()

func start_animation():
	is_animating = true
	amp_sprite.visible = true
	wave_sprite.visible = true
	wave_sprite.frame = 0
	animation_timer.start()
	print("🔊 [AMP DEBUG] AmpWave animation started")

func _on_AnimationTimer_timeout():
	if frame < max_frames:
		wave_sprite.frame = frame
		frame += 1
		animation_timer.start()
	else:
		# Animation complete, remove the node
		print("🔊 [AMP DEBUG] AmpWave animation complete, hits: ", hits, " queue_free")
		queue_free()

func _on_damage_timer_timeout():
	print("🔊 [AMP DEBUG] Damage tick, enemies in range: ", enemies_in_range.size())
	for enemy in enemies_in_range:
		if enemy and enemy.has_method("_on_hurt_box_hurt"):
			var dir = (enemy.global_position - global_position).normalized()
			print("🔊 [AMP DEBUG] Applying damage: ", damage, " to enemy: ", enemy.name)
			enemy._on_hurt_box_hurt(damage, dir, 0)
			hits += 1
			print("🔊 [AMP DEBUG] Hit registered, total hits: ", hits)

func _on_body_entered(body: Node) -> void:
	print("🔊 [AMP DEBUG] AmpWave collided with ", body.name, ", body groups=", body.get_groups())
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)
		print("🔊 [AMP DEBUG] Added enemy to range: ", body.name, ", total in range: ", enemies_in_range.size())
	else:
		print("🔊 [AMP DEBUG] Body not in enemy group")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)
		print("🔊 [AMP DEBUG] Removed enemy from range: ", body.name, ", total in range: ", enemies_in_range.size())

func update_stats():
	print("🔊 [AMP DEBUG] Updating stats for level: ", level)
	match level:
		1:
			damage = 2
			tick_speed = 1.0
			aura_size = 114.039
		2:
			damage = 3
			tick_speed = 0.8
			aura_size = 150.0
		3:
			damage = 4
			tick_speed = 0.6
			aura_size = 175.0
		4:
			damage = 5
			tick_speed = 0.4
			aura_size = 200.0

	area_2d.get_node("CollisionShape2D").shape.radius = aura_size
	damage_timer.wait_time = tick_speed
	print("🔊 [AMP DEBUG] Updated damage: ", damage, " tick speed: ", tick_speed, " aura size: ", aura_size)
