extends RigidBody2D

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player : Node = root.get_node("Player")

# Enum
enum DropType {
	COIN,
	HALF_HEART,
	HEART,
	BULLET,
	AMMO_BOX,
	KEY
}

# Exports
export var type = DropType.COIN
export var auto = true

# State
var enabled = true

func enable():
	sleeping = false
	enabled = true

func disable():
	sleeping = true
	enabled = false

func interact(_player):
	match (type):
		DropType.COIN:
			player.mod_coins(1)
		DropType.HALF_HEART:
			player.heal(5)
		DropType.HEART:
			player.heal(10)
		DropType.BULLET:
			player.reload(0.25)
		DropType.AMMO_BOX:
			player.reload_max()
		DropType.KEY:
			player.collect_key()
	player.remove_context(self)
	queue_free()

func _on_PlayerCollisionBox_body_entered(body):
	if (enabled and not body.is_in_group("projectile")):
		if (auto):
			interact(player)
		else:
			player.add_context(self)

func _on_PlayerCollisionBox_body_exited(body):
	if (enabled and not body.is_in_group("projectile")):
		player.remove_context(self)
