extends Node2D

# Signals
signal purchased()

# Nodes
onready var root : Node = get_node("/root/Main")
onready var player : Node = root.get_node("Player")
onready var price_label : Label = get_node("PriceLabel")

# Enum
enum ShopItemType {
	KEY,
	AMMO_BOX,
	UPGRADE
}

# State
var price = 20
var enabled = false

func _ready():
	enabled = true

func remove_item():
	var n = $ItemPos.get_child(0)
	$ItemPos.remove_child(n)
	return n

func set_price(val):
	price = val
	price_label.text = str(price)

func set_item(item, val):
	if ($ItemPos.get_child_count() > 0):
		var n = remove_item()
		n.queue_free()
	$ItemPos.add_child(item)
	item.scale = Vector2(0.5, 0.5)
	item.position = Vector2(0, 0)
	item.disable()
	set_price(val)

func interact(_player):
	if (player.can_pay(price)):
		var item = remove_item()
		root.add_child(item)
		item.global_position = $Sprite.global_position
		item.scale = Vector2(1, 1)
		item.enable()
		player.mod_coins(-price)
		player.remove_context(self)
		emit_signal("purchased")
		queue_free()

func _on_PurchaseArea_body_entered(body):
	if (enabled and not body.is_in_group("projectile")):
		price_label.modulate = Color(1, 1, 1, 1)
		player.add_context(self)

func _on_PurchaseArea_body_exited(body):
	if (enabled and not body.is_in_group("projectile")):
		price_label.modulate = Color(0.5, 0.5, 0.5, 0.5)
		player.remove_context(self)
