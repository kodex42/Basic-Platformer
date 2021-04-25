extends KinematicBody2D

# Signals
signal spawn_bullet(dir, start_pos, start_rot, damage, enemy, mods)
signal killed(pos)

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player = root.get_node("Player")

# Exports
export var acceleration = 0.25
export var friction = 0.35
export var damping = 0.05
export var slope_slide_threshold = 50.0

# State
var max_health = 100
var health = 100
var activated = false
var gravity = 900
var air_friction = 0.0
var force_hover = false
var force_stationary = false
var force_linear = false
var snap = false
var velocity = Vector2()
var max_x_speed = 200
var max_y_speed = 600
var contact_damage = 10

func _ready():
	connect("spawn_bullet", root, "_on_Enemy_spawn_bullet")
	connect("killed", root, "_on_Enemy_killed")
	add_to_group("enemy")

func _physics_process(delta):
	if (activated):
		# Get velocity from subclass method
		velocity += get_movement()
		if (snap):
			velocity.x = lerp(velocity.x, 0, friction)
		else:
			velocity.x = lerp(velocity.x, 0, damping)
		if (not is_on_floor()):
			velocity.x = lerp(velocity.x, 0, air_friction)
			velocity.y = lerp(velocity.y, 0, air_friction)
		# Apply gravity
		velocity.y += gravity*delta
		# Clamping
		velocity.x = clamp(velocity.x, -max_x_speed, max_x_speed)
		velocity.y = clamp(velocity.y, -max_y_speed, max_y_speed)

		if (not (force_hover or force_stationary)):
			# Configure snap vector if enemy is snapped to the ground
			var snap_vector = Vector2(0, 8) if snap else Vector2() # Ternary operation
			velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, slope_slide_threshold)
		elif (not force_stationary):
			move_and_slide(velocity)
		else:
			position += velocity
		
		# Apply snapping when landing
		if (is_on_floor() and not snap):
			snap = true
		# Turn off snapping while airborne
		if (not is_on_floor()):
			snap = false

func activate():
	activated = true

func fire_bullet_at_player(dmg):
	if (player):
		var dir = (player.get_global_position() - global_position).normalized()
		emit_signal("spawn_bullet", dir, global_position, dir.angle(), dmg, self, [])

func set_max_health(hp):
	max_health = hp
	health = hp

func get_damage():
	return contact_damage

# Abstract, to be replaced by subclasses
func get_movement():
	return Vector2(0, 0)

func kill():
	emit_signal("killed", global_position)
	queue_free()
