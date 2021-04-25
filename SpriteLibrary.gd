extends ResourcePreloader

# Preloads
var _crosshair = preload("res://Assets/Other/crosshair.png")
var desert_hawk_png = preload("res://Assets/Tiny Guns/desert_hawk.png")
var mag_png = preload("res://Assets/Tiny Guns/mag.png")
var poshlinov_png = preload("res://Assets/Tiny Guns/poshlinov.png")
var sg1_png = preload("res://Assets/Tiny Guns/sg1.png")
var knife_png = preload("res://Assets/Tiny Guns/knife.png")
var bullet_ui = preload("res://Assets/UI/bullet.png")
var empty_bullet_ui = preload("res://Assets/UI/empty_bullet.png")
var empty_key_ui = preload("res://Assets/Tiles/tile_0407.png")
var filled_key_ui = preload("res://Assets/Tiles/tile_0403.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_resource(name):
	match name:
		"desert_hawk":
			return desert_hawk_png
		"mag":
			return mag_png
		"poshlinov":
			return poshlinov_png
		"sg1":
			return sg1_png
		"knife":
			return knife_png
		"bullet_ui":
			return bullet_ui
		"empty_bullet_ui":
			return empty_bullet_ui
		"empty_key_ui":
			return empty_key_ui
		"filled_key_ui":
			return filled_key_ui
