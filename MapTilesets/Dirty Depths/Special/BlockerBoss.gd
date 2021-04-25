extends "res://MapTilesets/MapTile.gd"

onready var root : Node = get_node("/root/Main")

func _on_PlayerDetectionArea_body_entered(body):
	if (body.is_in_group("player")):
		$Blocker.activate()
		$PlayerDetectionArea.disconnect("body_entered", self, "_on_PlayerDetectionArea_body_entered")
		root.disable_player_clone()
