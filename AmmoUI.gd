extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func remove_children():
	for n in get_children():
		remove_child(n)
		n.queue_free()

func _on_Player_ammo_changed(ammo, ammo_max):
	if (ammo_max != -1):
		remove_children()
		for _i in range(0, ammo):
			var tex = TextureRect.new()
			tex.texture = get_parent().get_parent().get_node("SpriteLibrary").get_resource("bullet_ui")
			add_child(tex)
		for _i in range(ammo, ammo_max):
			var tex = TextureRect.new()
			tex.texture = get_parent().get_parent().get_node("SpriteLibrary").get_resource("empty_bullet_ui")
			add_child(tex)
