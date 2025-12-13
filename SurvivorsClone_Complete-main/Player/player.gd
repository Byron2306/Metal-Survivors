extends CharacterBody2D

var movement_speed = 60.0
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP
var time = 0

var experience = 0
var experience_level = 1
var collected_experience = 0

const AXE_EXTRA_DELAY : float = 0.1   # gap after each swing, tweak as needed
const AXE_SPAWN_OFFSET : Vector2 = Vector2(0, -40)  # raise axe 40px above player
# Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var metalSpike = preload("res://Player/Attack/metal_spike.tscn")
var mosh_projectile_scene = preload("res://Player/Attack/mosh_projectile.tscn")
var pentagram = preload("res://Player/Attack/pentagram.tscn")
var ice_spikes = preload("res://Player/Attack/ice_spikes.tscn")
var beer = preload("res://Player/Attack/beer.tscn")
# Razor Picks projectile scene
@export var razor_pick_scene: PackedScene = preload("res://Player/Attack/razor_pick.tscn")
@export var runeAxe_scene: PackedScene = preload("res://Player/Attack/rune_axe.tscn")
@export var treble_scene: PackedScene = preload("res://Player/Attack/treble.tscn")
@export var bass_scene: PackedScene = preload("res://Player/Attack/bass.tscn")
@export var amp_wave_scene: PackedScene = preload("res://Player/Attack/amp_wave.tscn")
@export var corpse_rain_scene: PackedScene = preload("res://Player/Attack/corpse_rain.tscn")

# Attack Nodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")
@onready var moshTimer = get_node("%MoshTimer")
@onready var moshAttackTimer = get_node("%MoshAttackTimer")
@onready var pentagramTimer = get_node("%PentagramTimer")
@onready var pentagramAttackTimer = get_node("%PentagramAttackTimer")
@onready var iceSpikesTimer = get_node("%IceSpikesTimer")
@onready var iceSpikesAttackTimer = get_node("%IceSpikesAttackTimer")
@onready var beerTimer = get_node("%BeerTimer")
@onready var beerAttackTimer = get_node("%BeerAttackTimer")
@onready var RazorTimer: Timer        = $RazorTimer
@onready var RazorAttackTimer: Timer  = $RazorAttackTimer
@onready var RuneAxeTimer       : Timer = $RuneAxeTimer
@onready var RuneAxeAttackTimer : Timer = $RuneAxeAttackTimer
@onready var TrebleTimer: Timer = $TrebleTimer
@onready var TrebleAttackTimer: Timer = $TrebleAttackTimer
@onready var BassTimer: Timer = $BassTimer
@onready var BassAttackTimer: Timer = $BassAttackTimer
@onready var AmpWaveTimer: Timer = $AmpWaveTimer
@onready var AmpWaveAttackTimer: Timer = $AmpWaveAttackTimer
@onready var CorpseRainTimer: Timer = $CorpseRainTimer
@onready var CorpseRainAttackTimer: Timer = $CorpseRainAttackTimer
@onready var camera2d = get_node("Camera2D")

# How many volleys we have queued
var razor_ammo: int = 0
# Upgrades
var collected_upgrades = []
var upgrade_options = []
var projectiles = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0

var runeAxe_level: int = 0
var runeAxe_slices: int = 0
var runeAxe_volley_delay: float = 0.7   # time between each slice in the volley

# IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0

# Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

# Javelin
var javelin_ammo = 0
var javelin_level = 0

# Metal Spike
var metalSpike_ammo = 0
var metalSpike_baseammo = 0
var metalSpike_attackspeed = 2.0
var metalSpike_level = 0
var metalSpike_instances = []
var metalSpike_orbiter = metalSpike.instantiate()
var orbit_radius: float = 50

# Mosh Projectile
var mosh_ammo = 0
var mosh_baseammo = 0
var mosh_attackspeed = 2.0
var mosh_level = 0

# Pentagram
var pentagram_ammo = 0
var pentagram_baseammo = 0
var pentagram_attackspeed = 1.0
var pentagram_level = 0
var pentagram_instance = null

# Ice Spikes
var iceSpikes_ammo = 0
var iceSpikes_baseammo = 0
var iceSpikes_attackspeed = 3.0
var iceSpikes_level = 0

# Beer
var beer_ammo = 0
var beer_baseammo = 0
var beer_attackspeed = 2.0
var beer_level = 0

var treble_level: int = 0
var treble_ammo: int = 0
var treble_baseammo: int = 3
var treble_attackspeed: float = 2.0
var treble_damage: int = 2
var treble_speed: float = 150.0

var bass_level: int = 0
var bass_ammo: int = 0
var bass_baseammo: int = 3
var bass_attackspeed: float = 2.0
var bass_damage: int = 2
var bass_speed: float = 150.0

var amp_wave_level: int = 0
var amp_wave_ammo: int = 0
var amp_wave_baseammo: int = 1
var amp_wave_attackspeed: float = 7.0

var corpse_rain_level: int = 0
var corpse_rain_ammo: int = 0
var corpse_rain_baseammo: int = 5  # Always 5 sprites per volley
var corpse_rain_attackspeed: float = 2.0
var corpse_rain_damage: int = 2

# Razor Picks
var razor_level: int = 0
var razor_picks_per_volley: int = 0
var razor_volley_delay: float = 0.0  # Delay between picks in a volley
# Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

# GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")
@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

const RazorPickScene = preload("res://Player/Attack/razor_pick.tscn")
# Signal
signal playerdeath

func _ready() -> void:
	# Initialize all timers at the start to avoid conflicts
	if iceSpearTimer:
		iceSpearTimer.wait_time = icespear_attackspeed
		iceSpearTimer.stop()
	if iceSpearAttackTimer:
		iceSpearAttackTimer.wait_time = 0.075
		iceSpearAttackTimer.stop()
	if tornadoTimer:
		tornadoTimer.wait_time = tornado_attackspeed
		tornadoTimer.stop()
	if tornadoAttackTimer:
		tornadoAttackTimer.wait_time = 0.2
		tornadoAttackTimer.stop()
	if moshTimer:
		moshTimer.wait_time = mosh_attackspeed
		moshTimer.stop()
	if moshAttackTimer:
		moshAttackTimer.wait_time = mosh_attackspeed
		moshAttackTimer.stop()
	if pentagramTimer:
		pentagramTimer.wait_time = pentagram_attackspeed
		pentagramTimer.stop()
	if pentagramAttackTimer:
		pentagramAttackTimer.wait_time = pentagram_attackspeed
		pentagramAttackTimer.stop()
	if iceSpikesTimer:
		iceSpikesTimer.wait_time = iceSpikes_attackspeed
		iceSpikesTimer.stop()
	if iceSpikesAttackTimer:
		iceSpikesAttackTimer.wait_time = 0.1
		iceSpikesAttackTimer.stop()
	if beerTimer:
		beerTimer.wait_time = beer_attackspeed
		beerTimer.stop()
	if beerAttackTimer:
		beerAttackTimer.wait_time = 0.1
		beerAttackTimer.stop()
	if RazorTimer:
		RazorTimer.wait_time = 1.0
		RazorTimer.stop()
	if RazorAttackTimer:
		RazorAttackTimer.wait_time = 0.1
		RazorAttackTimer.stop()
	if RuneAxeTimer:
		RuneAxeTimer.wait_time = 1.5
		RuneAxeTimer.stop()
	if RuneAxeAttackTimer:
		RuneAxeAttackTimer.wait_time = runeAxe_volley_delay
		RuneAxeAttackTimer.stop()
	if TrebleTimer:
		TrebleTimer.wait_time = treble_attackspeed
		TrebleTimer.stop()
		#print("🔊 [TREBLE DEBUG] TrebleTimer initialized with wait_time=", treble_attackspeed, ", stopped=", TrebleTimer.is_stopped(), ", valid=", is_instance_valid(TrebleTimer))
	else:
		push_error("TrebleTimer is null in _ready!")
	if TrebleAttackTimer:
		TrebleAttackTimer.wait_time = 0.1
		TrebleAttackTimer.stop()
		#print("🔊 [TREBLE DEBUG] TrebleAttackTimer initialized with wait_time=0.1, stopped=", TrebleAttackTimer.is_stopped(), ", valid=", is_instance_valid(TrebleAttackTimer))
	else:
		push_error("TrebleAttackTimer is null in _ready!")
	if BassTimer:
		BassTimer.wait_time = bass_attackspeed
		BassTimer.stop()
		#print("🔊 [BASS DEBUG] BassTimer initialized with wait_time=", bass_attackspeed, ", stopped=", BassTimer.is_stopped(), ", valid=", is_instance_valid(BassTimer))
	else:
		push_error("BassTimer is null in _ready!")
	if BassAttackTimer:
		BassAttackTimer.wait_time = 0.1
		BassAttackTimer.stop()
		#print("🔊 [BASS DEBUG] BassAttackTimer initialized with wait_time=0.1, stopped=", BassAttackTimer.is_stopped(), ", valid=", is_instance_valid(BassAttackTimer))
	else:
		push_error("BassAttackTimer is null in _ready!")
	if AmpWaveTimer:
		AmpWaveTimer.wait_time = amp_wave_attackspeed
		AmpWaveTimer.stop()
	if AmpWaveAttackTimer:
		AmpWaveAttackTimer.wait_time = 0.1
		AmpWaveAttackTimer.stop()
	if CorpseRainTimer:
		CorpseRainTimer.wait_time = corpse_rain_attackspeed
		CorpseRainTimer.stop()
		#print("💀 [CORPSE DEBUG] CorpseRainTimer initialized with wait_time=", corpse_rain_attackspeed, ", stopped=", CorpseRainTimer.is_stopped())
	else:
		push_error("CorpseRainTimer is null in _ready!")
	if CorpseRainAttackTimer:
		CorpseRainAttackTimer.wait_time = 0.1
		CorpseRainAttackTimer.stop()
		#print("💀 [CORPSE DEBUG] CorpseRainAttackTimer initialized with wait_time=0.1, stopped=", CorpseRainAttackTimer.is_stopped())
	else:
		push_error("CorpseRainAttackTimer is null in _ready!")
		
	# Set up character based on Global.selected_character
	if Global.selected_character:
		sprite.texture = load(Global.selected_character)
		if Global.selected_character == "res://Textures/Player/axel_sprite.png":
			sprite.scale = Vector2(0.5, 0.5)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("mosh1")
			#print("Starting weapon for Axel: mosh1")
		elif Global.selected_character == "res://Textures/Player/lucias_sprite.png":
			sprite.scale = Vector2(0.128, 0.128)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("iceSpikes1")
			#print("Starting weapon for Lucias: iceSpikes1")
		elif Global.selected_character == "res://Textures/Player/brutus_sprite.png":
			sprite.scale = Vector2(0.16, 0.11)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("beer1")
			#print("Starting weapon for Brutus: beer1")
		elif Global.selected_character == "res://Textures/Player/aiden_sprite.png":
			sprite.scale = Vector2(0.128, 0.128)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("icespear1")
			#print("Starting weapon for Aiden: icespear1")
		elif Global.selected_character == "res://Textures/Player/doug_sprite.png":
			sprite.scale = Vector2(0.116, 0.11)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("pentagram1")
			#print("Starting weapon for Doug: pentagram1")
		elif Global.selected_character == "res://Textures/Player/jesse_sprite.png":
			sprite.scale = Vector2(0.128, 0.134)
			sprite.hframes = 6
			sprite.vframes = 1
			sprite.position = Vector2(0, -5)
			upgrade_character("razorpick1")
			#print("Starting weapon for Jesse: razorpick1")
		elif Global.selected_character == "res://Textures/Player/malcolm_sprite.png":
			sprite.scale = Vector2(0.12, 0.12)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("runeaxe1")
			#print("Starting weapon for Malcolm: runeaxe1, runeAxe_level=", runeAxe_level, ", RuneAxeTimer running=", !RuneAxeTimer.is_stopped())
		elif Global.selected_character == "res://Textures/Player/xavier_sprite.png":
			sprite.scale = Vector2(0.12, 0.12)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("treble1")
			upgrade_character("bass1")
			#print("🔊 [TREBLE DEBUG] Starting weapon for Xavier: treble1, treble_level=", treble_level, ", TrebleTimer running=", !TrebleTimer.is_stopped())
			#print("🔊 [BASS DEBUG] Starting weapon for Xavier: bass1, bass_level=", bass_level, ", BassTimer running=", !BassTimer.is_stopped())
		elif Global.selected_character == "res://Textures/Player/stryker_sprite.png":
			sprite.scale = Vector2(0.12, 0.12)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("ampwave1")
			#print("Starting weapon for Stryker: ampwave1")
		elif Global.selected_character == "res://Textures/Player/kyle_sprite.png":
			sprite.scale = Vector2(0.12, 0.12)
			sprite.hframes = 6
			sprite.vframes = 1
			upgrade_character("corpse_rain1")
			#print("Starting weapon for Kyle: corpse_rain1")
		sprite.frame = clamp(sprite.frame, 0, sprite.hframes * sprite.vframes - 1)
		#print("Player sprite set to:", Global.selected_character, "with scale:", sprite.scale, "position:", sprite.position, "hframes:", sprite.hframes, "vframes:", sprite.vframes)
	else:
		sprite.texture = load("res://Textures/Player/axel_sprite.png")
		sprite.scale = Vector2(0.5, 0.5)
		sprite.hframes = 6
		sprite.vframes = 1
		sprite.frame = clamp(sprite.frame, 0, sprite.hframes * sprite.vframes - 1)
		upgrade_character("mosh1")
		#print("Player sprite defaulted to: res://Textures/Player/axel_sprite.png with scale:", sprite.scale, "hframes:", sprite.hframes, "vframes:", sprite.vframes, "Starting weapon: mosh1")

	# Connect boss_defeated signals for existing enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.has_signal("boss_defeated") and not enemy.boss_defeated.is_connected(_on_boss_defeated):
			enemy.boss_defeated.connect(_on_boss_defeated)
			#print("Connected boss_defeated signal for enemy in _ready: ", enemy.scene_file_path)

	var spawner = get_tree().get_first_node_in_group("enemy_spawner")
	if spawner:
		spawner.changetime.connect(_on_spawner_changetime)
	else:
		push_error("Enemy spawner not found in 'enemy_spawner' group!")

	# Start attacks for active weapons
	attack()
	#print("attack() called, RuneAxeTimer running=", !RuneAxeTimer.is_stopped())

	set_expbar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0, 0, 0)

	if deathPanel:
		deathPanel.z_index = 10
	else:
		push_error("DeathPanel not found!")

	# Add fallback timer to check boss signal connections
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.connect("timeout", _check_boss_signal)
	add_child(timer)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		#print("Cheat activated: Spawning boss immediately…")
		var spawner = get_tree().get_first_node_in_group("enemy_spawner")
		if spawner and not spawner.boss_spawned:
			# 1) Stop the real timer so it won’t overwrite us
			spawner.timer.stop()
			# 2) Set just before the trigger so next tick == 1180
			spawner.time = 1179
			# 3) Manually fire the timeout once → exactly one boss
			spawner._on_timer_timeout()
			# 4) Update your UI
			change_time(spawner.time)

		# Beer damage boost
		if beer_level > 0:
			beer_baseammo += 1
			for node in get_tree().get_nodes_in_group("beer"):
				if node.has_method("increase_damage"):
					node.increase_damage(100)
			var beer_scene = beer.instantiate()
			if beer_scene.has_method("increase_damage"):
				beer_scene.increase_damage(100)
			#print("Beer damage increased by 100")
		else:
			#print("Beer weapon not active, activating beer1")
			upgrade_character("beer1")


func _check_boss_signal():
	if time >= 1180:
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			if enemy.scene_file_path in [
				"res://Enemy/death18.tscn",
				"res://Enemy/black18.tscn",
				"res://Enemy/enemy18.tscn",
				"res://Enemy/power18.tscn"
			] and enemy.has_signal("boss_defeated") and not enemy.boss_defeated.is_connected(_on_boss_defeated):
				enemy.boss_defeated.connect(_on_boss_defeated)
				#print("Fallback: Connected boss_defeated signal for: ", enemy.scene_file_path)


func _physics_process(delta):
	movement()
	if camera2d:
		camera2d.global_position = global_position


func movement() -> void:
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = false
	elif mov.x < 0:
		sprite.flip_h = true

	if mov != Vector2.ZERO:
		last_movement = mov
	else:
		if last_movement == Vector2.ZERO:  # Set default facing if no movement
			last_movement = Vector2.UP    # Default to facing up when idle

	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			var max_frames = sprite.hframes * sprite.vframes - 1
			if sprite.frame >= max_frames:
				sprite.frame = 0
			else:
				sprite.frame = clamp(sprite.frame + 1, 0, max_frames)
			#print("Sprite frame set to: ", sprite.frame, " max_frames: ", max_frames)
			walkTimer.start()

	velocity = mov.normalized() * movement_speed
	move_and_slide()


func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1 - spell_cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1 - spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()
	if metalSpike_level > 0:
		spawn_metalSpike()
	if mosh_level > 0 and moshTimer:
		moshTimer.wait_time = mosh_attackspeed * (1 - spell_cooldown)
		if moshTimer.is_stopped():
			moshTimer.start()
	elif moshTimer and moshAttackTimer:
		moshTimer.stop()
		moshAttackTimer.stop()
	if pentagram_level > 0 and pentagramTimer:
		pentagramTimer.wait_time = pentagram_attackspeed * (1 - spell_cooldown)
		if pentagramTimer.is_stopped():
			pentagramTimer.start()
	elif pentagramTimer and pentagramAttackTimer:
		pentagramTimer.stop()
		pentagramAttackTimer.stop()
	if iceSpikes_level > 0 and iceSpikesTimer:
		iceSpikesTimer.wait_time = iceSpikes_attackspeed * (1 - spell_cooldown)
		if iceSpikesTimer.is_stopped():
			iceSpikesTimer.start()
	elif iceSpikesTimer and iceSpikesAttackTimer:
		iceSpikesTimer.stop()
		iceSpikesAttackTimer.stop()
	if beer_level > 0 and beerTimer:
		beerTimer.wait_time = beer_attackspeed * (1 - spell_cooldown)
		if beerTimer.is_stopped():
			beerTimer.start()
	elif beerTimer and beerAttackTimer:
		beerTimer.stop()
		beerAttackTimer.stop()
	if razor_level > 0 and RazorTimer:
		# ensure the volley‐starter is running
		if RazorTimer.is_stopped():
			RazorTimer.start()
	elif RazorTimer and RazorAttackTimer:
		# weapon locked or dropped—stop everything
		RazorTimer.stop()
		RazorAttackTimer.stop()
	if runeAxe_level > 0:
		if RuneAxeTimer.is_stopped():
			RuneAxeTimer.start()
	else:
		RuneAxeTimer.stop()
		RuneAxeAttackTimer.stop()
	if treble_level > 0 and TrebleTimer:
		TrebleTimer.wait_time = treble_attackspeed * (1 - spell_cooldown)
		if TrebleTimer.is_stopped():
			TrebleTimer.start()
			#print("🔊 [TREBLE DEBUG] attack() starting TrebleTimer, treble_level=", treble_level, ", wait_time=", TrebleTimer.wait_time, ", running=", !TrebleTimer.is_stopped())
	elif TrebleTimer and TrebleAttackTimer:
		TrebleTimer.stop()
		TrebleAttackTimer.stop()
		#print("🔊 [TREBLE DEBUG] attack() stopping TrebleTimer and TrebleAttackTimer, treble_level=", treble_level)
	if bass_level > 0 and BassTimer:
		BassTimer.wait_time = bass_attackspeed * (1 - spell_cooldown)
		if BassTimer.is_stopped():
			BassTimer.start()
			#print("🔊 [BASS DEBUG] attack() starting BassTimer, bass_level=", bass_level, ", wait_time=", BassTimer.wait_time, ", running=", !BassTimer.is_stopped())
	elif BassTimer and BassAttackTimer:
		BassTimer.stop()
		BassAttackTimer.stop()
		#print("🔊 [BASS DEBUG] attack() stopping BassTimer and BassAttackTimer, bass_level=", bass_level)
	if amp_wave_level > 0 and AmpWaveTimer:
		AmpWaveTimer.wait_time = amp_wave_attackspeed * (1 - spell_cooldown)
		if AmpWaveTimer.is_stopped():
			AmpWaveTimer.start()
	if corpse_rain_level > 0 and CorpseRainTimer:
		CorpseRainTimer.wait_time = corpse_rain_attackspeed * (1 - spell_cooldown)
		if CorpseRainTimer.is_stopped():
			CorpseRainTimer.start()
			#print("💀 [CORPSE DEBUG] attack() starting CorpseRainTimer, corpse_rain_level=", corpse_rain_level, ", wait_time=", CorpseRainTimer.wait_time)
	elif CorpseRainTimer and CorpseRainAttackTimer:
		CorpseRainTimer.stop()
		CorpseRainAttackTimer.stop()
		#print("💀 [CORPSE DEBUG] attack() stopping CorpseRainTimer and CorpseRainAttackTimer, corpse_rain_level=", corpse_rain_level)

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		death()


func _on_ice_spear_timer_timeout():
	icespear_ammo = 1 + additional_attacks
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()


func _on_tornado_timer_timeout():
	# instead of refilling tornado_ammo, just fire
	spawn_tornado()
	# restart the cooldown timer
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	# no longer needed—stop using this
	# just disable it so it doesn't fire again
	tornadoAttackTimer.stop()


func _on_pentagram_timer_timeout():
	if pentagram_level > 0:
		if pentagram_instance == null:
			pentagram_instance = pentagram.instantiate()
			pentagram_instance.level = pentagram_level
			get_parent().add_child(pentagram_instance)
		else:
			pentagram_instance.level = pentagram_level
			pentagram_instance.update_stats()
		pentagramAttackTimer.start()


func _on_pentagram_attack_timer_timeout():
	pass


func _on_ice_spikes_timer_timeout():
	iceSpikes_ammo += iceSpikes_baseammo + additional_attacks
	iceSpikesAttackTimer.start()


func _on_ice_spikes_attack_timer_timeout():
	if iceSpikes_ammo > 0:
		var ice_spikes_attack = ice_spikes.instantiate()
		var viewport_rect = get_viewport_rect()
		var camera_pos = camera2d.global_position if camera2d else global_position
		var spawn_pos = Vector2(
			camera_pos.x - viewport_rect.size.x / 2 + randf() * viewport_rect.size.x,
			camera_pos.y - viewport_rect.size.y / 2 + randf() * viewport_rect.size.y
		)
		ice_spikes_attack.global_position = spawn_pos
		ice_spikes_attack.level = iceSpikes_level
		get_parent().add_child(ice_spikes_attack)
		iceSpikes_ammo -= 1
		if iceSpikes_ammo > 0:
			iceSpikesAttackTimer.start()
		else:
			iceSpikesAttackTimer.stop()


func _on_beer_timer_timeout():
	beer_ammo += beer_baseammo + additional_attacks
	beerAttackTimer.start()


func _on_beer_attack_timer_timeout():
	if beer_ammo > 0:
		var beer_attack = beer.instantiate()
		beer_attack.global_position = global_position + Vector2(0, -10)
		beer_attack.level = beer_level
		get_parent().add_child(beer_attack)
		beer_ammo -= 1
		if beer_ammo > 0:
			beerAttackTimer.start()
		else:
			beerAttackTimer.stop()

func _spawn_rune_axe_slice(dir: int) -> void:
	# 1) Instantiate the rune‐axe slice
	var slice = runeAxe_scene.instantiate() as Area2D

	# 2) Parent it under the Player so its position is local to you
	add_child(slice)

	# 3) Place it directly above the head
	slice.position = AXE_SPAWN_OFFSET

	# 4) Configure damage
	slice.damage = 2 + runeAxe_level

	# 5) Kick off the orbiting swing in the requested direction
	slice.start_swing(dir)

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()

func spawn_metalSpike():
	# 1) Clear out any existing orbiters
	for spike in metalSpike_instances:
		if is_instance_valid(spike):
			spike.queue_free()
	metalSpike_instances.clear()

	# 2) Determine the base count by weapon level:
	#    level 1 → 1 spike,  level 2 & 3 → 2 spikes,  level 4 → 3 spikes
	var base_count: int = 1
	if metalSpike_level >= 2:
		base_count = 2
	if metalSpike_level >= 4:
		base_count = 3

	# 3) Add ring bonus
	var total_spikes: int = base_count + additional_attacks

	# 4) If we still have only one, just spawn that one
	if total_spikes <= 1:
		total_spikes = 1

	# 5) Compute equal spacing
	var angle_step: float = TAU / float(total_spikes)

	# 6) Instantiate all spikes
	for i in range(total_spikes):
		var spike = metalSpike.instantiate() as Node2D
		spike.level = metalSpike_level
		spike.angle = angle_step * i
		spike.orbit_radius = orbit_radius
		add_child(spike)
		metalSpike_instances.append(spike)

func spawn_tornado():
	# ——— 1) Cap total active tornado skulls ———
	var active = get_tree().get_nodes_in_group("enemy_tornado").size()
	if active >= 8:
		return

	# ——— 2) Determine how many to spawn based on level & ring bonus ———
	var base_count: int = 1
	if tornado_level >= 2:
		base_count = 3
	var total: int = base_count + additional_attacks
	if total <= 0:
		return

	# ——— 3) Spawn each skull with our new parameters ———
	var base_angle = last_movement.angle()
	for i in range(total):
		var tw = tornado.instantiate() as Area2D

		# position & stats
		tw.global_position = global_position
		tw.level           = tornado_level
		tw.last_movement   = last_movement

		# new lifetime & homing limits
		tw.max_time_alive = 5.0
		tw.homing_radius  = 300.0

		# tag it so we can count/cull it globally
		tw.add_to_group("enemy_tornado")

		# — your original direction logic ——
		var dir_vec: Vector2
		if tornado_level == 4:
			# spiral 360°
			var theta = TAU * float(i) / float(total)
			dir_vec = Vector2(cos(theta), sin(theta))
		else:
			# ±10° spread cone
			var t: float = float(i) / float(total - 1) if total > 1 else 0.5
			var jitter = -10.0 + 20.0 * t
			var theta = base_angle + deg_to_rad(jitter)
			dir_vec = Vector2(cos(theta), sin(theta))
		tw.angle = dir_vec

		add_child(tw)


func _on_MoshTimer_timeout():
	if moshTimer and moshAttackTimer:
		#print("🌀 [DEBUG] MoshTimer timeout, refilling ammo to ", mosh_baseammo + additional_attacks)
		mosh_ammo = mosh_baseammo + additional_attacks
		if mosh_ammo > 0 and moshAttackTimer.is_stopped():
			moshAttackTimer.start()
	else:
		push_error("MoshTimer or MoshAttackTimer is null in _on_MoshTimer_timeout")


func _on_MoshAttackTimer_timeout():
	if moshAttackTimer:
		#print("🌀 [DEBUG] MoshAttackTimer timeout, ammo=", mosh_ammo)
		if mosh_ammo > 0:
			spawn_mosh()
			mosh_ammo -= 1
			if mosh_ammo > 0:
				moshAttackTimer.start()
			else:
				moshAttackTimer.stop()
	else:
		push_error("MoshAttackTimer is null in _on_MoshAttackTimer_timeout")

func spawn_mosh() -> void:
	# base direction
	var base_dir = last_movement.normalized()

	if mosh_level == 4:
		# Level 4: four‐ball swirling barrage
		for i in range(4):
			var proj = mosh_projectile_scene.instantiate()
			proj.global_position = global_position
			# spread 90° apart
			proj.direction        = base_dir.rotated(i * PI * 0.5)
			proj.camera2d         = camera2d
			proj.level            = mosh_level
			get_parent().add_child(proj)
	else:
		# Levels 1–3: single ball
		var proj = mosh_projectile_scene.instantiate()
		proj.global_position = global_position
		proj.direction        = base_dir
		proj.camera2d         = camera2d
		proj.level            = mosh_level
		get_parent().add_child(proj)



func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)


func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)


func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
		
	return exp_cap


func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value


func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "offset_left", 220.0, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(levelPanel, "offset_top", 50.0, 0.2)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true


func upgrade_character(upgrade):
	var old_mosh_level = mosh_level
	var old_pentagram_level = pentagram_level
	var old_iceSpikes_level = iceSpikes_level
	var old_beer_level = beer_level
	var old_treble_level = treble_level
	var old_bass_level = bass_level
	var old_amp_wave_level = amp_wave_level
	var old_corpse_rain_level = corpse_rain_level
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4": 
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"metalSpike1":
			metalSpike_level = 1
			metalSpike_ammo = 1
		"metalSpike2":
			metalSpike_level = 2
		"metalSpike3":
			metalSpike_level = 3
		"metalSpike4":
			metalSpike_level = 4
			metalSpike_baseammo += 2
		"mosh1":
			mosh_level = 1
			mosh_baseammo += 1
			if moshTimer:
				moshTimer.start()
			else:
				push_error("MoshTimer is null in upgrade_character for mosh1")
		"mosh2":
			mosh_level = 2
			mosh_baseammo += 1
			if moshTimer:
				moshTimer.start()
			else:
				push_error("MoshTimer is null in upgrade_character for mosh2")
		"mosh3":
			mosh_level = 3
			if moshTimer:
				moshTimer.start()
			else:
				push_error("MoshTimer is null in upgrade_character for mosh3")
		"mosh4":
			mosh_level = 4
			mosh_baseammo += 2
			mosh_attackspeed = max(0.5, mosh_attackspeed - 0.2)
			if moshTimer and moshAttackTimer:
				moshTimer.wait_time = mosh_attackspeed * (1 - spell_cooldown)
				moshAttackTimer.wait_time = mosh_attackspeed
				moshTimer.start()
			else:
				push_error("MoshTimer or MoshAttackTimer is null in upgrade_character for mosh4")
		"pentagram1":
			pentagram_level = 1
			if pentagramTimer:
				pentagramTimer.start()
			else:
				push_error("PentagramTimer is null in upgrade_character for pentagram1")
		"pentagram2":
			pentagram_level = 2
			if pentagramTimer:
				pentagramTimer.start()
			else:
				push_error("PentagramTimer is null in upgrade_character for pentagram2")
		"pentagram3":
			pentagram_level = 3
			if pentagramTimer:
				pentagramTimer.start()
			else:
				push_error("PentagramTimer is null in upgrade_character for pentagram3")
		"pentagram4":
			pentagram_level = 4
			if pentagramTimer:
				pentagramTimer.start()
			else:
				push_error("PentagramTimer is null in upgrade_character for pentagram4")
		"iceSpikes1":
			iceSpikes_level = 1
			iceSpikes_baseammo += 1
			if iceSpikesTimer:
				iceSpikesTimer.start()
			else:
				push_error("IceSpikesTimer is null in upgrade_character for iceSpikes1")
		"iceSpikes2":
			iceSpikes_level = 2
			iceSpikes_baseammo += 1
			if iceSpikesTimer:
				iceSpikesTimer.start()
			else:
				push_error("IceSpikesTimer is null in upgrade_character for iceSpikes2")
		"iceSpikes3":
			iceSpikes_level = 3
			if iceSpikesTimer:
				iceSpikesTimer.start()
			else:
				push_error("IceSpikesTimer is null in upgrade_character for iceSpikes3")
		"iceSpikes4":
			iceSpikes_level = 4
			iceSpikes_baseammo += 2
			iceSpikes_attackspeed = max(0.5, iceSpikes_attackspeed - 0.5)
			if iceSpikesTimer and iceSpikesAttackTimer:
				iceSpikesTimer.wait_time = iceSpikes_attackspeed * (1 - spell_cooldown)
				iceSpikesAttackTimer.wait_time = 0.1
				iceSpikesTimer.start()
			else:
				push_error("IceSpikesTimer or IceSpikesAttackTimer is null in upgrade_character for iceSpikes4")
		"beer1":
			beer_level = 1
			beer_baseammo += 1
			if beerTimer:
				beerTimer.start()
			else:
				push_error("BeerTimer is null in upgrade_character for beer1")
		"beer2":
			beer_level = 2
			beer_baseammo += 1
			if beerTimer:
				beerTimer.start()
			else:
				push_error("BeerTimer is null in upgrade_character for beer2")
		"beer3":
			beer_level = 3
			if beerTimer:
				beerTimer.start()
			else:
				push_error("BeerTimer is null in upgrade_character for beer3")
		"beer4":
			beer_level = 4
			beer_baseammo += 2
			beer_attackspeed = max(0.5, beer_attackspeed - 0.5)
			if beerTimer and beerAttackTimer:
				beerTimer.wait_time = beer_attackspeed * (1 - spell_cooldown)
				beerAttackTimer.wait_time = 0.1
				beerTimer.start()
			else:
				push_error("BeerTimer or BeerAttackTimer is null in upgrade_character for beer4")
		"razorpick1":
			razor_level = 1
			razor_picks_per_volley = 3
			razor_volley_delay = 0.2
			RazorTimer.wait_time = 1.5
			RazorAttackTimer.wait_time = razor_volley_delay
			if RazorTimer and RazorAttackTimer:
				RazorTimer.start()
				#print("🌀 Razor Picks upgraded to level 1, RazorTimer started, picks: ", razor_picks_per_volley, " volley delay: ", razor_volley_delay)
			else:
				push_error("RazorTimer or RazorAttackTimer is null for razorpick1")
		"razorpick2":
			razor_level = 2
			razor_picks_per_volley = 4
			razor_volley_delay = 0.15
			RazorTimer.wait_time = 1.2
			RazorAttackTimer.wait_time = razor_volley_delay
			if RazorTimer and RazorAttackTimer:
				RazorTimer.start()
				#print("🌀 Razor Picks upgraded to level 2, RazorTimer started, picks: ", razor_picks_per_volley, " volley delay: ", razor_volley_delay)
			else:
				push_error("RazorTimer or RazorAttackTimer is null for razorpick2")
		"razorpick3":
			razor_level = 3
			razor_picks_per_volley = 5
			razor_volley_delay = 0.1
			RazorTimer.wait_time = 1.0
			RazorAttackTimer.wait_time = razor_volley_delay
			if RazorTimer and RazorAttackTimer:
				RazorTimer.start()
				#print("🌀 Razor Picks upgraded to level 3, RazorTimer started, picks: ", razor_picks_per_volley, " volley delay: ", razor_volley_delay)
			else:
				push_error("RazorTimer or RazorAttackTimer is null for razorpick3")
		"razorpick4":
			razor_level = 4
			razor_picks_per_volley = 6
			razor_volley_delay = 0.05
			RazorTimer.wait_time = 0.8
			RazorAttackTimer.wait_time = razor_volley_delay
			if RazorTimer and RazorAttackTimer:
				RazorTimer.start()
				#print("🌀 Razor Picks upgraded to level 4, RazorTimer started, picks: ", razor_picks_per_volley, " volley delay: ", razor_volley_delay)
			else:
				push_error("RazorTimer or RazorAttackTimer is null for razorpick4")
		"runeaxe1":
			runeAxe_level = 1
			if RuneAxeTimer and RuneAxeAttackTimer:
				RuneAxeTimer.start()
		"runeaxe2":
			runeAxe_level = 2
			if RuneAxeTimer and RuneAxeAttackTimer:
				RuneAxeTimer.start()
		"runeaxe3":
			runeAxe_level = 3
			if RuneAxeTimer and RuneAxeAttackTimer:
				RuneAxeTimer.start()
		"runeaxe4":
			runeAxe_level = 4
			if RuneAxeTimer and RuneAxeAttackTimer:
				RuneAxeTimer.start()
		"treble1":
			treble_level = 1
			treble_baseammo = 3
			if TrebleTimer and TrebleAttackTimer:
				TrebleTimer.start()
				#print("🔊 [TREBLE DEBUG] Upgraded to treble1, treble_level=", treble_level, ", baseammo=", treble_baseammo, ", TrebleTimer started, running=", !TrebleTimer.is_stopped())
			else:
				push_error("TrebleTimer or TrebleAttackTimer is null for treble1")
		"treble2":
			treble_level = 2
			treble_baseammo += 1
			treble_damage += 1
			if TrebleTimer and TrebleAttackTimer:
				TrebleTimer.start()
				#print("🔊 [TREBLE DEBUG] Upgraded to treble2, treble_level=", treble_level, ", baseammo=", treble_baseammo, ", damage=", treble_damage, ", TrebleTimer started, running=", !TrebleTimer.is_stopped())
			else:
				push_error("TrebleTimer or TrebleAttackTimer is null for treble2")
		"treble3":
			treble_level = 3
			treble_baseammo += 1
			treble_speed += 50
			if TrebleTimer and TrebleAttackTimer:
				TrebleTimer.start()
				#print("🔊 [TREBLE DEBUG] Upgraded to treble3, treble_level=", treble_level, ", baseammo=", treble_baseammo, ", speed=", treble_speed, ", TrebleTimer started, running=", !TrebleTimer.is_stopped())
			else:
				push_error("TrebleTimer or TrebleAttackTimer is null for treble3")
		"treble4":
			treble_level = 4
			treble_baseammo += 2
			treble_damage += 2
			treble_speed += 100
			if TrebleTimer and TrebleAttackTimer:
				TrebleTimer.start()
				#print("🔊 [TREBLE DEBUG] Upgraded to treble4, treble_level=", treble_level, ", baseammo=", treble_baseammo, ", damage=", treble_damage, ", speed=", treble_speed, ", TrebleTimer started, running=", !TrebleTimer.is_stopped())
			else:
				push_error("TrebleTimer or TrebleAttackTimer is null for treble4")
		"bass1":
			bass_level = 1
			bass_baseammo = 3
			if BassTimer and BassAttackTimer:
				BassTimer.start()
				#print("🔊 [BASS DEBUG] Upgraded to bass1, bass_level=", bass_level, ", baseammo=", bass_baseammo, ", BassTimer started, running=", !BassTimer.is_stopped())
			else:
				push_error("BassTimer or BassAttackTimer is null for bass1")
		"bass2":
			bass_level = 2
			bass_baseammo += 1
			bass_damage += 1
			if BassTimer and BassAttackTimer:
				BassTimer.start()
				#print("🔊 [BASS DEBUG] Upgraded to bass2, bass_level=", bass_level, ", baseammo=", bass_baseammo, ", damage=", bass_damage, ", BassTimer started, running=", !BassTimer.is_stopped())
			else:
				push_error("BassTimer or BassAttackTimer is null for bass2")
		"bass3":
			bass_level = 3
			bass_baseammo += 1
			bass_speed += 50
			if BassTimer and BassAttackTimer:
				BassTimer.start()
				#print("🔊 [BASS DEBUG] Upgraded to bass3, bass_level=", bass_level, ", baseammo=", bass_baseammo, ", speed=", bass_speed, ", BassTimer started, running=", !BassTimer.is_stopped())
			else:
				push_error("BassTimer or BassAttackTimer is null for bass3")
		"bass4":
			bass_level = 4
			bass_baseammo += 2
			bass_damage += 2
			bass_speed += 100
			if BassTimer and BassAttackTimer:
				BassTimer.start()
				#print("🔊 [BASS DEBUG] Upgraded to bass4, bass_level=", bass_level, ", baseammo=", bass_baseammo, ", damage=", bass_damage, ", speed=", bass_speed, ", BassTimer started, running=", !BassTimer.is_stopped())
			else:
				push_error("BassTimer or BassAttackTimer is null for bass4")
		"ampwave1":
			amp_wave_level = 1
			amp_wave_baseammo = 1
			if AmpWaveTimer and AmpWaveAttackTimer:
				AmpWaveTimer.start()
				#print("🔊 [AMP DEBUG] Upgraded to ampwave1, amp_wave_level=", amp_wave_level, ", baseammo=", amp_wave_baseammo, ", AmpWaveTimer started, running=", !AmpWaveTimer.is_stopped())
			else:
				push_error("AmpWaveTimer or AmpWaveAttackTimer is null for ampwave1")
		"ampwave2":
			amp_wave_level = 2
			amp_wave_baseammo = 1
			if AmpWaveTimer and AmpWaveAttackTimer:
				AmpWaveTimer.start()
				#print("🔊 [AMP DEBUG] Upgraded to ampwave2, amp_wave_level=", amp_wave_level, ", baseammo=", amp_wave_baseammo, ", AmpWaveTimer started, running=", !AmpWaveTimer.is_stopped())
			else:
				push_error("AmpWaveTimer or AmpWaveAttackTimer is null for ampwave2")
		"ampwave3":
			amp_wave_level = 3
			amp_wave_baseammo = 1
			if AmpWaveTimer and AmpWaveAttackTimer:
				AmpWaveTimer.start()
				#print("🔊 [AMP DEBUG] Upgraded to ampwave3, amp_wave_level=", amp_wave_level, ", baseammo=", amp_wave_baseammo, ", AmpWaveTimer started, running=", !AmpWaveTimer.is_stopped())
			else:
				push_error("AmpWaveTimer or AmpWaveAttackTimer is null for ampwave3")
		"ampwave4":
			amp_wave_level = 4
			amp_wave_baseammo = 1
			if AmpWaveTimer and AmpWaveAttackTimer:
				AmpWaveTimer.start()
				#print("🔊 [AMP DEBUG] Upgraded to ampwave4, amp_wave_level=", amp_wave_level, ", baseammo=", amp_wave_baseammo, ", AmpWaveTimer started, running=", !AmpWaveTimer.is_stopped())
			else:
				push_error("AmpWaveTimer or AmpWaveAttackTimer is null for ampwave4")
		"corpse_rain1":
			corpse_rain_level = 1
			corpse_rain_baseammo = 5
			corpse_rain_attackspeed = 2.0
			corpse_rain_damage = 2
			if CorpseRainTimer and CorpseRainAttackTimer:
				CorpseRainTimer.start()
				#print("💀 [CORPSE DEBUG] Upgraded to corpse_rain1, corpse_rain_level=", corpse_rain_level, ", baseammo=", corpse_rain_baseammo, ", attackspeed=", corpse_rain_attackspeed, ", damage=", corpse_rain_damage, ", CorpseRainTimer started, running=", !CorpseRainTimer.is_stopped())
			else:
				push_error("CorpseRainTimer or CorpseRainAttackTimer is null for corpse_rain1")
		"corpse_rain2":
			corpse_rain_level = 2
			corpse_rain_baseammo = 5
			corpse_rain_attackspeed = 1.8
			corpse_rain_damage = 3
			if CorpseRainTimer and CorpseRainAttackTimer:
				CorpseRainTimer.wait_time = corpse_rain_attackspeed * (1 - spell_cooldown)
				CorpseRainTimer.start()
				#print("💀 [CORPSE DEBUG] Upgraded to corpse_rain2, corpse_rain_level=", corpse_rain_level, ", baseammo=", corpse_rain_baseammo, ", attackspeed=", corpse_rain_attackspeed, ", damage=", corpse_rain_damage, ", CorpseRainTimer started, running=", !CorpseRainTimer.is_stopped())
			else:
				push_error("CorpseRainTimer or CorpseRainAttackTimer is null for corpse_rain2")
		"corpse_rain3":
			corpse_rain_level = 3
			corpse_rain_baseammo = 5
			corpse_rain_attackspeed = 1.6
			corpse_rain_damage = 4
			if CorpseRainTimer and CorpseRainAttackTimer:
				CorpseRainTimer.wait_time = corpse_rain_attackspeed * (1 - spell_cooldown)
				CorpseRainTimer.start()
				#print("💀 [CORPSE DEBUG] Upgraded to corpse_rain3, corpse_rain_level=", corpse_rain_level, ", baseammo=", corpse_rain_baseammo, ", attackspeed=", corpse_rain_attackspeed, ", damage=", corpse_rain_damage, ", CorpseRainTimer started, running=", !CorpseRainTimer.is_stopped())
			else:
				push_error("CorpseRainTimer or CorpseRainAttackTimer is null for corpse_rain3")
		"corpse_rain4":
			corpse_rain_level = 4
			corpse_rain_baseammo = 5
			corpse_rain_attackspeed = 1.4
			corpse_rain_damage = 6
			if CorpseRainTimer and CorpseRainAttackTimer:
				CorpseRainTimer.wait_time = corpse_rain_attackspeed * (1 - spell_cooldown)
				CorpseRainTimer.start()
				#print("💀 [CORPSE DEBUG] Upgraded to corpse_rain4, corpse_rain_level=", corpse_rain_level, ", baseammo=", corpse_rain_baseammo, ", attackspeed=", corpse_rain_attackspeed, ", damage=", corpse_rain_damage, ", CorpseRainTimer started, running=", !CorpseRainTimer.is_stopped())
			else:
				push_error("CorpseRainTimer or CorpseRainAttackTimer is null for corpse_rain4")
		"power_chord1", "power_chord2", "power_chord3", "power_chord4", "power_chord5":
			damage_multiplier += 0.10
		"shred_drive1", "shred_drive2", "shred_drive3", "shred_drive4", "shred_drive5":
			projectile_speed_multiplier += 0.10
		"resonance_pedal1", "resonance_pedal2", "resonance_pedal3", "resonance_pedal4", "resonance_pedal5":
			effect_duration_multiplier += 0.10
		"stage_magnet1", "stage_magnet2", "stage_magnet3", "stage_magnet4", "stage_magnet5":
			pickup_radius_bonus += 0.10
			if has_node("PickupArea/CollisionShape2D"):
				var shape := $PickupArea/CollisionShape2D.shape
				if shape is CircleShape2D:
					shape.radius *= (1.0 + pickup_radius_bonus)
		"blood_oath1", "blood_oath2", "blood_oath3", "blood_oath4", "blood_oath5":
			hp_regen_per_sec += 0.2
		"iron_will1", "iron_will2", "iron_will3", "iron_will4", "iron_will5":
			maxhp = int(round(maxhp * 1.2))
			hp = min(hp, maxhp)
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			movement_speed += 20.0
		"tome1", "tome2", "tome3", "tome4":
			spell_size += 0.10
		"scroll1", "scroll2", "scroll3", "scroll4":
			spell_cooldown += 0.05
		"ring1", "ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp, 0, maxhp)

	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.offset_left = 800.0
	levelPanel.offset_top = 50.0
	get_tree().paused = false
	attack()
	calculate_experience(0)


func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null


func change_time(argtime = 0):
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)


func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)


func death():
	# Delay to allow boss queue_free() to complete
	await get_tree().create_timer(0.1).timeout
	var enemies = get_tree().get_nodes_in_group("enemy")
	var boss_alive = false
	for enemy in enemies:
		if enemy.scene_file_path in [
			"res://Enemy/death18.tscn",  # world.tscn boss
			"res://Enemy/black18.tscn",  # level2.tscn boss
			"res://Enemy/enemy18.tscn",  # level3.tscn boss
			"res://Enemy/doom18.tscn",
			"res://Enemy/glam18.tscn",
			"res://Enemy/folk18.tscn",
			"res://Enemy/prog18.tscn",
			"res://Enemy/indus18.tscn",
			"res://Enemy/nu18.tscn",
			"res://Enemy/power18.tscn" 
		]:
			boss_alive = true
			break
	if time >= 1180 and not boss_alive:
		_on_boss_defeated()
	elif time >= 1200:
		_on_boss_defeated()
	else:
		deathPanel.visible = true
		get_tree().paused = true
		var tween = deathPanel.create_tween()
		tween.tween_property(deathPanel, "offset_left", 230.0, 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(deathPanel, "offset_top", 50.0, 3.0)
		tween.play()
		lblResult.text = "You Lose"
		sndLose.play()
		#print("Player died, showing 'You Lose'")


func _on_spawner_changetime(_time: int):
	if _time == 1180:
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			if enemy.has_signal("boss_defeated") and not enemy.boss_defeated.is_connected(_on_boss_defeated):
				enemy.boss_defeated.connect(_on_boss_defeated)
				#print("Connected boss_defeated signal for enemy at time=1180: ", enemy.scene_file_path)


func _on_boss_defeated():
	#print("Boss defeated, triggering victory screen")
	if deathPanel:
		deathPanel.visible = true
		get_tree().paused = true
		var tween = deathPanel.create_tween()
		tween.tween_property(deathPanel, "offset_left", 230.0, 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(deathPanel, "offset_top", 50.0, 3.0)
		tween.play()
		lblResult.text = "You Win"
		sndVictory.play()
		#print("DeathPanel visible: ", deathPanel.visible, " offset: ", Vector2(deathPanel.offset_left, deathPanel.offset_top), " z_index: ", deathPanel.z_index)
	else:
		push_error("DeathPanel is null in _on_boss_defeated!")


func _on_btn_menu_click_end():
	get_tree().paused = false
	# Disable processing to prevent _physics_process during scene change
	process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")


func _on_RazorTimer_timeout() -> void:
	#–– do nothing if weapon not unlocked
	if razor_level == 0:
		return

	# refill this volley’s ammo
	razor_ammo = razor_picks_per_volley

	# ——— force burst cooldown per level ———
	var volley_waits = {
		1: 1.0,  # level 1 → 1.0 s between volleys
		2: 0.9,  # level 2 → 0.9 s
		3: 0.8,  # level 3 → 0.8 s
		4: 0.7   # level 4 → 0.7 s
	}
	RazorTimer.wait_time = volley_waits[razor_level]

	# ——— lock inter‐shot spacing at 0.1 s for every level ———
	RazorAttackTimer.wait_time = 0.1

	# start spitting out the picks
	RazorAttackTimer.start()

func _on_RazorAttackTimer_timeout() -> void:
	#–– stop if volley spent
	if razor_ammo <= 0:
		RazorAttackTimer.stop()
		return

	# which shot in this volley (0 .. N-1)
	var shot_index = razor_picks_per_volley - razor_ammo

	# instantiate pick
	var pick = RazorPickScene.instantiate() as Area2D
	pick.camera_path = camera2d.get_path()

	# ——— level-based damage & piercing ———
	match razor_level:
		1:
			pick.damage = 2
			pick.pierce_count = 1
		2:
			pick.damage = 3
			pick.pierce_count = 1
		3:
			pick.damage = 4
			pick.pierce_count = 2
		4:
			pick.damage = 5
			pick.pierce_count = 3

# ——— small fan-out around last_movement ———
	var base_dir = last_movement.normalized()
	var spread_degrees = 8                                    # ±4° cone
	var total = max(razor_picks_per_volley - 1, 1)
	var t = float(shot_index) / total                         # evenly 0→1
	var angle_offset = deg_to_rad(-spread_degrees/2 + t * spread_degrees)
	var shot_dir = base_dir.rotated(angle_offset)
	# ——— spawn at one of three offsets perpendicular to aim ———
	var perp = Vector2(-base_dir.y, base_dir.x)    # 90°-rotated last_movement
	var distances = [-8, 0, 8]                     # tweak these magnitudes
	var idx = shot_index % distances.size()        # cycles 0→1→2→0…
	var spawn_pos = global_position + perp * distances[idx]

	# ——— add to scene & fire ———
	get_tree().current_scene.add_child(pick)
	pick.global_position = spawn_pos
	pick.level = razor_level
	pick.initialize(shot_dir, shot_index)

	#–– consume ammo & stop when done
	razor_ammo -= 1
	if razor_ammo <= 0:
		RazorAttackTimer.stop()

func _on_RuneAxeTimer_timeout() -> void:
	# refill count to exactly level
	runeAxe_slices = runeAxe_level

	# same cooldown between volleys regardless of level
	RuneAxeTimer.wait_time = 1.5
	RuneAxeTimer.start()

	# kick off the per-slice firing
	RuneAxeAttackTimer.wait_time = runeAxe_volley_delay
	RuneAxeAttackTimer.start()

func _on_RuneAxeAttackTimer_timeout() -> void:
	if runeAxe_slices <= 0:
		RuneAxeAttackTimer.stop()
		return

	# instantiate & parent under player so position is local
	var slice = runeAxe_scene.instantiate() as RuneAxeSlice
	add_child(slice)
	slice.position = AXE_SPAWN_OFFSET
	slice.damage = 2 + runeAxe_level

	# calculate which swing this is (1-based)
	var swings_done = runeAxe_level - runeAxe_slices + 1

	# odd swings → RIGHT, even swings → LEFT
	var dir = RuneAxeSlice.SwingDir.RIGHT if (swings_done % 2) == 1 else RuneAxeSlice.SwingDir.LEFT
	
	slice.start_swing(dir)

	runeAxe_slices -= 1


func _on_TrebleTimer_timeout() -> void:
	if treble_level == 0:
		return
	treble_ammo = treble_baseammo + additional_attacks
	#print("🔊 [TREBLE DEBUG] TrebleTimer timeout, refilling ammo to ", treble_ammo, ", treble_level=", treble_level, ", TrebleTimer running=", !TrebleTimer.is_stopped())
	TrebleAttackTimer.start()


func _on_TrebleAttackTimer_timeout() -> void:
	if treble_ammo > 0:
		var treble_attack = treble_scene.instantiate()
		treble_attack.camera_path = camera2d.get_path()
		treble_attack.level = treble_level
		treble_attack.damage = treble_damage
		treble_attack.speed = treble_speed
		treble_attack.global_position = global_position
		get_tree().current_scene.add_child(treble_attack)
		treble_ammo -= 1
		#print("🔊 [TREBLE DEBUG] TrebleAttackTimer timeout, spawned treble, ammo left=", treble_ammo, ", level=", treble_level, ", position=", treble_attack.global_position)
		if treble_ammo > 0:
			TrebleAttackTimer.start()
		else:
			TrebleAttackTimer.stop()
	else:
		TrebleAttackTimer.stop()
		#print("🔊 [TREBLE DEBUG] TrebleAttackTimer timeout, no ammo, stopping timer")


func _on_BassTimer_timeout() -> void:
	if bass_level == 0:
		return
	bass_ammo = bass_baseammo + additional_attacks
	#print("🔊 [BASS DEBUG] BassTimer timeout, refilling ammo to ", bass_ammo, ", bass_level=", bass_level, ", BassTimer running=", !BassTimer.is_stopped())
	BassAttackTimer.start()


func _on_BassAttackTimer_timeout() -> void:
	if bass_ammo > 0:
		var bass_attack = bass_scene.instantiate()
		bass_attack.camera_path = camera2d.get_path()
		bass_attack.level = bass_level
		bass_attack.damage = bass_damage
		bass_attack.speed = bass_speed
		bass_attack.global_position = global_position
		get_tree().current_scene.add_child(bass_attack)
		bass_ammo -= 1
		#print("🔊 [BASS DEBUG] BassAttackTimer timeout, spawned bass, ammo left=", bass_ammo, ", level=", bass_level, ", position=", bass_attack.global_position)
		if bass_ammo > 0:
			BassAttackTimer.start()
		else:
			BassAttackTimer.stop()
	else:
		BassAttackTimer.stop()
		#print("🔊 [BASS DEBUG] BassAttackTimer timeout, no ammo, stopping timer")


func _on_AmpWaveTimer_timeout() -> void:
	if amp_wave_level == 0:
		return
	amp_wave_ammo = amp_wave_baseammo + additional_attacks
	AmpWaveAttackTimer.start()


func _on_AmpWaveAttackTimer_timeout() -> void:
	if amp_wave_ammo > 0:
		var amp_wave_attack = amp_wave_scene.instantiate()
		amp_wave_attack.global_position = global_position
		amp_wave_attack.level = amp_wave_level
		get_parent().add_child(amp_wave_attack)
		amp_wave_ammo -= 1
		#print("🔊 [AMP DEBUG] AmpWaveAttackTimer timeout, spawned AmpWave, ammo left=", amp_wave_ammo, ", level=", amp_wave_level, ", position=", amp_wave_attack.global_position)
		if amp_wave_ammo > 0:
			AmpWaveAttackTimer.start()
		else:
			AmpWaveAttackTimer.stop()

func _on_CorpseRainTimer_timeout() -> void:
	if corpse_rain_level == 0:
		return
	corpse_rain_ammo = corpse_rain_baseammo + additional_attacks
	#print("💀 [CORPSE DEBUG] CorpseRainTimer timeout, refilling ammo to ", corpse_rain_ammo, ", corpse_rain_level=", corpse_rain_level)
	CorpseRainAttackTimer.start()

func _on_CorpseRainAttackTimer_timeout() -> void:
	if corpse_rain_ammo > 0:
		var sprite_types = ["head", "arm", "foot", "torso", "hand"]
		var sprite_type = sprite_types[corpse_rain_ammo - 1] if corpse_rain_ammo <= 5 else sprite_types[randi() % 5]
		var corpse_rain_attack = corpse_rain_scene.instantiate()
		corpse_rain_attack.sprite_type = sprite_type
		corpse_rain_attack.level = corpse_rain_level
		corpse_rain_attack.damage = corpse_rain_damage
		
		# Random x-position within viewport
		var viewport_rect = camera2d.get_viewport_rect()
		var camera_pos = camera2d.global_position
		var spawn_x = camera_pos.x - viewport_rect.size.x / 2 + randf() * viewport_rect.size.x
		var spawn_y = camera_pos.y - viewport_rect.size.y / 2 - 50  # Above top of screen
		corpse_rain_attack.global_position = Vector2(spawn_x, spawn_y)
		
		get_parent().add_child(corpse_rain_attack)
		corpse_rain_ammo -= 1
		#print("💀 [CORPSE DEBUG] CorpseRainAttackTimer timeout, spawned ", sprite_type, ", ammo left=", corpse_rain_ammo, ", level=", corpse_rain_level, ", position=", corpse_rain_attack.global_position)
		if corpse_rain_ammo > 0:
			CorpseRainAttackTimer.start()
		else:
			CorpseRainAttackTimer.stop()
	else:
		CorpseRainAttackTimer.stop()
		#print("💀 [CORPSE DEBUG] CorpseRainAttackTimer timeout, no ammo, stopping timer")
