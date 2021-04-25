extends Sprite

var is_aiming = true
var is_melee = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var ang = (get_global_mouse_position() - get_parent().get_global_position()).angle()
	# Rotate toward the mouse cursor
	if (is_aiming and not is_melee):
		set_deferred("flip_h", false)
		look_at(get_global_mouse_position())
		# Check if the sprite needs to be flipped
		if (ang < -PI/2 or ang > PI/2):
			set_deferred("flip_v", true)
			position.x = -8
			offset.y = 3
		else:
			set_deferred("flip_v", false)
			position.x = 8
			offset.y = -3
	elif (is_melee): # Different settings if melee
		set_deferred("flip_v", false)
		offset.y = -6
		if (ang < -PI/2 or ang > PI/2):
			look_at(global_position + Vector2(1, -1))
			set_deferred("flip_h", true)
			position.x = -9
		else:
			look_at(global_position + Vector2(1, 1))
			set_deferred("flip_h", false)
			position.x = 7

func set_is_aiming(b):
	is_aiming = b
