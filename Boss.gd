extends KinematicBody2D

# Signals
signal health_changed(health)
signal max_health_changed(max_health)
signal spawn_bullet(dir, start_pos, start_rot, damage, enemy, mods)
signal killed(pos)

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player = root.get_node("Player")

# State
var activated = false
var contact_damage = 0
var max_health = 100
var health = max_health

func _ready():
	connect("spawn_bullet", root, "_on_Enemy_spawn_bullet")
	connect("killed", root, "_on_Boss_killed")

func _physics_process(delta):
	if (activated):
		act(delta)

func activate():
	if (not activated):
		root.change_enemy_count(1)
		activated = true

func fire_bullet_at_player(dmg):
	var dir = (player.global_position - global_position).normalized()
	emit_signal("spawn_bullet", dir, global_position, dir.angle(), dmg, self, [])

func set_max_health(hp):
	max_health = hp
	health = hp
	emit_signal("max_health_changed", max_health)

func get_damage():
	return contact_damage

func kill():
	emit_signal("killed", global_position)
	queue_free()

# Abstract, to be replaced by subclasses
func act(_delta):
	pass

func take_damage(val):
	health = health - val if health - val < max_health else max_health
	emit_signal("health_changed", health)
