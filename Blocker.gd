extends "res://Boss.gd"

# Enum
enum States {
	GO_HOME,
	AIMING,
	MOVING,
	COOLDOWN
}

# State
var current_state = States.GO_HOME
var home = Vector2()
var dest = Vector2()
var dir = Vector2()
var raycast = null

func _ready():
	set_max_health(200)
	home = global_position
	$AnimatedSprite.play("idle")

func act(delta):
	if (health > 0):
		match (current_state):
			States.GO_HOME:
				go_home(delta)
			States.AIMING:
				if (!player):
					continue
				aim(delta)
			States.MOVING:
				if (!player):
					continue
				move(delta)
			States.COOLDOWN:
				cooldown(delta)
	else:
		move_and_slide(Vector2(0, 1)*200)

func go_home(_delta):
	if ($AnimatedSprite.animation != "idle"):
		$AnimatedSprite.play("idle")
	dir = global_position.direction_to(home)
	position += dir * 3
	if (global_position.distance_to(home) < 3):
		go_to_next_state()

func aim(_delta):
	if ($AimingTimer.is_stopped()):
		$AimingTimer.start()
	var dist = 250
	var angle = rad2deg(home.angle_to_point(player.get_global_position()))
	if (angle > 135 or angle < -135):
		dest = player.get_global_position() + Vector2(-dist, 0)
	elif (angle <= 135 and angle > 45):
		dest = player.get_global_position() + Vector2(0, dist/25)
	elif (angle <= 45 and angle > -45):
		dest = player.get_global_position() + Vector2(dist, 0)
	else:
		dest = player.get_global_position() + Vector2(0, -dist)
	dir = global_position.direction_to(dest) * 200
	
	if (global_position.distance_to(dest) > 3):
		move_and_slide(dir)
	
	if ($AnimatedSprite.animation != "prepare" and $AimingTimer.time_left < 0.5):
		$AnimatedSprite.play("prepare")

func move(_delta):
	if (dir == null):
		add_to_group("crushing")
		var angle = rad2deg(global_position.angle_to_point(player.get_global_position()))
		if (angle > 135 or angle < -135):
			dir = Vector2(1, 0)
			raycast = $RightCast
			$AnimatedSprite.play("moving_right")
		elif (angle <= 135 and angle > 45):
			dir = Vector2(0, -1)
			raycast = $UpCast
			$AnimatedSprite.play("moving_up")
		elif (angle <= 45 and angle > -45):
			dir = Vector2(-1, 0)
			raycast = $LeftCast
			$AnimatedSprite.play("moving_left")
		else:
			dir = Vector2(0, 1)
			raycast = $DownCast
			$AnimatedSprite.play("moving_down")
		raycast.enabled = true
	position += dir * 12
	
	if (raycast.is_colliding()):
		raycast.enabled = false
		go_to_next_state()

func cooldown(_delta):
	if ($CooldownTimer.is_stopped()):
		remove_from_group("crushing")
		$CooldownTimer.start()
		home.x = global_position.x
		$AnimatedSprite.play("impact")

func go_to_next_state():
	match (current_state):
		States.GO_HOME:
			current_state = States.AIMING
		States.AIMING:
			current_state = States.MOVING
		States.MOVING:
			current_state = States.COOLDOWN
		States.COOLDOWN:
			current_state = States.GO_HOME

func take_damage(val):
	.take_damage(val)
	root.spawn_particle("bullet_impact_bloody", global_position)
	
	# Kill node after a while if health is <= 0
	if (health <= 0):
		add_to_group("crushing")
		$DyingTimer.start()
		$AnimatedSprite.play("dying")
		modulate = Color(0.7, 0.7, 0.7, 1)
	else:
		var tint = Color()
		if (val > 0):
			tint = Color(1, 0.3, 0.3, 1)
		elif (val == 0):
			tint = Color(0.3, 0.3, 1, 1)
		else:
			tint = Color(0.3, 1, 0.3, 1)
		
		$Tween.interpolate_property(self, "modulate", tint, Color(1, 1, 1, 1), 0.8, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_CooldownTimer_timeout():
	if (health > 0):
		go_to_next_state()

func _on_AimingTimer_timeout():
	if (health > 0):
		dir = null
		go_to_next_state()

func _on_DyingTimer_timeout():
	kill()

func _on_HitCollision_area_entered(area):
	if (area.is_in_group("melee")):
		take_damage(area.get_damage())
	if (area.is_in_group("projectile")):
		take_damage(area.get_damage())
		area.queue_free()
