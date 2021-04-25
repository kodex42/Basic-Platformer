extends Label

onready var timer = get_parent().get_parent().get_node("DoppelgangerSpawnTimer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	set_text(str(ceil(timer.time_left)))
