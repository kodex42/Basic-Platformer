extends ResourcePreloader

var arsenal = []
var default = {
	"name" : "knife",
	"display_name" : "Knife",
	"type" : "melee",
	"fire_rate" : 0.75,
	"damage" : 5.0,
	"recoil" : 150.0,
	"multishot" : 1,
	"accuracy" : 1.0,
	"max_shots": 0,
	"shots": 0,
	"auto" : false,
	"time_shot" : 0,
	"range" : "melee"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Desert Hawk .50
	arsenal.append({
		"name" : "desert_hawk",
		"display_name" : "Pistol",
		"type" : "secondary",
		"fire_rate" : 0.5,
		"damage" : 10.0,
		"recoil" : 300.0,
		"multishot" : 1,
		"accuracy" : 1.0,
		"max_shots": 10,
		"shots": 10,
		"auto" : false,
		"time_shot" : 0,
		"range": "gun"
	})
	
	# Mag 9mm
	arsenal.append({
		"name" : "mag",
		"display_name" : "SMG",
		"type" : "secondary",
		"fire_rate" : 0.05,
		"damage" : 3.0,
		"recoil" : 50.0,
		"multishot" : 1,
		"accuracy" : 0.94,
		"max_shots": 32,
		"shots": 32,
		"auto" : true,
		"time_shot" : 0,
		"range": "gun"
	})
	
	# Poshlinov 7.62x39mm
	arsenal.append({
		"name" : "poshlinov",
		"display_name" : "Rifle",
		"type" : "primary",
		"fire_rate" : 0.2,
		"damage" : 12.0,
		"recoil" : 150.0,
		"multishot" : 1,
		"accuracy" : 0.98,
		"max_shots": 20,
		"shots": 20,
		"auto" : true,
		"time_shot" : 0,
		"range": "gun"
	})
	
	# sg1 12 gauge
	arsenal.append({
		"name" : "sg1",
		"display_name" : "Shotgun",
		"type" : "primary",
		"fire_rate" : 1.5,
		"damage" : 4.0,
		"recoil" : 44.0,
		"multishot" : 12,
		"accuracy" : 0.92,
		"max_shots": 4,
		"shots": 4,
		"auto" : false,
		"time_shot" : 0,
		"range": "gun"
	})

func get_default_weapon():
	return default.duplicate()

func get_random_weapon():
	randomize()
	if (arsenal.size() != 0):
		var ref = arsenal[randi()%arsenal.size()]
		var weap = ref.duplicate()
		return weap
	else:
		return get_default_weapon()

func get_random_secondary():
	randomize()
	var secondaries = [arsenal[0], arsenal[1]]
	if (secondaries.size() != 0):
		var ref = secondaries[randi()%secondaries.size()]
		var weap = ref.duplicate()
		return weap
	else:
		return get_default_weapon()

func get_weapon(name):
	var weap = null
	var ref = null
	for weapon in arsenal:
		if (weapon.name == name):
			ref = weapon
			weap = ref.duplicate()
	if (weap != null):
		return weap
	else:
		return get_random_weapon()
