extends Node2D

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player : Node = root.get_node("Player")

# State
var stats = {
	"type" : "none", # Either "player", "bullet", or "weapon"
	"subtype" : "none", # Extensible. Determines when or where the upgrade func is called (ex: "onDamage", "onShoot", "onBuntShot", etc.)
	"func_ref" : null,
	"img" : null
}
var enabled = true
var desc = "An upgrade"

func _ready():
	stats.func_ref = funcref(self, "upgrade")
	stats.img = $Sprite.texture

func interact(_player):
	if (player.collect_upgrade(stats)):
		player.remove_context(self)
		$PlayerCollisionBox.disconnect("body_entered", self, "_on_PlayerCollisionBox_body_entered")
		$PlayerCollisionBox.disconnect("body_exited", self, "_on_PlayerCollisionBox_body_exited")
		print("Player picked up an upgrade:")
		# By reparenting to player the node is kept in memory for the FuncRef
		self.hide()
		get_parent().remove_child(self)
		player.add_child(self)

func enable():
	enabled = true

func disable():
	enabled = false

func upgrade(_obj):
	print("Upgrade applied:")

func _on_PlayerCollisionBox_body_entered(body):
	if (enabled and not body.is_in_group("projectile")):
		player.add_context(self)

func _on_PlayerCollisionBox_body_exited(body):
	if (enabled and not body.is_in_group("projectile")):
		player.remove_context(self)
