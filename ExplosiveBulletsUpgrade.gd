extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "bullet"
	label.text = "Explosive Bullets"
	desc = "Causes bullets to create an explosion on next collision\nStacks compoundingly"

func upgrade(bullet):
	.upgrade(bullet)
	bullet.add_mod("explosive")
	print("Explosive Bullets make your bullets explode!")

func interact(player):
	.interact(player)
	print(label.text)
