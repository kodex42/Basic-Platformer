extends Control

# Preloads
var bullet = preload("res://Bullet.tscn")
var player_instance = preload("res://Player.tscn")
var bullet_impact_particles = preload("res://BulletImpactParticles.tscn")
var enemy_spawner = preload("res://EnemySpawner.tscn")
var weapon = preload("res://Weapon.tscn")
var explosion = preload("res://Explosion.tscn")

# Nodes
onready var player = $Player

# State
var elapsed_time = 0.0
var recorded_time = 0.0
var recording = false
var action_queue = []
var bullet_stack = []
var clone_released = false
var doors_closed = false
var player_clone
var num_enemies = 0
var restartable = false
var release = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Load bullet stack
	for _i in range(500):
		var b = bullet.instance()
		b.global_position = Vector2(-1000, -1000)
		bullet_stack.append(b)
	
	# Get generated map
	generate_map()
	
	open_doors()

func generate_map():
	var map_tiles = $MapGenerator.get_nodes()
	for tile in map_tiles:
		$Map.add_child(tile)
	
	# Move player to start position
	player.global_position = $Map.get_node("Start/StartPosition").global_position
	$Player/GridSnapper.update_grid_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check input for window control
	check_input()
	# Increment elapsed time
	elapsed_time += delta
	if (recording and player):
		recorded_time += delta
		action_queue.push_front(player.position)
	
	# Record player actions and spawn a clone after a time
	if (recorded_time > 3 and not clone_released):
		clone_released = true
		player_clone = player_instance.instance()
		player_clone.recording = true
		player_clone.remove_from_group("player")
		player_clone.add_to_group("enemy")
		player_clone.add_to_group("crushing")
		player_clone.set_collision_layer_bit(0, false)
		player_clone.set_collision_layer_bit(1, true)
		player_clone.get_node("AnimatedSprite").modulate.r = 1.0
		player_clone.get_node("AnimatedSprite").modulate.g = 0.0
		player_clone.get_node("AnimatedSprite").modulate.b = 1.0
		player_clone.get_node("GridSnapper/Camera").current = false
		player_clone.get_node("UI/HealthContainer").hide()
		player_clone.get_node("MeleeHitbox").hide()
		player_clone.get_node("WeaponSprite").hide()
		player_clone.name = "PlayerClone"
		add_child(player_clone)
	if (clone_released):
		player_clone.position = action_queue.pop_back()
		player_clone.rotate(PI/32)

func check_input():
	# Exit the game
	if (Input.is_action_just_pressed("escape")):
		get_tree().quit()
	check_debug_input()

func check_debug_input():
	if (!release):
		var cheated = false
		# Player damage and healing
		if (Input.is_action_just_pressed("debug_self_damage")):
			$Player.take_damage(10)
			cheated = true
		if (Input.is_action_just_pressed("debug_self_heal")):
			$Player.take_damage(-10)
			cheated = true
			
		# Spawn enemies
		var enemy = null
		var spawner = enemy_spawner.instance()
		if (Input.is_action_just_pressed("spawn_enemy_1")):
			enemy = spawner.init_enemy("bat")
		if (Input.is_action_just_pressed("spawn_enemy_2")):
			enemy = spawner.init_enemy("green_wiggler")
		if (Input.is_action_just_pressed("spawn_enemy_3")):
			enemy = spawner.init_enemy("frog")
		if (Input.is_action_just_pressed("spawn_enemy_4")):
			enemy = spawner.init_enemy("red_wiggler")
		if (Input.is_action_just_pressed("spawn_enemy_5")):
			enemy = spawner.init_enemy("spider")
		if (Input.is_action_just_pressed("spawn_enemy_6")):
			enemy = spawner.init_enemy("ghost")
		if (Input.is_action_just_pressed("spawn_enemy_7")):
			enemy = spawner.init_enemy("ufo")
		if (Input.is_action_just_pressed("spawn_enemy_8")):
			enemy = spawner.init_enemy("sawblade")
		if (Input.is_action_just_pressed("spawn_enemy_9")):
			enemy = spawner.init_enemy("turret")
			enemy.set_direction(Vector2(1, 0)) # Right
		if (Input.is_action_just_pressed("spawn_enemy_10")):
			enemy = spawner.init_enemy("turret")
			enemy.set_direction(Vector2(0, -1)) # Up
		if (Input.is_action_just_pressed("spawn_enemy_11")):
			enemy = spawner.init_enemy("turret")
			enemy.set_direction(Vector2(-1, 0)) # Left
		if (Input.is_action_just_pressed("spawn_enemy_12")):
			enemy = spawner.init_enemy("turret")
			enemy.set_direction(Vector2(0, 1)) # Down
		if (enemy != null):
			add_child(spawner)
			spawner.set_global_position(get_global_mouse_position())
			spawner.start_spawning()
			cheated = true
			
		# Spawn items
		var item = null
		if (Input.is_action_just_pressed("spawn_weapon")):
			item = weapon.instance()
		if (Input.is_action_just_pressed("spawn_upgrade")):
			item = $RandomUpgradeSpawner.spawn()
		if (item != null):
			item.set_global_position(get_global_mouse_position())
			add_child(item)
			cheated = true
		
		# Log to console if cheats were used
		if (cheated):
			print("I know what you did...")
	if (restartable and Input.is_action_just_pressed("restart_game")):
		restart_game()

func disable_player_clone():
	if (clone_released):
		get_node("PlayerClone").kill()
		clone_released = false
	recording = false
	recorded_time = 0
	
	$DoppelgangerSpawnTimer.disconnect("timeout", self, "_on_DoppelgangerSpawnTimer_timeout")
	$DoppelgangerSpawnTimer.stop()

func restart_game():
	get_tree().reload_current_scene()

func spawn_particle(name, position, num = 1, scale = 1):
	var particle = null
	match name:
		"bullet_impact":
			particle = bullet_impact_particles.instance()
			particle.emitting = true
			particle.global_position = position
		"bullet_impact_bloody":
			particle = bullet_impact_particles.instance()
			particle.modulate = Color(1, 0, 0, 1)
			particle.emitting = true
			particle.global_position = position
		"bullet_impact_metal":
			particle = bullet_impact_particles.instance()
			particle.modulate = Color(0.5, 0.5, 0.5, 1)
			particle.emitting = true
			particle.global_position = position
	particle.amount *= num
	particle.scale.x = scale
	particle.scale.y = scale
	if (particle != null):
		add_child(particle)

func get_elapsed_time():
	return elapsed_time

func get_bullet_scene():
	return bullet_stack.pop_front()

func despawn_bullet(b):
	remove_child(b)
	b.global_position = Vector2(-1000, -1000)
	bullet_stack.append(b)

func change_enemy_count(val):
	num_enemies += val
	$GUI/EnemiesLeftLabel.text = "Enemies: " + str(num_enemies)
	if (num_enemies >= 1 and not doors_closed):
		$GUI/EnemiesLeftLabel.show()
		close_doors()
	if (num_enemies == 0 and doors_closed):
		$GUI/EnemiesLeftLabel.hide()
		open_doors()

func open_doors():
	for tile_set in $Map.get_children():
		tile_set.get_node("Doors").hide()
		tile_set.get_node("Doors").set_collision_layer_bit(2, false)
	doors_closed = false

func close_doors():
	for tile_set in $Map.get_children():
		tile_set.get_node("Doors").show()
		tile_set.get_node("Doors").set_collision_layer_bit(2, true)
	doors_closed = true

func create_explosion(pos):
	var e = explosion.instance()
	e.global_position = pos
	add_child(e)

func update_weapon_ui(weapons):
	for n in $GUI/EquippedWeaponsUI.get_children():
		$GUI/EquippedWeaponsUI.remove_child(n)
		n.queue_free()
	for w in weapons:
		var sprite = TextureRect.new()
		sprite.texture = $SpriteLibrary.get_resource(w.name)
		$GUI/EquippedWeaponsUI.add_child(sprite)

func remove_weapon_from_ui(index):
	var children = $GUI/EquippedWeaponsUI.get_children()
	$GUI/EquippedWeaponsUI.get_child(index).queue_free()
	$GUI/EquippedWeaponsUI.remove_child(children[index])
	update_weapon_ui_index($GUI/EquippedWeaponsUI.get_children().size()-1)

func update_weapon_ui_index(i):
	for child in $GUI/EquippedWeaponsUI.get_children():
		child.modulate = Color(0.2, 0.2, 0.2, 0.5)
	$GUI/EquippedWeaponsUI.get_children()[i].modulate = Color(1, 1, 1, 1)

func update_upgrade_ui(player_upgrades, bullet_upgrades, weapon_upgrades):
	for n in $GUI/CollectedUpgradesUI.get_children():
		n.queue_free()
	
	for pu in player_upgrades:
		add_upgrade_to_ui(pu, Color(0.5, 0.5, 1, 1))
	for bu in bullet_upgrades:
		add_upgrade_to_ui(bu, Color(1, 0.5, 0.5, 1))
	for wu in weapon_upgrades:
		var eq = $Player.equipped
		if (wu.type == eq.name):
			add_upgrade_to_ui(wu, Color(0.5, 1, 0.5, 1))

func update_upgrade_description_ui(showing, desc:String="nothing"):
	$GUI/CenterContainer/UpgradeDescription.visible = showing
	$GUI/CenterContainer/UpgradeDescription.text = desc

func add_upgrade_to_ui(u, tint):
	var cont = PanelContainer.new()
	cont.modulate = tint
	var tex = TextureRect.new()
	tex.texture = u.img
	cont.add_child(tex)
	$GUI/CollectedUpgradesUI.add_child(cont)

func _on_Enemy_spawn_bullet(dir, start_pos, start_rot, damage, _enemy, mods):
	var bullet_instance = get_bullet_scene()
	if (not bullet_instance): return
	for m in mods:
		m.func_ref.call_func(bullet_instance)
#	bullet_instance.add_to_group("enemy")
	bullet_instance.set_collision_layer_bit(1, true)
	bullet_instance.position = start_pos
	bullet_instance.rotation = start_rot
	bullet_instance.set_deferred("modulate", Color(1.0, 0.5, 0.5, 1.0))
	bullet_instance.set_damage(damage)
	bullet_instance.set_speed(300)
	bullet_instance.fire(dir, "enemy")
	add_child(bullet_instance)

func _on_Enemy_killed(pos):
	change_enemy_count(-1)
	var r = randi() % 3
	if (r == 0):
		var drop = $RandomDropSpawner.spawn()
		drop.global_position = pos
		add_child(drop)
		
func _on_Boss_killed(pos):
	change_enemy_count(-1)
	
	spawn_particle("bullet_impact_bloody", pos, 10, 3)
	for i in range(5):
		var drop = $RandomDropSpawner.spawn()
		drop.global_position = pos
		add_child(drop)
	for i in range(3):
		var upgrade = $RandomUpgradeSpawner.spawn()
		upgrade.global_position = pos
		add_child(upgrade)

func _on_Player_spawn_bullet(dir, start_pos, start_rot, damage, mods):
	var bullet_instance = get_bullet_scene()
	if (not bullet_instance): return
	for m in mods:
		m.func_ref.call_func(bullet_instance)
#	bullet_instance.add_to_group("player")
	bullet_instance.set_collision_layer_bit(0, true)
	bullet_instance.position = start_pos
	bullet_instance.rotation = start_rot
	bullet_instance.set_damage(damage)
	bullet_instance.fire(dir, "player")
	add_child(bullet_instance)

func _on_DoppelgangerSpawnTimer_timeout():
	recording = true

func _on_DeathPlane_body_entered(body):
	if (body.is_in_group("player") or body.is_in_group("enemy")):
		body.kill()

func _on_Player_has_key_changed(has_key):
	$GUI/KeyIndicator.texture = $SpriteLibrary.get_resource("filled_key_ui" if has_key else "empty_key_ui")

func _on_Player_player_killed():
	disable_player_clone()
	$GUI/GameOverScreen/Tween.interpolate_property($GUI/GameOverScreen, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$GUI/GameOverScreen/Tween.start()
	restartable = true
