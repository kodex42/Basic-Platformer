extends Node2D

export var has_left_exit = false
export var has_up_exit = false
export var has_right_exit = false
export var has_down_exit = false

func get_connections():
	return [has_left_exit, has_up_exit, has_right_exit, has_down_exit]
