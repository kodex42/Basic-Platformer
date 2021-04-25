extends RigidBody2D

# State variables
var acceleration = 100
var max_velocity = 200
var max_jump_velocity = 200

# Movement variables
var directional_force = Vector2()
const DIRECTION = {
	ZERO = Vector2(0, 0),
	LEFT = Vector2(-1, 0),
	RIGHT = Vector2(1, 0),
	UP = Vector2(0, -1),
	DOWN = Vector2(0, 1),
}

func _integrate_forces(state):
	# Final force vector of the actor
	var force = Vector2()
	
	# Don't move when not changing direction
	directional_force = DIRECTION.ZERO
	
	# Apply force on actor
	apply_force(state)
	
	# Get movement velocity
	force = state.get_linear_velocity() + (directional_force * acceleration)
	
	# Limit velocity
	force.x = clamp(force.x, -max_velocity, max_velocity)
	force.y = clamp(force.y, -max_jump_velocity, max_jump_velocity)
	
	# Apply final force
	state.set_linear_velocity(force)

func apply_force(state): pass # Abstract
