extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "player"
	stats.subtype = "immediate"
	label.text = "Good Shoes"
	desc = "Increases jump force by 20%"

func upgrade(player):
	.upgrade(player)
	player.jump_force *= 1.2
	print("Good Shoes increase your jump force by 20%!")

func interact(player):
	.interact(player)
	print(label.text)
