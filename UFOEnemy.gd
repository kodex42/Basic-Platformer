extends "res://Enemy.gd"

# Children
onready var wall_ray_cast : RayCast2D = $WallRayCast
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var sprite_tint_tween : Tween = $AnimatedSprite/TintTween

# State
var speed = 100
var direction = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_health(30)
	update_direction()
	contact_damage = 15
	max_x_speed = speed
	force_hover = true
	gravity = 0
	$FiringTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (not $DyingTimer.is_stopped()):
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	# Update animation
	var animation
	if (health <= 0):
		animation = "dying"
	elif (activated):
		animation = "flying"
	else:
		animation = "idle"
	
	# Only change the animation if needed
	if (animated_sprite.animation != animation):
		animated_sprite.set_deferred("animation", animation)

# Overloaded function from parent class
func get_movement():
	# Check results of raycasts for movement change
	if (wall_ray_cast.is_colliding()): # We are approaching a wall
		direction = -direction
		update_direction()
		
	return Vector2(direction*speed, 0)

func update_direction():
	wall_ray_cast.set_cast_to(Vector2(16*direction, 0))
	animated_sprite.set_deferred("flip_h", direction == 1)

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

func _on_FiringTimer_timeout():
	if ($DyingTimer.is_stopped()):
		fire_bullet_at_player(20)
