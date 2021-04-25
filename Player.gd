extends KinematicBody2D

# Signals
signal spawn_bullet(dir, start_pos, start_rot, damage, bullet_upgrades)
signal health_changed(health)
signal ammo_changed(ammo, ammo_max)
signal num_coins_changed(amount, diff)
signal has_key_changed(has_key)
signal player_killed()

# Preloads
var weapon_scene = preload("res://Weapon.tscn")

# Nodes
onready var root : Node = get_node("/root/Main")
onready var library : ResourcePreloader = root.get_node("SpriteLibrary")
onready var arsenal : ResourcePreloader = root.get_node("ArsenalStats")
onready var ammo_ui : VBoxContainer = root.get_node("GUI").get_node("AmmoUI")
onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var weapon_sprite : Sprite = $WeaponSprite
onready var invuln_timer : Timer = $InvulnerabilityTimer
onready var melee_attack_timer : Timer = $MeleeAttackTimer
onready var melee_hit_box : Area2D = $MeleeHitbox
onready var melee_hit_box_shape : CollisionShape2D = $MeleeHitbox/HitboxShape
onready var hit_box : Area2D = $HitCollisionArea
onready var hit_box_shape : CollisionShape2D = $HitCollisionArea/HitCollisionShape
onready var interaction_prompt_label : Label = $UI/InteractionPromptLabel
onready var interaction_context_texture : TextureRect = $UI/CenterContainer/InteractionContext

# Exports
export var snap = false # Snapping not only let's us know when we can jump, but also helps with slope climbing
export var acceleration = 0.25
export var friction = 0.35
export var damping = 0.05
export var move_speed = 200
export var jump_force = 400
export var gravity = 900
export var slope_slide_threshold = 50.0

# State
var health = 100
var direction_x
var velocity = Vector2()
var can_jump_cancel = false
var rotation_time = -1
var rotation_factor = 0
var weapons = []
var equip_index = -1
var equipped
var rng = RandomNumberGenerator.new()
var recording = false
var control = true
var coins = 0
var has_key = false
var context = []
var is_being_crushed = [
	false,
	false,
	false,
	false
]

# Upgrades
var player_upgrades = []
var on_damage_upgrades = []
var on_contact_upgrades = []
var bullet_upgrades = []
var weapon_upgrades = []

func _ready():
	if (!recording):
		take_damage(0, Vector2())
		mod_coins(5)
		equip_weapon(arsenal.get_default_weapon())
		remove_context_ui()

func _process(delta):
	if (not recording):
		# Make the character flash when invulnerable
		if (!invuln_timer.is_stopped()):
			animated_sprite.modulate.a = 0.2 if Engine.get_frames_drawn() % 4 == 0 else 1.0
		else:
			animated_sprite.modulate.a = 1.0
		
		# Show or hide UI elements based on equipped weapon
		if (equipped):
			weapon_sprite.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if (equipped.range != "melee"):
				ammo_ui.show()
				$MeleeHitbox/HitboxShape/AimTexture.hide()
			else:
				if (equipped.time_shot + equipped.fire_rate < get_parent().get_elapsed_time()):
					$MeleeHitbox/HitboxShape/AimTexture.show()
				else:
					$MeleeHitbox/HitboxShape/AimTexture.hide()
		else:
			weapon_sprite.hide()
			ammo_ui.hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		# Update animations
		if (control):
			update_animation(delta)
		
		# Check death conditions
		if (health <= 0):
			print("Player Killed!")
		if ((is_being_crushed[0] and is_being_crushed[2]) or (is_being_crushed[1] and is_being_crushed[3])):
			kill()
			print("Player Crushed!")

func _physics_process(delta):
	if (not recording):
		if (control):
			# Check controls and apply forces / activate abilities
			check_controls()
		
		# Apply gravity force
		velocity.y += gravity * delta
		
		# Clamping
#		velocity.x = clamp(velocity.x, -MAX_X_SPEED, MAX_X_SPEED)
#		velocity.y = clamp(velocity.y, -MAX_Y_SPEED, MAX_Y_SPEED)
		
		# Configure snap vector if player is snapped to the ground
		var snap_vector = Vector2(0, 8) if snap else Vector2() # Ternary operation
		velocity = move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, slope_slide_threshold)
		
		if (is_on_floor() and (Input.is_action_just_released("move_right") or Input.is_action_just_released("move_left"))):
			velocity.y = 0 # Prevents unintended jumps when moving up slopes
		
		# Reset snap bool if we have just landed
		var just_landed = is_on_floor() and not snap
		if (just_landed and $KnockbackTimer.is_stopped()):
			snap = true

func check_controls():
	# Check lateral forces from controls
	direction_x = 0
	if (Input.is_action_pressed("move_right")):
		direction_x += 1
	if (Input.is_action_pressed("move_left")):
		direction_x -= 1
	
	# Linear interpolation for smoother movement
	if (direction_x != 0):
		velocity.x = lerp(velocity.x, direction_x * move_speed, acceleration)
	elif (snap):
		velocity.x = lerp(velocity.x, 0, friction)
	else:
		velocity.x = lerp(velocity.x, 0, damping)
	
	# Dropping
	if (Input.is_action_pressed("crouch") and is_on_floor()):
		snap = false
		try_drop()
		
	# Jumping
	if (Input.is_action_just_pressed("jump") and is_on_floor() and snap):
		snap = false
		jump()
	elif (Input.is_action_just_released("jump")):
		jump_cut()

	# Shooting
	if (equipped and equipped.auto):
		if (Input.is_action_pressed("shoot")):
			shoot(get_global_mouse_position())
		if (Input.is_action_pressed("bunt_shot") and not is_on_floor()):
			bunt_shot()
	elif (equipped):
		if (Input.is_action_just_pressed("shoot")):
			shoot(get_global_mouse_position())
		if (Input.is_action_just_pressed("bunt_shot") and not is_on_floor()):
			bunt_shot()
	
	# Changing weapon
	if (Input.is_action_just_released("next_weapon") and weapons.size() > 0):
		var index = equip_index + 1 if equip_index + 1 < weapons.size() else 0
		equip_at_index(index)
	
	if (Input.is_action_just_released("previous_weapon") and weapons.size() > 0):
		var index = equip_index - 1 if equip_index - 1 > -1 else weapons.size() - 1
		equip_at_index(index)
	
	if (Input.is_action_just_pressed("equip_melee") and weapons.size() >= 1):
		equip_at_index(0)
	
	if (Input.is_action_just_pressed("equip_secondary") and weapons.size() >= 2):
		equip_at_index(1)
	
	if (Input.is_action_just_pressed("equip_primary") and weapons.size() == 3):
		equip_at_index(2)
	
	# Context sensitive interaction
	if (Input.is_action_just_pressed("interact") and context.size() > 0):
		interact()

func update_animation(delta):
	var animation
	if (abs(velocity.x) > 10.0):
		if (Input.get_action_strength("move_right") - Input.get_action_strength("move_left") == 0):
			animation = "sliding"
		else:
			animation = "walking"
		if (not equipped):
			var flip = velocity.x < 0
			animated_sprite.set_deferred("flip_h", flip)
	else:
		animation = "standing"
	
	if (equipped):
		var ang = (get_global_mouse_position() - get_global_position()).angle()
		if (ang < -PI/2 or ang > PI/2):
			animated_sprite.set_deferred("flip_h", true)
		else:
			animated_sprite.set_deferred("flip_h", false)
			
	if (not is_on_floor()):
		animation = "jumping"
	
	# Mid-air rotation for bunt shot
	if (rotation_time != -1):
		animated_sprite.rotate(2*PI*delta/rotation_factor)
		rotation_time -= delta
		animation = "sliding"
	
	# Reset rotation while grounded or when rotation is finished
	if (is_on_floor() or rotation_time <= 0):
		reset_rotation()
	
	# Have guns point at the mouse cursor while not rotating
	if (equipped and rotation_time == -1):
		weapon_sprite.set_is_aiming(true)
	else:
		weapon_sprite.set_is_aiming(false)
	
	# Set appointed animation
	if (animated_sprite.animation != animation):
		animated_sprite.set_deferred("animation", animation)

func reset_rotation():
	rotation_time = -1
	rotation_factor = 0
	animated_sprite.set_deferred("rotation", 0)

func jump():
	velocity.y = -jump_force
	can_jump_cancel = true

func jump_cut():
	if (velocity.y < -100 and can_jump_cancel):
		velocity.y = -100

func shoot(end_pos):
	var time = get_parent().get_elapsed_time()
	if (equipped.range != "melee"):
		if (equipped.time_shot + equipped.fire_rate < time and equipped.shots > 0):
			equipped.time_shot = time
			# Calculate initial offset to position bullet next to muzzle of gun
			var offset = (weapon_sprite.offset*2).rotated(weapon_sprite.rotation)
			var start_pos = weapon_sprite.get_global_position() + offset
			var direction = (end_pos - start_pos).normalized()
			spawn_bullet(start_pos, direction)
	else:
		if (equipped.time_shot + equipped.fire_rate < time):
			equipped.time_shot = time
			create_melee_hitbox()

func bunt_shot():
	var time = get_parent().get_elapsed_time()
	if (equipped.range != "melee") :
		if (equipped.time_shot + equipped.fire_rate < time and equipped.shots > 0):
			weapon_sprite.rotation = PI/2
			weapon_sprite.set_is_aiming(false)
			rotation_time = equipped.fire_rate
			rotation_factor = rotation_time
			equipped.time_shot = time
			# Calculate initial offset to position bullet next to muzzle of gun
			var start_pos = global_position
			var direction = Vector2(0, 1)
			spawn_bullet(start_pos, direction)
	else:
		if (equipped.time_shot + equipped.fire_rate < time):
			equipped.time_shot = time
			melee_hit_box.rotate_to_vector(Vector2(0, 1))
			create_melee_hitbox()

func spawn_bullet(start_pos, direction):
	var delta_v = Vector2()
	# Apply random rotation to direction based on accuracy
	var max_range_of_deviation = (1 - equipped.accuracy) * PI
	for _i in range(equipped.multishot):
		var deviation = (rng.randf_range(-max_range_of_deviation, max_range_of_deviation))/2
		var deviated_dir = direction.rotated(deviation)
		delta_v += -(deviated_dir) * equipped.recoil
		emit_signal("spawn_bullet", deviated_dir, start_pos + direction*20, $WeaponSprite.rotation, equipped.damage, bullet_upgrades)
	if (not snap):
		velocity *= 0.35 # Damp current speed for more impact
		velocity += delta_v
	can_jump_cancel = false
	equipped.shots -= 1
	emit_signal("ammo_changed", equipped.shots, equipped.max_shots)

func create_melee_hitbox():
	melee_attack_timer.start()
	melee_hit_box.get_node("HitboxShape").disabled = false
	melee_hit_box.get_node("HitboxShape/AimTexture").hide()
	melee_hit_box.get_node("HitboxShape/AnimatedSprite").show()
	melee_hit_box.get_node("HitboxShape/AnimatedSprite").play("default")
	$MeleeHitbox/HitboxShape/AimTexture.hide()

func try_drop():
	for i in get_slide_count():
		var check = get_slide_collision(i)
		if (check.collider.is_in_group("semisolid")):
			position.y += 1

func get_weapons():
	return weapons

func equip_weapon(weapon):
	for i in range(weapons.size()):
		var w = weapons[i]
		if (w.name == weapon.name):
			equip_at_index(i)
			reload_max()
			return
		if (w.type == weapon.type):
			equip_at_index(i)
			drop_current_weapon()
			break
	weapons.append(weapon)
	weapons.sort_custom(self, "weaponComparison")
	root.update_weapon_ui(weapons)
	equip_at_index(weapons.find(weapon))

func equip_at_index(index):
	equipped = weapons[index]
	equip_index = index
	weapon_sprite.set_deferred("texture", library.get_resource(equipped.name))
	weapon_sprite.is_melee = equipped.range == "melee"
	# Reset rotation in case switching while airborne
	if (!is_on_floor()):
		rotation_time = -1
		rotation_factor = 0
		animated_sprite.set_deferred("rotation", 0)
		weapon_sprite.set_deferred("rotation", 0)
	# Update UI
	emit_signal("ammo_changed", equipped.shots, equipped.max_shots)
	root.update_weapon_ui_index(equip_index)
	root.update_upgrade_ui(player_upgrades, bullet_upgrades, weapon_upgrades)
	if (equipped.range == "melee"):
		ammo_ui.hide()
		melee_hit_box.set_damage(equipped.damage)

func drop_current_weapon():
	if (equipped.name == "knife"):
		var index = equip_index + 1 if equip_index + 1 < weapons.size() else 0
		equip_at_index(index)
	var stats = equipped
	
	weapons.remove(equip_index)
	root.remove_weapon_from_ui(equip_index)
	equip_index = equip_index - 1 if equip_index - 1 >= 0 else weapons.size() - 1
	equip_at_index(equip_index)
	
	var weapon_node = weapon_scene.instance()
	weapon_node.create_from_drop(stats)
	weapon_node.global_position = global_position
	root.add_child(weapon_node)

func weaponComparison(w1, w2):
	if (w1.type == "melee" and w2.type != "melee"):
		return true
	elif (w2.type == "melee" and w1.type != "melee"):
		return false
	elif (w1.type == "secondary" and w2.type == "primary"):
		return true
	return false

func set_has_key(b):
	has_key = b
	emit_signal("has_key_changed", has_key)

func collect_key():
	set_has_key(true)

func remove_key():
	set_has_key(false)

func collect_upgrade(upgrade):
	match upgrade.type:
		"player":
			player_upgrades.append(upgrade)
		"bullet":
			bullet_upgrades.append(upgrade)
		"weapon":
			if ((upgrade.subtype == "gun" and equipped.type != "melee")):
				weapon_upgrades.append(upgrade)
				upgrade.type = equipped.name # For UI
				upgrade.func_ref.call_func(equipped)
			elif (upgrade.subtype == "melee"):
				var weap = weapons[0]
				weapon_upgrades.append(upgrade)
				upgrade.type = weap.name # For UI
				upgrade.func_ref.call_func(weap)
			else:
				return false
	match upgrade.subtype:
		"immediate":
			upgrade.func_ref.call_func(self)
		"onDamage":
			on_damage_upgrades.append(upgrade)
		"onContact":
			on_contact_upgrades.append(upgrade)
	root.update_upgrade_ui(player_upgrades, bullet_upgrades, weapon_upgrades)
	return true

func take_damage(val, contact:Vector2 = global_position + Vector2(direction_x, 0)):
	if (val > 0 and invuln_timer.is_stopped()):
		for u in on_damage_upgrades:
			val = u.func_ref.call_func(val)
		hit_box.set_deferred("monitoring", false)
		invuln_timer.start()
		apply_knockback(contact, 100, false)
		change_health(val)
	elif (val < 0):
		change_health(val)

func heal(val):
	take_damage(-val, Vector2())

func change_health(val):
	health = health - val if health - val < 100 else 100
	if (health <= 0):
		kill()
	emit_signal("health_changed", health)

func kill():
	if (not recording):
		$GridSnapper/Camera.current = false
		var newcam = $GridSnapper/Camera.duplicate()
		newcam.current = true
		newcam.global_position = $GridSnapper/Camera.global_position
		root.add_child(newcam)
		emit_signal("player_killed")
	root.spawn_particle("bullet_impact_bloody", global_position, 4, 2)
	emit_signal("health_changed", 0)
	queue_free()

func apply_knockback(contact, mag, with_control):
	var diff = contact - global_position
	velocity += -diff.normalized() * mag
	snap = false
	if (not with_control):
		control = false
		animated_sprite.set_deferred("animation", "sliding")
		$KnockbackTimer.start()

func check_collision_with_subshape(obj, obj_shape, col_shape):
	var contact_avg = Vector2(0, 0)
	if (not recording and obj.is_in_group("enemy")):
		var contacts = get_points_of_contact_with_shape(obj, obj_shape, col_shape)
		if (contacts.size() > 0): # Check the size of the contacts array just in case movement shenanigans occur
			# Find the average of each point of contact
			for vec in contacts:
				contact_avg += vec
			contact_avg /= contacts.size()
	return contact_avg

func get_points_of_contact_with_shape(obj, obj_shape, col_shape):
	# Get both shape objects to find intersecting points
	var this_shape = col_shape
	var their_shape = obj.shape_owner_get_owner(obj.shape_find_owner(obj_shape))
	return this_shape.shape.collide_and_get_contacts(this_shape.get_global_transform(), their_shape.shape, their_shape.get_global_transform())

func get_damage():
	if (recording):
		return 35

func reload(percentage):
	var num = ceil(equipped.max_shots * percentage)
	var weapon = equipped
	if (equipped.range == "melee"): 
		weapon = weapons[1]
	weapon.shots += num
	if (weapon.shots > weapon.max_shots): weapon.shots = weapon.max_shots
	emit_signal("ammo_changed", equipped.shots, equipped.max_shots)

func reload_max():
	reload(100)

func mod_coins(val):
	coins += val
	emit_signal("num_coins_changed", coins, val)

func can_pay(val):
	return coins >= val

func attempt_enemy_collision_with_player(body, body_shape, sub_shape):
	if (body.is_in_group("enemy")):
		var avg = check_collision_with_subshape(body, body_shape, sub_shape)
		if (avg.length() > 0 and body.get_damage() > 0):
			take_damage(body.get_damage(), avg)
			for u in on_contact_upgrades:
				u.func_ref.call_func(body)
			if (body.is_in_group("projectile")):
				body.queue_free()
	elif (body.is_in_group("needs_key")):
		if (has_key):
			body.queue_free()
			remove_key()

func attempt_enemy_collision_with_melee(body):
	if ("deflecting" in weapons[0] and body.is_in_group("projectile")):
		body.kill()
	elif (!body.is_in_group("enemy")):
		return
	var angle = rad2deg(melee_hit_box.position.angle())
	if (angle < 135 and angle > 45): # Player swung weapon downwards with right click
		velocity.y *= 0 # Damp current y velocity for consistency
		apply_knockback(melee_hit_box.global_position, equipped.recoil, true)
		rotation_time = equipped.fire_rate / 2
		rotation_factor = rotation_time

func interact():
	context[0].interact(self)

func add_context(ctx):
	context.push_front(ctx)
	set_context(ctx)

func set_context(ctx):
	if (!ctx.is_in_group("no_interaction_preview")):
		interaction_context_texture.texture = ctx.get_node("Sprite").texture.duplicate()
		interaction_context_texture.show()
	if (ctx.is_in_group("upgrade")):
		root.update_upgrade_description_ui(true, ctx.desc)
	interaction_prompt_label.show()

func remove_context(ctx):
	context.erase(ctx)
	if (context.size() == 0):
		remove_context_ui()
	else:
		set_context(context[0])

func remove_context_ui():
	interaction_context_texture.hide()
	interaction_prompt_label.hide()
	root.update_upgrade_description_ui(false)

func check_crushing(body, dir, is_crushing):
	if (body.is_in_group("crushing") or body.is_in_group("solid")):
		is_being_crushed[dir] = is_crushing

func _on_MeleeAttackTimer_timeout():
	melee_hit_box.get_node("HitboxShape").disabled = true
	melee_hit_box.get_node("HitboxShape/AnimatedSprite").hide()
	melee_hit_box.get_node("HitboxShape/AnimatedSprite").stop()
	melee_hit_box.get_node("HitboxShape/AnimatedSprite").frame = 0
	$MeleeHitbox/HitboxShape/AimTexture.show()

func _on_InvulnerabilityTimer_timeout():
	hit_box.set_deferred("monitoring", true)

func _on_KnockbackTimer_timeout():
	control = true

func _on_HitCollisionArea_area_shape_entered(_area_id, area, area_shape, _self_shape):
	attempt_enemy_collision_with_player(area, area_shape, hit_box_shape)

func _on_HitCollisionArea_body_shape_entered(_body_id, body, body_shape, _area_shape):
	attempt_enemy_collision_with_player(body, body_shape, hit_box_shape)

func _on_MeleeHitbox_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	attempt_enemy_collision_with_melee(area)

func _on_MeleeHitbox_body_shape_entered(_body_id, body, _body_shape, _area_shape):
	attempt_enemy_collision_with_melee(body)

func _on_RightCrushArea_body_entered(body):
	check_crushing(body, 2, true)

func _on_RightCrushArea_body_exited(body):
	check_crushing(body, 2, false)

func _on_UpCrushArea_body_entered(body):
	check_crushing(body, 1, true)

func _on_UpCrushArea_body_exited(body):
	check_crushing(body, 1, false)

func _on_LeftCrushArea_body_entered(body):
	check_crushing(body, 0, true)

func _on_LeftCrushArea_body_exited(body):
	check_crushing(body, 0, false)

func _on_DownCrushArea_body_entered(body):
	check_crushing(body, 3, true)

func _on_DownCrushArea_body_exited(body):
	check_crushing(body, 3, false)
