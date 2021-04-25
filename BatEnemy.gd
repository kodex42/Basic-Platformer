extends "res://Enemy.gd"

# Children
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var sprite_tint_tween : Tween = $AnimatedSprite/TintTween

# State
var x_speed = 75
var y_speed = 50
var direction = Vector2(0, 0)
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_health(10)
	contact_damage = 5
	max_x_speed = x_speed
	max_y_speed = y_speed
	force_hover = true
	gravity = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (not $DyingTimer.is_stopped()):
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	moving = activated
	
	# Update animation
	var animation
	if (health <= 0):
		animation = "dying"
	elif (moving):
		animation = "flying"
	else:
		animation = "idle"
	
	# Only change the animation if needed
	if (animated_sprite.animation != animation):
		animated_sprite.set_deferred("animation", animation)

# Overloaded function from parent class
func get_movement():
	if (moving):
		update_direction()
		return direction * Vector2(x_speed, y_speed)
	else:
		return Vector2(0, 0)

func update_direction():
	if (player):
		direction = (player.get_global_position() - global_position).normalized()
		animated_sprite.set_deferred("flip_h", velocity.x >= 0)

func take_damage(val):
	health = health - val if health - val < 100 else 100
	root.spawn_particle("bullet_impact_bloody", global_position)
	
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
