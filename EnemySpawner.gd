extends Position2D

# Preloads
var spider_enemy = preload("res://SpiderEnemy.tscn")
var green_wiggler_enemy = preload("res://GreenWigglerEnemy.tscn")
var frog_enemy = preload("res://FrogEnemy.tscn")
var red_wiggler_enemy = preload("res://RedWigglerEnemy.tscn")
var bat_enemy = preload("res://BatEnemy.tscn")
var ghost_enemy = preload("res://GhostEnemy.tscn")
var ufo_enemy = preload("res://UFOEnemy.tscn")
var saw_blade_enemy = preload("res://SawBladeEnemy.tscn")
var turret_enemy = preload("res://TurretEnemy.tscn")

# Other nodes
onready var root : Node = get_node("/root/Main")

# Exports
export var spawn_type = "none"

# State
var enemy_instance = null
var started_spawning = false

func _ready():
	if (enemy_instance == null):
		init_enemy(spawn_type)

func _process(delta):
	rotate(delta*PI)

func init_enemy(name):
	var enemy = null
	match name:
		"spider":
			enemy = spider_enemy.instance()
		"green_wiggler":
			enemy = green_wiggler_enemy.instance()
		"frog":
			enemy = frog_enemy.instance()
		"red_wiggler":
			enemy = red_wiggler_enemy.instance()
		"bat":
			enemy = bat_enemy.instance()
		"ghost":
			enemy = ghost_enemy.instance()
		"ufo":
			enemy = ufo_enemy.instance()
		"sawblade":
			enemy = saw_blade_enemy.instance()
		"turret":
			enemy = turret_enemy.instance()
	if (enemy != null):
		enemy_instance = enemy
	return enemy

func start_spawning():
	if (not started_spawning):
		started_spawning = true
		if (enemy_instance.name != "TurretEnemy"):
			root.change_enemy_count(1)
		$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	enemy_instance.global_position = global_position
	enemy_instance.activate()
	enemy_instance.get_node("DyingTimer").wait_time = 0.75
	enemy_instance.add_to_group("enemy")
	enemy_instance.activated = true
	root.add_child(enemy_instance)
	queue_free()

func _on_PlayerDetectionArea_body_entered(body):
	if (not body.is_in_group("projectile")):
		start_spawning()
