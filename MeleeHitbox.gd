extends Area2D

var damage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if ($HitboxShape.disabled): # Only move the hitbox while inactive
		var unit_distance = get_global_mouse_position() - get_parent().get_global_position()
		rotate_to_vector(unit_distance)
		# Flip animation if needed
		var ang = unit_distance.angle()
		if (ang < -PI/2 or ang > PI/2):
			$HitboxShape/AnimatedSprite.set_deferred("flip_v", true)
		else:
			$HitboxShape/AnimatedSprite.set_deferred("flip_v", false)

func rotate_to_vector(vec):
	rotation = vec.angle()
	position = vec.normalized() * 20

func set_damage(dmg):
	damage = dmg

func get_damage():
	return damage
