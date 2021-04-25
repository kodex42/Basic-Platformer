extends ResourcePreloader

var drops = [
	preload("res://CoinDrop.tscn"),
	preload("res://BulletDrop.tscn"),
	preload("res://HalfHeartDrop.tscn"),
	preload("res://HeartDrop.tscn"),
	preload("res://AmmoBoxDrop.tscn")
]

func spawn():
	var r = randi() % 256
	var i
	
	if (r < 8):
		i = 4
	elif (r < 32):
		i = 3
	elif (r < 64):
		i = 2
	elif (r < 128):
		i = 1
	else:
		i = 0
	
	return drops[i].instance()
