extends "res://Enemy.gd"

# Children
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var sprite_tint_tween : Tween = $AnimatedSprite/TintTween
onready var spin_up_timer : Timer = $SpinUpTimer
onready var movement_timer: Timer = $MovementTimer
onready var spin_cooldown_timer : Timer = $SpinCooldownTimer

# State
var speed = 200
var direction = Vector2()
var destination = Vector2()
var moved = false
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_health(20)
	update_direction()
	contact_damage = 30
	max_x_speed = speed
	max_y_speed = speed
	force_hover = true
	force_linear = true
	gravity = 0
	damping = 0
	destination = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (not $DyingTimer.is_stopped()):
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	if (activated):
		# Start the sawblade when activated
		if (not moving and spin_up_timer.is_stopped() and spin_cooldown_timer.is_stopped()):
			spin_up_timer.start()
		
		# Stop the sawblade when it gets close to it's destination
		if (global_position.distance_to(destination) <= 10 and moving):
			movement_timer.stop()
			reset_movement()
		
		# Use timers for rotation to signify to the player when to dodge
		var rotf = 0.0 # Rotation factor
		if (not spin_up_timer.is_stopped()):
			rotf = (spin_up_timer.time_left - spin_up_timer.wait_time) / spin_up_timer.wait_time
		elif (not spin_cooldown_timer.is_stopped()):
			rotf = spin_cooldown_timer.time_left / spin_cooldown_timer.wait_time
		elif (moving):
			rotf = 1.0
		rotate(PI/8 * rotf)
		
	# Update animation
	var animation
	if (health <= 0):
		animation = "dying"
	else:
		animation = "flying"
	
	# Only change the animation if needed
	if (animated_sprite.animation != animation):
		animated_sprite.set_deferred("animation", animation)

# Overloaded function from parent class
func get_movement():
	if (moving and not moved):
		moved = true
		return direction * speed
	else:
		return Vector2(0, 0)

func reset_movement():
	moving = false
	moved = false
	spin_cooldown_timer.start()
	air_friction = 0.05

func update_direction():
	if (player):
		destination = player.get_global_position()
		direction = (destination - global_position).normalized()

func take_damage(val):
	health = health - val if health - val < 100 else 100
	root.spawn_particle("bullet_impact_metal", global_position)
	
	# Kill node after a while if health is <= 0
	if (health <= 0):
		activated = false
		$Collision.set_deferred("disabled", true)
		$HitCollision/HitCollisionShape.set_deferred("disabled", true)
		$DyingTimer.start()
	else:
		var tint = Color()
		if (val > 0):
			tint = Color(1, 0.3, 0.3, 1)
		elif (val == 0):
			tint = Color(0.3, 0.3, 1, 1)
		else:
			tint = Color(0.3, 1, 0.3, 1)
		
		sprite_tint_tween.interpolate_property(self, "modulate", tint, Color(1, 1, 1, 1), 0.8, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		sprite_tint_tween.start()

func _on_HitCollision_area_entered(area):
	if (area.is_in_group("melee")):
		take_damage(area.get_damage())
	if (area.is_in_group("projectile")):
		take_damage(area.get_damage())
		area.queue_free()

func _on_DyingTimer_timeout():
	kill()

func _on_SpinUpTimer_timeout():
	moving = true
	movement_timer.start()
	air_friction = 0
	update_direction()

func _on_SpinCooldownTimer_timeout():
	spin_up_timer.start()

func _on_MovementTimer_timeout():
	reset_movement()
