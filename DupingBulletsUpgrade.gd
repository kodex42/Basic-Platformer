extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "bullet"
	label.text = "Duping Bullets"
	desc = "Causes bullets to create bullet fragments on next collision\nBullet fragments deal half the creating bullet's damage\nStacks compoundingly"

func upgrade(bullet):
	.upgrade(bullet)
	bullet.add_mod("duping")
	print("Duping Bullets make your bullets duplicate!")

func interact(player):
	.interact(player)
	print(label.text)
