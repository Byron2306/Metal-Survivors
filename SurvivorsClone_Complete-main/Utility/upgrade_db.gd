extends Node

const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const UPGRADES = {
	"icespear1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Guitar Shock",
		"details": "A Guitar Shock is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"icespear2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Guitar Shock",
		"details": "An additional Guitar Shock is thrown",
		"level": "Level: 2",
		"prerequisite": ["icespear1"],
		"type": "weapon"
	},
	"icespear3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Guitar Shock",
		"details": "Guitar Shocks now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Guitar Shock",
		"details": "An additional 2 Guitar Shocks are thrown",
		"level": "Level: 4",
		"prerequisite": ["icespear3"],
		"type": "weapon"
	},
	"javelin1": {
		"icon": WEAPON_PATH + "javelin1.png",
		"displayname": "Devil Horns",
		"details": "A magical Devil Horn will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"javelin2": {
		"icon": WEAPON_PATH + "javelin1.png",
		"displayname": "Devil Horns",
		"details": "The Devil Horn will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisite": ["javelin1"],
		"type": "weapon"
	},
	"javelin3": {
		"icon": WEAPON_PATH + "javelin1.png",
		"displayname": "Devil Horns",
		"details": "The Devil Horn will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisite": ["javelin2"],
		"type": "weapon"
	},
	"javelin4": {
		"icon": WEAPON_PATH + "javelin1.png",
		"displayname": "Devil Horns",
		"details": "The Devil Horn now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisite": ["javelin3"],
		"type": "weapon"
	},
	"tornado1": {
		"icon": WEAPON_PATH + "fire-skull1.png",
		"displayname": "Flame Skull",
		"details": "A Flame Skull is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"tornado2": {
		"icon": WEAPON_PATH + "fire-skull1.png",
		"displayname": "Flame Skull",
		"details": "An additional Flame Skull is created",
		"level": "Level: 2",
		"prerequisite": ["tornado1"],
		"type": "weapon"
	},
	"tornado3": {
		"icon": WEAPON_PATH + "fire-skull1.png",
		"displayname": "Flame Skull",
		"details": "The Flame Skull cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["tornado2"],
		"type": "weapon"
	},
	"tornado4": {
		"icon": WEAPON_PATH + "fire-skull1.png",
		"displayname": "Flame Skull",
		"details": "An additional Flame Skull is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["tornado3"],
		"type": "weapon"
	},
	"metalSpike1": {
		"icon": WEAPON_PATH + "metal spike1.png",
		"displayname": "Metal Spike Initiation",
		"details": "Unlock the Metal Spike weapon. Initial level with a single spike.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon",
		"metalSpike_level": 1,
		"metalSpike_ammo": 1
	},
	"metalSpike2": {
		"icon": WEAPON_PATH + "metal spike1.png",
		"displayname": "Metal Spike Strengthening",
		"details": "Upgrade your Metal Spike to level 2.",
		"level": "Level: 2",
		"prerequisite": ["metalSpike1"],
		"type": "weapon",
		"metalSpike_level": 2
	},
	"metalSpike3": {
		"icon": WEAPON_PATH + "metal spike1.png",
		"displayname": "Advanced Metal Spike",
		"details": "Further upgrade your Metal Spike to level 3.",
		"level": "Level: 3",
		"prerequisite": ["metalSpike2"],
		"type": "weapon",
		"metalSpike_level": 3
	},
	"metalSpike4": {
		"icon": WEAPON_PATH + "metal spike1.png",
		"displayname": "Ultimate Metal Spike",
		"details": "Maximize the power of your Metal Spike and gain additional ammo.",
		"level": "Level: 4",
		"prerequisite": ["metalSpike3"],
		"type": "weapon",
		"metalSpike_level": 4,
		"metalSpike_baseammo": 2
	},
	"mosh1": {
		"icon": WEAPON_PATH + "mosh_icon.png",
		"displayname": "Mosh Ball I",
		"details": "Hurl a single Mosh Ball that bounces twice.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"mosh2": {
		"icon": WEAPON_PATH + "mosh_icon.png",
		"displayname": "Double Mosh",
		"details": "Two Mosh Balls fire in quick succession.",
		"level": "Level: 2",
		"prerequisite": ["mosh1"],
		"type": "weapon"
	},
	"mosh3": {
		"icon": WEAPON_PATH + "mosh_icon.png",
		"displayname": "Chain Mosh",
		"details": "Mosh Balls pierce one extra enemy each bounce.",
		"level": "Level: 3",
		"prerequisite": ["mosh2"],
		"type": "weapon"
	},
	"mosh4": {
		"icon": WEAPON_PATH + "mosh_icon.png",
		"displayname": "Mosh Barrage",
		"details": "Fire four Mosh Balls in a swirling pattern.",
		"level": "Level: 4",
		"prerequisite": ["mosh3"],
		"type": "weapon"
	},
	"pentagram1": {
		"icon": WEAPON_PATH + "pentagram.png",
		"displayname": "Pentagram Aura",
		"details": "Creates an aura that deals 1 damage per second in a 50-unit radius.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"pentagram2": {
		"icon": WEAPON_PATH + "pentagram.png",
		"displayname": "Pentagram Aura",
		"details": "Increases damage to 2 and radius to 60 units.",
		"level": "Level: 2",
		"prerequisite": ["pentagram1"],
		"type": "weapon"
	},
	"pentagram3": {
		"icon": WEAPON_PATH + "pentagram.png",
		"displayname": "Pentagram Aura",
		"details": "Increases damage to 3, radius to 70 units, and ticks every 0.6 seconds.",
		"level": "Level: 3",
		"prerequisite": ["pentagram2"],
		"type": "weapon"
	},
	"pentagram4": {
		"icon": WEAPON_PATH + "pentagram.png",
		"displayname": "Pentagram Aura",
		"details": "Increases damage to 4, radius to 80 units, and ticks every 0.4 seconds.",
		"level": "Level: 4",
		"prerequisite": ["pentagram3"],
		"type": "weapon"
	},
	"iceSpikes1": {
		"icon": WEAPON_PATH + "ice_small.png",
		"displayname": "Ice Spikes",
		"details": "Spawns a zone of ice spikes that damages enemies over time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"iceSpikes2": {
		"icon": WEAPON_PATH + "ice_small.png",
		"displayname": "Ice Spikes",
		"details": "Increases damage and zone size",
		"level": "Level: 2",
		"prerequisite": ["iceSpikes1"],
		"type": "weapon"
	},
	"iceSpikes3": {
		"icon": WEAPON_PATH + "ice_small.png",
		"displayname": "Ice Spikes",
		"details": "Increases tick speed and adds an extra zone",
		"level": "Level: 3",
		"prerequisite": ["iceSpikes2"],
		"type": "weapon"
	},
	"iceSpikes4": {
		"icon": WEAPON_PATH + "ice_small.png",
		"displayname": "Ice Spikes",
		"details": "Further increases damage, zone size, and adds more zones",
		"level": "Level: 4",
		"prerequisite": ["iceSpikes3"],
		"type": "weapon"
	},
	"beer1": {
		"icon": WEAPON_PATH + "beer_small.png",
		"displayname": "Beer",
		"details": "Throws a beer bottle that arches and damages enemies in its path",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"beer2": {
		"icon": WEAPON_PATH + "beer_small.png",
		"displayname": "Beer",
		"details": "Increases damage and adds an extra bottle",
		"level": "Level: 2",
		"prerequisite": ["beer1"],
		"type": "weapon"
	},
	"beer3": {
		"icon": WEAPON_PATH + "beer_small.png",
		"displayname": "Beer",
		"details": "Increases damage and throw speed",
		"level": "Level: 3",
		"prerequisite": ["beer2"],
		"type": "weapon"
	},
	"beer4": {
		"icon": WEAPON_PATH + "beer_small.png",
		"displayname": "Beer",
		"details": "Further increases damage, speed, and adds more bottles",
		"level": "Level: 4",
		"prerequisite": ["beer3"],
		"type": "weapon"
	},
	"razorpick1": {
		"icon": WEAPON_PATH + "pick.png",
		"displayname": "Razor Picks I",
		"details": "Throws a single razor pick in your movement direction.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"razorpick2": {
		"icon": WEAPON_PATH + "pick.png",
		"displayname": "Twin Razor Picks",
		"details": "Throws two razor picks in quick succession.",
		"level": "Level: 2",
		"prerequisite": ["razorpick1"],
		"type": "weapon"
	},
	"razorpick3": {
		"icon": WEAPON_PATH + "pick.png",
		"displayname": "Triple Razor Picks",
		"details": "Throws three razor picks in a wider spread.",
		"level": "Level: 3",
		"prerequisite": ["razorpick2"],
		"type": "weapon"
	},
	"razorpick4": {
		"icon": WEAPON_PATH + "pick.png",
		"displayname": "Razor Barrage",
		"details": "Throws four razor picks in a rapid volley; picks now pierce one extra enemy.",
		"level": "Level: 4",
		"prerequisite": ["razorpick3"],
		"type": "weapon"
	},
	"runeaxe1": {
		"icon": WEAPON_PATH + "rune_axe_small.png",
		"displayname": "Rune Axe I",
		"details": "Swing a rune axe downward for 3 damage",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"runeaxe2": {
		"icon": WEAPON_PATH + "rune_axe_small.png",
		"displayname": "Rune Axe II",
		"details": "After the first slice, swing a second slice to the left for 4 damage",
		"level": "Level: 2",
		"prerequisite": ["runeaxe1"],
		"type": "weapon"
	},
	"runeaxe3": {
		"icon": WEAPON_PATH + "rune_axe_small.png",
		"displayname": "Rune Axe III",
		"details": "Add a third slice to the right for 5 damage",
		"level": "Level: 3",
		"prerequisite": ["runeaxe2"],
		"type": "weapon"
	},
	"runeaxe4": {
		"icon": WEAPON_PATH + "rune_axe_small.png",
		"displayname": "Rune Axe IV",
		"details": "Perform four slices (right, left, right, left) dealing 6 damage each",
		"level": "Level: 4",
		"prerequisite": ["runeaxe3"],
		"type": "weapon"
	},
	"treble1": {
		"icon": WEAPON_PATH + "treble_small.png",
		"displayname": "Treble",
		"details": "Fires 3 Treble projectiles in a fixed North East direction.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"treble2": {
		"icon": WEAPON_PATH + "treble_small.png",
		"displayname": "Treble",
		"details": "Adds 1 more projectile and increases damage by 1.",
		"level": "Level: 2",
		"prerequisite": ["treble1"],
		"type": "weapon"
	},
	"treble3": {
		"icon": WEAPON_PATH + "treble_small.png",
		"displayname": "Treble",
		"details": "Adds 1 more projectile and increases speed by 50.",
		"level": "Level: 3",
		"prerequisite": ["treble2"],
		"type": "weapon"
	},
	"treble4": {
		"icon": WEAPON_PATH + "treble_small.png",
		"displayname": "Treble",
		"details": "Adds 2 more projectiles, increases damage by 2, and speed by 100.",
		"level": "Level: 4",
		"prerequisite": ["treble3"],
		"type": "weapon"
	},
	"bass1": {
		"icon": ICON_PATH + "bass_small.png",
		"displayname": "Bass",
		"details": "Fires 3 Bass projectiles in a fixed North-West direction.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"bass2": {
		"icon": ICON_PATH + "bass_small.png",
		"displayname": "Bass",
		"details": "Adds 1 more projectile and increases damage by 1.",
		"level": "Level: 2",
		"prerequisite": ["bass1"],
		"type": "weapon"
	},
	"bass3": {
		"icon": ICON_PATH + "bass_small.png",
		"displayname": "Bass",
		"details": "Adds 1 more projectile and increases speed by 50.",
		"level": "Level: 3",
		"prerequisite": ["bass2"],
		"type": "weapon"
	},
	"bass4": {
		"icon": ICON_PATH + "bass_small.png",
		"displayname": "Bass",
		"details": "Adds 2 more projectiles, increases damage by 2, and speed by 100.",
		"level": "Level: 4",
		"prerequisite": ["bass3"],
		"type": "weapon"
	},
	"ampwave1": {
		"icon": ICON_PATH + "amp_small.png",
		"displayname": "Amp Wave",
		"details": "Emits a wave of sound energy to damage enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"ampwave2": {
		"icon": ICON_PATH + "amp_small.png",
		"displayname": "Amp Wave",
		"details": "Increases Amp Wave damage and adds an additional wave",
		"level": "Level: 2",
		"prerequisite": ["ampwave1"],
		"type": "weapon"
	},
	"ampwave3": {
		"icon": ICON_PATH + "amp_small.png",
		"displayname": "Amp Wave",
		"details": "Increases Amp Wave area and attack speed, adds another wave",
		"level": "Level: 3",
		"prerequisite": ["ampwave2"],
		"type": "weapon"
	},
	"ampwave4": {
		"icon": ICON_PATH + "amp_small.png",
		"displayname": "Amp Wave",
		"details": "Greatly increases Amp Wave damage and adds a final wave",
		"level": "Level: 4",
		"prerequisite": ["ampwave3"],
		"type": "weapon"
	},
	"corpse_rain1": {
		"icon": ICON_PATH + "head_small.png",
		"displayname": "Corpse Rain",
		"details": "Rains body parts from the sky to damage enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"corpse_rain2": {
		"icon": ICON_PATH + "head_small.png",
		"displayname": "Corpse Rain",
		"details": "Increases Corpse Rain damage and slightly reduces cooldown",
		"level": "Level: 2",
		"prerequisite": ["corpse_rain1"],
		"type": "weapon"
	},
	"corpse_rain3": {
		"icon": ICON_PATH + "head_small.png",
		"displayname": "Corpse Rain",
		"details": "Increases Corpse Rain damage, size, and attack speed",
		"level": "Level: 3",
		"prerequisite": ["corpse_rain2"],
		"type": "weapon"
	},
	"corpse_rain4": {
		"icon": ICON_PATH + "head_small.png",
		"displayname": "Corpse Rain",
		"details": "Greatly increases Corpse Rain damage, size, and attack speed",
		"level": "Level: 4",
		"prerequisite": ["corpse_rain3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"power_chord1": {
		"icon": ICON_PATH + "power.png",
		"displayname": "Power Chord",
		"details": "Increases weapon damage by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"power_chord2": {
		"icon": ICON_PATH + "power.png",
		"displayname": "Power Chord",
		"details": "Increases weapon damage by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["power_chord1"],
		"type": "upgrade"
	},
	"power_chord3": {
		"icon": ICON_PATH + "power.png",
		"displayname": "Power Chord",
		"details": "Increases weapon damage by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["power_chord2"],
		"type": "upgrade"
	},
	"power_chord4": {
		"icon": ICON_PATH + "power.png",
		"displayname": "Power Chord",
		"details": "Increases weapon damage by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["power_chord3"],
		"type": "upgrade"
	},
	"power_chord5": {
		"icon": ICON_PATH + "power.png",
		"displayname": "Power Chord",
		"details": "Increases weapon damage by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["power_chord4"],
		"type": "upgrade"
	},
	"shred_drive1": {
		"icon": ICON_PATH + "drive.png",
		"displayname": "Shred Drive",
		"details": "Increases weapon speed by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"shred_drive2": {
		"icon": ICON_PATH + "drive.png",
		"displayname": "Shred Drive",
		"details": "Increases weapon speed by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["shred_drive1"],
		"type": "upgrade"
	},
	"shred_drive3": {
		"icon": ICON_PATH + "drive.png",
		"displayname": "Shred Drive",
		"details": "Increases weapon speed by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["shred_drive2"],
		"type": "upgrade"
	},
	"shred_drive4": {
		"icon": ICON_PATH + "drive.png",
		"displayname": "Shred Drive",
		"details": "Increases weapon speed by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["shred_drive3"],
		"type": "upgrade"
	},
	"shred_drive5": {
		"icon": ICON_PATH + "drive.png",
		"displayname": "Shred Drive",
		"details": "Increases weapon speed by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["shred_drive4"],
		"type": "upgrade"
	},
	"resonance_pedal1": {
		"icon": ICON_PATH + "pedal.png",
		"displayname": "Resonance Pedal",
		"details": "Increases effect duration by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"resonance_pedal2": {
		"icon": ICON_PATH + "pedal.png",
		"displayname": "Resonance Pedal",
		"details": "Increases effect duration by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["resonance_pedal1"],
		"type": "upgrade"
	},
	"resonance_pedal3": {
		"icon": ICON_PATH + "pedal.png",
		"displayname": "Resonance Pedal",
		"details": "Increases effect duration by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["resonance_pedal2"],
		"type": "upgrade"
	},
	"resonance_pedal4": {
		"icon": ICON_PATH + "pedal.png",
		"displayname": "Resonance Pedal",
		"details": "Increases effect duration by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["resonance_pedal3"],
		"type": "upgrade"
	},
	"resonance_pedal5": {
		"icon": ICON_PATH + "pedal.png",
		"displayname": "Resonance Pedal",
		"details": "Increases effect duration by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["resonance_pedal4"],
		"type": "upgrade"
	},
	"stage_magnet1": {
		"icon": ICON_PATH + "magnet.png",
		"displayname": "Stage Magnet",
		"details": "Increases pickup radius by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"stage_magnet2": {
		"icon": ICON_PATH + "magnet.png",
		"displayname": "Stage Magnet",
		"details": "Increases pickup radius by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["stage_magnet1"],
		"type": "upgrade"
	},
	"stage_magnet3": {
		"icon": ICON_PATH + "magnet.png",
		"displayname": "Stage Magnet",
		"details": "Increases pickup radius by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["stage_magnet2"],
		"type": "upgrade"
	},
	"stage_magnet4": {
		"icon": ICON_PATH + "magnet.png",
		"displayname": "Stage Magnet",
		"details": "Increases pickup radius by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["stage_magnet3"],
		"type": "upgrade"
	},
	"stage_magnet5": {
		"icon": ICON_PATH + "magnet.png",
		"displayname": "Stage Magnet",
		"details": "Increases pickup radius by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["stage_magnet4"],
		"type": "upgrade"
	},
	"blood_oath1": {
		"icon": ICON_PATH + "oath.png",
		"displayname": "Blood Oath",
		"details": "Regenerates 0.2 HP per second",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"blood_oath2": {
		"icon": ICON_PATH + "oath.png",
		"displayname": "Blood Oath",
		"details": "Regenerates an additional 0.2 HP per second",
		"level": "Level: 2",
		"prerequisite": ["blood_oath1"],
		"type": "upgrade"
	},
	"blood_oath3": {
		"icon": ICON_PATH + "oath.png",
		"displayname": "Blood Oath",
		"details": "Regenerates an additional 0.2 HP per second",
		"level": "Level: 3",
		"prerequisite": ["blood_oath2"],
		"type": "upgrade"
	},
	"blood_oath4": {
		"icon": ICON_PATH + "oath.png",
		"displayname": "Blood Oath",
		"details": "Regenerates an additional 0.2 HP per second",
		"level": "Level: 4",
		"prerequisite": ["blood_oath3"],
		"type": "upgrade"
	},
	"blood_oath5": {
		"icon": ICON_PATH + "oath.png",
		"displayname": "Blood Oath",
		"details": "Regenerates an additional 0.2 HP per second",
		"level": "Level: 5",
		"prerequisite": ["blood_oath4"],
		"type": "upgrade"
	},
	"iron_will1": {
		"icon": ICON_PATH + "will.png",
		"displayname": "Iron Will",
		"details": "Increases maximum HP by 20%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"iron_will2": {
		"icon": ICON_PATH + "will.png",
		"displayname": "Iron Will",
		"details": "Increases maximum HP by an additional 20%",
		"level": "Level: 2",
		"prerequisite": ["iron_will1"],
		"type": "upgrade"
	},
	"iron_will3": {
		"icon": ICON_PATH + "will.png",
		"displayname": "Iron Will",
		"details": "Increases maximum HP by an additional 20%",
		"level": "Level: 3",
		"prerequisite": ["iron_will2"],
		"type": "upgrade"
	},
	"iron_will4": {
		"icon": ICON_PATH + "will.png",
		"displayname": "Iron Will",
		"details": "Increases maximum HP by an additional 20%",
		"level": "Level: 4",
		"prerequisite": ["iron_will3"],
		"type": "upgrade"
	},
	"iron_will5": {
		"icon": ICON_PATH + "will.png",
		"displayname": "Iron Will",
		"details": "Increases maximum HP by an additional 20%",
		"level": "Level: 5",
		"prerequisite": ["iron_will4"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisite": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisite": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisite": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisite": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisite": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisite": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["ring1"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}
