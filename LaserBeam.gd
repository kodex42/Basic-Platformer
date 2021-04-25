extends Node2D

const MAX_LENGTH = 2000

onready var beam = $Beam
onready var end = $End

func set_end_position(pos):
	end.global_position = pos
	beam.rotation = end.position.angle()
	beam.region_rect.end.x = end.position.length()
