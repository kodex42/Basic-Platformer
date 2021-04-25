extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "gun"
	label.text = "Forceful Springs"
	desc = "Decreases your current gun's fire delay by 0.1s\nGuns with 0.02s fire rate are capped and becom automatic"

func upgrade(weapon):
	.upgrade(weapon)
	weapon.fire_rate = weapon.fire_rate - 0.1 
	if (weapon.fire_rate < 0.02):
		weapon.fire_rate = 0.02
		weapon.auto = true
	print("Forceful Springs upgraded your " + weapon.name + "'s Fire Delay by -0.1 seconds!")

func interact(player):
	.interact(player)
	print(label.text)
