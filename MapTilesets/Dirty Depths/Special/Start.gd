extends "res://MapTilesets/MapTile.gd"

# Nodes
onready var root : Node = get_node("/root/Main")
onready var upgrade_spawner = root.get_node("RandomUpgradeSpawner")

func _ready():
	var upgrade = upgrade_spawner.spawn()
	$RandomUpgradeLocation.add_child(upgrade)
