extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "bullet"
	label.text = "Rubber Bullets"
	desc = "Causes bullets to bounce on next collision\nStacks compoundingly"

func upgrade(bullet):
	.upgrade(bullet)
	bullet.add_mod("rubber")
	print("Rubber Bullets make your bullets bounce!")

func interact(player):
	.interact(player)
	print(label.text)
