extends "res://MapTilesets/MapTile.gd"

# Preloads
var key_drop = preload("res://KeyDrop.tscn")
var ammo_box_drop = preload("res://AmmoBoxDrop.tscn")

# Nodes
onready var root : Node = get_node("/root/Main")
onready var upgrade_spawner : ResourcePreloader = root.get_node("RandomUpgradeSpawner")
onready var item1 : Node = get_node("ShopItem1")
onready var item2 : Node = get_node("ShopItem2")
onready var item3 : Node = get_node("ShopItem3")

func _ready():
	item1.set_item(key_drop.instance(), 5)
	item2.set_item(ammo_box_drop.instance(), 7)
	item3.set_item(upgrade_spawner.spawn(), 10)
