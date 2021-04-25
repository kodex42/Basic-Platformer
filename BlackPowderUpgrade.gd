extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "gun"
	label.text = "Black Powder"
	desc = "Increases your current gun's recoil by 50%"

func upgrade(weapon):
	.upgrade(weapon)
	weapon.recoil *= 1.5
	print("Black Powder upgraded your " + weapon.name + "'s recoil by 50%!")

func interact(player):
	.interact(player)
	print(label.text)
