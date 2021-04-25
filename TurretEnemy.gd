extends "res://Enemy.gd"

# Children
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var sprite_tint_tween : Tween = $AnimatedSprite/TintTween
onready var hit_box : Area2D = $HitCollision
onready var hit_box_shape : CollisionShape2D = $HitCollision/HitCollisionShape
onready var firing_direction_cast : RayCast2D = $FiringDirectionCast
onready var firing_charging_timer : Timer = $FiringChargingTimer
onready var firing_timer : Timer = $FiringTimer
onready var firing_cooldown_timer : Timer = $FiringCooldownTimer
onready var firing_light : Sprite = $FiringLight
onready var laser_beam : Node2D = $LaserBeam

# State
export var direction = Vector2(0, 0)
var charging = false
var firing = false
var player_body = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_health(50)
	contact_damage = 0
	activated = true
	if (direction.x == 0):
		force_hover = true
		gravity = 0
	update_direction()
	update_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (not $DyingTimer.is_stopped()):
		modulate = Color(0.5, 0.5, 0.5, 1)
	
	if (firing_direction_cast.is_colliding()):
		var collision = firing_direction_cast.get_collision_point()
		var length = (collision - global_position).length()
		hit_box.position = (collision - global_position) / 2
		if (direction.x != 0):
			hit_box.scale = Vector2(length/2, 3)
		else:
			hit_box.scale = Vector2(3, length/2)
		laser_beam.set_end_position(collision)
	
	if (activated):
		if (firing_charging_timer.is_stopped() and firing_timer.is_stopped() and firing_cooldown_timer.is_stopped()):
			firing_cooldown_timer.start()
		if (player_body):
			player.take_damage(30, firing_direction_cast.get_collision_point())
	update_animation()

# Overloaded function from parent class
func get_movement():
	return Vector2(0, 0)

func set_direction(dir):
	direction = dir

func update_direction():
	match (direction):
		Vector2(1, 0):
			firing_light.offset = Vector2(15, 1)
			pass
		Vector2(0, 1):
			firing_light.offset = Vector2(1, 15)
			pass
		Vector2(-1, 0):
			firing_light.offset = Vector2(-15, 1)
			pass
		Vector2(0, -1):
			firing_light.offset = Vector2(1, -15)
			pass
	laser_beam.position = direction * 10
	firing_direction_cast.cast_to = direction * 630

func update_animation():
	var animation = ""
	if (direction.x != 0):
		animation = "horizontal"
	else:
		animation = "vertical"
	if (firing):
		animation = animation+"_firing"
	elif (charging):
		animation = animation+"_charging"
	# Only change the animation if needed
	if (animated_sprite.animation != animation):
		animated_sprite.set_deferred("animation", animation)
	animated_sprite.set_deferred("flip_h", direction.x == 1)
	animated_sprite.set_deferred("flip_v", direction.y == -1)

func take_damage(val):
	pass

func _on_HitCollision_area_entered(area):
	if (area.is_in_group("melee")):
		take_damage(area.get_damage())
	if (area.is_in_group("projectile")):
		take_damage(area.get_damage())
		area.queue_free()

func _on_DyingTimer_timeout():
	kill()

func _on_FiringChargingTimer_timeout():
	firing = true
	charging = false
	firing_timer.start()
	hit_box_shape.disabled = false
	laser_beam.show()

func _on_FiringTimer_timeout():
	firing = false
	firing_light.modulate.a = 0
	hit_box_shape.disabled = true
	laser_beam.hide()
	firing_cooldown_timer.start()

func _on_FiringCooldownTimer_timeout():
	charging = true
	var tween = firing_light.get_node("Tween")
	tween.interpolate_property(firing_light, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	firing_charging_timer.start()

func _on_HitCollision_body_entered(body):
	if (body.is_in_group("player")):
		player_body = body

func _on_HitCollision_body_exited(body):
	if (body.is_in_group("player")):
		player_body = null
