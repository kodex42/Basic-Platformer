extends "res://MapTilesets/MapTile.gd"

# Nodes
onready var root : Node = get_node("/root/Main")
onready var upgrade_spawner : ResourcePreloader = root.get_node("RandomUpgradeSpawner")
onready var items = [
	get_node("UpgradeItem1"),
	get_node("UpgradeItem2"),
	get_node("UpgradeItem3")
]

func _ready():
	items[0].set_item(upgrade_spawner.spawn(), 0)
	items[1].set_item(upgrade_spawner.spawn(), 0)
	items[2].set_item(upgrade_spawner.spawn(), 0)

func remove_others():
	for item in items:
		item.queue_free()

func _on_UpgradeItem1_purchased():
	remove_others()

func _on_UpgradeItem2_purchased():
	remove_others()

func _on_UpgradeItem3_purchased():
	remove_others()
