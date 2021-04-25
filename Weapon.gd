extends Area2D

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player : Node = root.get_node("Player")
onready var sprite : Sprite = $Sprite
onready var library : ResourcePreloader = root.get_node("SpriteLibrary")
onready var arsenal : ResourcePreloader = root.get_node("ArsenalStats")

# Enum
enum WeaponType {
	NONE,
	DESERT_HAWK,
	MAG,
	POSHLINOV,
	SG1,
	KNIFE
}

# Export
export var spawn_weapon_type = "none"

# State
var stats = {}
var total_hover_frames = 4
var hover_frames = 0
var hover_speed = 0.3
var phase = 0
var created_from_drop = false

func _ready():
	if (not created_from_drop):
		change_weapon_type(spawn_weapon_type)
	else:
		sprite.texture = library.get_resource(stats.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	phase += delta
	
	# Only occur every fraction of a second determined by hover_speed
	if (phase >= hover_speed):
		phase -= hover_speed
		
		# 'Animate' the hover
		hover_frames += 1
		if (hover_frames <= total_hover_frames / 2):
			position.y += 1
		else:
			position.y -= 1
		
		# Reset hover_frames
		if (hover_frames >= total_hover_frames):
			hover_frames = 0

# Changes the gun type and sprite
func change_weapon_type(type):
	if (spawn_weapon_type == "none"):
		stats = arsenal.get_random_weapon()
	elif (spawn_weapon_type == "secondary"):
		stats = arsenal.get_random_secondary()
	else:
		stats = arsenal.get_weapon(type)
	sprite.texture = library.get_resource(stats.name)

func create_from_drop(weapon_stats):
	stats = weapon_stats
	created_from_drop = true

func interact(_player):
	player.equip_weapon(stats)
	player.remove_context(self)
	queue_free()

func _on_Weapon_body_entered(body):
	if (not body.is_in_group("projectile")):
		player.add_context(self)

func _on_Weapon_body_exited(body):
	if (not body.is_in_group("projectile")):
		player.remove_context(self)
