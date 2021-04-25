extends "res://MapTilesets/MapTile.gd"

# Nodes
onready var root : Node = get_node("/root/Main")
onready var upgrade_spawner = root.get_node("RandomUpgradeSpawner")

# Called when the node enters the scene tree for the first time.
func _ready():
	var upgrade = upgrade_spawner.spawn()
	$UpgradeLocation.add_child(upgrade)
