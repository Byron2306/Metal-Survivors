extends Node2D

@export var spawns: Array[Resource] = []

var time = 0
var time_end = 1200
var enemy_array = []
var boss_spawned = false

var boss_resource_paths = [
	"res://Enemy/death18.tscn",  # world.tscn boss
	"res://Enemy/glam18.tscn",
	"res://Enemy/folk18.tscn",
	"res://Enemy/prog18.tscn",
	"res://Enemy/indus18.tscn",
	"res://Enemy/nu18.tscn",
	"res://Enemy/doom18.tscn",   # level4.tscn boss
	"res://Enemy/black18.tscn",  # level2.tscn boss
	"res://Enemy/enemy18.tscn",  # level3.tscn boss
	"res://Enemy/power18.tscn"   # level5.tscn boss
	
]

@onready var timer: Timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player")

signal changetime(time)

func _ready() -> void:
	# allow cheat to find this spawner by group name
	add_to_group("enemy_spawner")

	if spawns.size() == 0:
		push_error("Spawns array is empty! Please populate in the inspector.")
	if player:
		connect("changetime", Callable(player, "change_time"))
	else:
		push_warning("Player node not found in 'player' group.")
	timer.start()

func _physics_process(_delta: float) -> void:
	if time >= time_end:
		timer.stop()

func _on_timer_timeout() -> void:
	# ————————
	# 1) EARLY EXIT if boss already spawned
	if boss_spawned:
		return

	# advance time and update UI
	time += 1
	emit_signal("changetime", time)

	if time <= time_end and spawns.size() > 0:
		# ————————
		# 2) Handle boss spawn at t == 1180
		if time == 1180 and not boss_spawned:
			for spawn in spawns:
				var enemy_scene = spawn.get("enemy") as PackedScene
				if enemy_scene and enemy_scene.resource_path in boss_resource_paths:
					var boss = enemy_scene.instantiate()
					apply_enemy_scaling(boss, time)
					enemy_array.append(boss)
					add_child(boss)
					boss.global_position = get_random_position()

					if boss.has_signal("boss_defeated"):
						boss.boss_defeated.connect(player._on_boss_defeated)
						print("Connected boss_defeated signal for boss:", enemy_scene.resource_path)

					boss_spawned = true
					print("Boss spawned:", enemy_scene.resource_path, "at time:", time)

					# ————————
					# 3) RETURN to stop any further spawning in this tick
					return

		# ————————
		# 4) Spawn regular enemies
		for spawn in spawns:
			if spawn is Resource:
				var time_start = spawn.get("time_start") as int
				var time_end_spawn = spawn.get("time_end") as int
				var enemy_num = spawn.get("enemy_num") as int
				var enemy_spawn_delay = spawn.get("enemy_spawn_delay") as float
				var enemy_scene = spawn.get("enemy") as PackedScene
				var spawn_delay_counter = spawn.get("spawn_delay_counter") as int

				# skip any boss‐type if we've already spawned the boss
				if boss_spawned and enemy_scene and enemy_scene.resource_path in boss_resource_paths:
					continue

				if enemy_scene and time >= time_start and time <= time_end_spawn:
					if spawn_delay_counter < enemy_spawn_delay:
						spawn.set("spawn_delay_counter", spawn_delay_counter + 1)
					else:
						spawn.set("spawn_delay_counter", 0)
						var counter = 0
						while counter < enemy_num:
							var enemy = enemy_scene.instantiate()
							apply_enemy_scaling(enemy, time)
							enemy_array.append(enemy)
							add_child(enemy)
							enemy.global_position = get_random_position()
							print("Spawned enemy:", enemy_scene.resource_path, "at time:", time)
							counter += 1

func apply_enemy_scaling(enemy: Node, current_time: int) -> void:
	# Base scaling: 1.0 → 3.0 over 0–1200s
	var scaling_factor =1.0 + (current_time / 1200.0) * 3.0

	enemy.hp = int(enemy.hp * scaling_factor)
	enemy.enemy_damage = int(enemy.enemy_damage * scaling_factor)
	enemy.movement_speed = enemy.movement_speed * min(scaling_factor, 1.5)
	enemy.experience = int(enemy.experience * scaling_factor)

	# extra buff for the boss at/after 1180
	if current_time >= 1180 and enemy.is_in_group("enemy"):
		enemy.hp = int(enemy.hp * 1.5)
		enemy.enemy_damage = int(enemy.enemy_damage * 1.3)
		enemy.experience = int(enemy.experience * 2.0)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var side = ["up", "down", "right", "left"].pick_random()
	var a = Vector2()
	var b = Vector2()

	match side:
		"up":
			a = top_left; b = top_right
		"down":
			a = bottom_left; b = bottom_right
		"right":
			a = top_right; b = bottom_right
		"left":
			a = top_left; b = bottom_left

	return Vector2(
		randf_range(a.x, b.x),
		randf_range(a.y, b.y)
	)

func _on_enemy_remove_from_array(object: Node) -> void:
	enemy_array.erase(object)
