extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "gun"
	label.text = "Scope"
	desc = "Increases your current gun's accuracy by 5% (additive)\nGuns at 100% accuracy are capped"

func upgrade(weapon):
	.upgrade(weapon)
	weapon.accuracy = weapon.accuracy + 0.05 if (weapon.accuracy < 1.0) else 1.0
	print("Scope upgraded your " + weapon.name + "'s accuracy by 5%!")

func interact(player):
	.interact(player)
	print(label.text)
