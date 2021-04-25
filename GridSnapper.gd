extends Position2D

onready var parent = get_parent()

var grid_size = Vector2()
var grid_position = Vector2(-1,-1)

func _ready():
	grid_size = Vector2(630, 420)
	set_as_toplevel(true)
	update_grid_position()

func _physics_process(_delta):
	update_grid_position()

func update_grid_position():
	var x = floor(parent.position.x / grid_size.x)
	var y = floor(parent.position.y / grid_size.y)
	var new_grid_position = Vector2(x, y)
	if (grid_position == new_grid_position):
		return
	
	grid_position = new_grid_position
	position = grid_position * grid_size
