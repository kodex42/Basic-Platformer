extends "res://Upgrade.gd"

# Onready
onready var label = $CenterContainer/Label

func _ready():
	stats.type = "player"
	stats.subtype = "onContact"
	label.text = "Abrasive Personality"
	desc = "Deals 100% of incoming contact damage to attackers"

func upgrade(source):
	.upgrade(source)
	source.take_damage(source.get_damage())
	print("Abrasive Personality deals 100% of contact damage dealt to you back to the attacker!")

func interact(player):
	.interact(player)
	print(label.text)
