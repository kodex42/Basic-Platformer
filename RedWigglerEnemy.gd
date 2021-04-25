extends "res://Enemy.gd"

# Children
onready var floor_ray_cast : RayCast2D = $FloorRayCast
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var hit_box : CollisionShape2D = $HitCollision/HitCollisionShape
onready var collision_box : CollisionShape2D = $Collision
onready var sprite_tint_tween : Tween = $AnimatedSprite/TintTween

# State
var segments = []
var num_segments = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_health(25)
	contact_damage = 10
	gravity = 0
	force_stationary = true
	$FiringTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (not $DyingTimer.is_stopped()):
		modulate = Color(0.5, 0.5, 0.5, 1)
	# Count the number of required segments
	if (floor_ray_cast.is_colliding() and floor_ray_cast.enabled):
		var collision = floor_ray_cast.get_collision_point()
		# Each 21 pixel long stretch of distance between the wiggler and the collider means another segment
		for i in range(0, ceil(global_position.distance_to(collision) / 21)):
			num_segments += 1
			var seg = animated_sprite.duplicate()
			seg.translate(Vector2(0, num_segments*(20)))
			seg.set_deferred("frames", animated_sprite.frames)
			seg.frame = 0
			seg.play("seg standing")
			if (i % 2 == 1):
				seg.set_deferred("flip_h", true)
			segments.append(seg)
			add_child(seg)
		# Extend collision and hit boxes to match the size of the wiggler + segments
		collision_box.apply_scale(Vector2(1, num_segments+1))
		collision_box.translate(Vector2(0, 10*num_segments))
		hit_box.apply_scale(Vector2(1, num_segments+1))
		hit_box.translate(Vector2(0, 10*num_segments))
		# Disable floor ray cast
		floor_ray_cast.set_deferred("enabled", false)
		# Play top animated sprite for sync
		animated_sprite.frame = 0
		animated_sprite.play("standing")

# Overloaded function from parent class
func get_movement():
	return Vector2(0, 0)

func take_damage(val):
	health = health - val if health - val < 100 else 100
	root.spawn_particle("bullet_impact_bloody", global_position)
	
	# Kill node after a while if health is <= 0
	if (health <= 0):
		activated = false
		$Collision.set_deferred("disabled", true)
		$HitCollision/HitCollisionShape.set_deferred("disabled", true)
		$DyingTimer.start()
		animated_sprite.set_deferred("animation", "dying")
		for seg in segments:
			seg.set_deferred("animation", "seg dying")
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
