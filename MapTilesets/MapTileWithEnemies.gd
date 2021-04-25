extends "res://MapTilesets/MapTile.gd"

# Nodes
onready var root : Node = get_node("/root/Main")
onready var drop_spawner = root.get_node("RandomDropSpawner")

# State
var num_enemies = 0
var payed_out = false

func _on_RoomDetectionArea_body_entered(body):
	if (body.is_in_group("enemy")):
		num_enemies += 1
#		print("num_enemies: " + str(num_enemies))
		body.connect("killed", self, "_on_Enemy_killed")
	if (body.is_in_group("player")):
		for spawner in $Enemies.get_children():
			spawner.start_spawning()

func _on_Enemy_killed(pos):
	num_enemies -= 1
	if (num_enemies == 0 and not payed_out):
#		print("payout")
		payed_out = true
		for _i in range(3):
			var drop = drop_spawner.spawn()
			add_child(drop)
			drop.global_position = pos
