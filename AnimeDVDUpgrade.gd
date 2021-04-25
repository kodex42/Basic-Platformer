extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "melee"
	label.text = "Anime DVD"
	desc = "Decreases melee attack delay by 0.1s\nGives your melee weapon the ability to cut enemy bullets"

func upgrade(melee_weapon):
	.upgrade(melee_weapon)
	if (!"deflecting" in melee_weapon):
		melee_weapon["deflecting"] = true
	melee_weapon.fire_rate -= 0.1;
	if (melee_weapon.fire_rate < 0.4):
		melee_weapon.fire_rate = 0.4
	print("Anime DVDs give your " + melee_weapon.name + " the ability to destroy bullets!")

func interact(player):
	.interact(player)
	print(label.text)
