extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "weapon"
	stats.subtype = "gun"
	label.text = "Shrapnel Rounds"
	desc = "Increases your current gun's multishot by 1"

func upgrade(weapon):
	.upgrade(weapon)
	weapon.multishot += 1
	print("Shrapnel Rounds upgraded your " + weapon.name + "'s multishot by 1!")

func interact(player):
	.interact(player)
	print(label.text)
