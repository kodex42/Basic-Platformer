extends Area2D

func _ready():
	$AnimatedSprite.play("explode")

func take_damage(_val):
	pass

func get_damage():
	return 10

func _on_AnimatedSprite_animation_finished():
	queue_free()

func _on_Explosion_body_entered(body):
	if (body.is_in_group("enemy")):
		body.take_damage(get_damage())
