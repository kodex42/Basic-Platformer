extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "gun"
	label.text = "Barrel Cleaner"
	desc = "Increases your current gun's damage by 2"

func upgrade(weapon):
	.upgrade(weapon)
	weapon.damage += 2
	print("Barrel Cleaner upgraded your " + weapon.name + "'s damage by 2!")

func interact(player):
	.interact(player)
	print(label.text)
