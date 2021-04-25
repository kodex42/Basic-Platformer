extends MarginContainer


onready var health_bar_over : TextureProgress = $HealthBarOver
onready var health_bar_under : TextureProgress = $HealthBarUnder
onready var health_tween : Tween = $UpdateTween
onready var pulse_tween : Tween = $PulseTween

export (Color) var healthy_color = Color.green
export (Color) var caution_color = Color.yellow
export (Color) var danger_color = Color.red
export (Color) var pulse_color = Color.darkred
export (float, 0, 1, 0.05) var caution_zone = 0.4
export (float, 0, 1, 0.05) var danger_zone = 0.2
export (bool) var will_pulse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func assign_health_color(health):
	if (health < health_bar_over.max_value * danger_zone):
		if (will_pulse):
			pulse_tween.interpolate_property(health_bar_over, "tint_progress", pulse_color, danger_color, 1.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			pulse_tween.start()
		else:
			health_bar_over.tint_progress = danger_color
	else:
		pulse_tween.set_active(false)
		if (health < health_bar_over.max_value * caution_zone):
			health_bar_over.tint_progress = caution_color
		else:
			health_bar_over.tint_progress = healthy_color

func max_health_changed_handler(max_health):
	health_bar_over.max_value = max_health
	health_bar_over.value = max_health
	health_bar_under.max_value = max_health
	health_bar_under.value = max_health

func health_changed_handler(health):
	will_pulse = true
	health_bar_under.value = health_bar_over.value
	if (health > health_bar_over.value):
		health_tween.interpolate_property(health_bar_over, "value", health_bar_over.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		health_tween.start()
	else:
		health_bar_over.value = health
		health_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.4)
		health_tween.start()
	assign_health_color(health)

func _on_Player_health_changed(health):
	health_changed_handler(health)

func _on_Boss_health_changed(health):
	health_changed_handler(health)

func _on_Boss_max_health_changed(max_health):
	max_health_changed_handler(max_health)
