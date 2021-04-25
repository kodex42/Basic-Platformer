extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "player"
	stats.subtype = "onDamage"
	label.text = "Body Armor"
	desc = "Reduces all incoming damage by 50%"

func upgrade(damage):
	.upgrade(damage)
	damage /= 2
	print("Body Armor reduced your damage taken by 50%!")
	return damage

func interact(player):
	.interact(player)
	print(label.text)
