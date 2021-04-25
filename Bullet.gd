extends KinematicBody2D

# Onready
onready var root : Node = get_node("/root/Main")

# Enum
enum Modifier {
	DUPING,
	EXPLOSIVE,
	RUBBER
}

# State
var fired_from
var velocity = Vector2()
var damage = 0
var speed = 500
var modifiers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if (visible):
		var collision = move_and_collide(velocity * speed * delta)
		if (collision):
			collide(collision)

func fire(direction, fired):
	velocity = direction
	fired_from = fired

func add_mod(mod_str):
	match mod_str:
		"duping":
			modifiers.append(Modifier.DUPING)
		"explosive":
			modifiers.append(Modifier.EXPLOSIVE)
		"rubber":
			modifiers.append(Modifier.RUBBER)

func add_mod_collection(col):
	modifiers = col.duplicate(true)

func set_damage(dmg):
	damage = dmg

func set_speed(spd):
	speed = spd

func get_damage():
	return damage

func bounce(collision):
	var reflect = collision.remainder.bounce(collision.normal)
	velocity = velocity.bounce(collision.normal)
	rotation = velocity.angle()
	move_and_collide(reflect)

func dupe(collision):
	var normal = collision.normal
	apply_scale(Vector2(0.8, 0.8))
	for _i in range(2):
		var d = root.get_bullet_scene()
		if (not d): return
		var deviation = (-1 + randf() * 2) * PI/8 # Compute deviation
		d.global_position = global_position
		d.fired_from = fired_from
		d.set_damage(damage/2)
		d.set_collision_layer_bit(0, get_collision_layer_bit(0))
		d.set_collision_layer_bit(1, get_collision_layer_bit(1))
		d.velocity = (normal * velocity.length()).rotated(deviation) # Apply new velocity + deviation for dupe
		d.rotation = d.velocity.angle()
		d.apply_scale(Vector2(0.8, 0.8))
		d.move_and_collide(d.velocity)
		d.add_mod_collection(modifiers)
		get_parent().add_child(d)

func explode(_collision):
	root.create_explosion(global_position)

func collide(collision):
	var body = collision.collider
	if ((body.is_in_group("player") and fired_from == "enemy") or (body.is_in_group("enemy") and fired_from == "player")):
		body.take_damage(damage)
	if (modifiers.size() > 0):
		var next_explode = modifiers.find(Modifier.EXPLOSIVE)
		if (next_explode != -1):
			modifiers.remove(next_explode)
			explode(collision)
		var next_dupe = modifiers.find(Modifier.DUPING)
		if (next_dupe != -1):
			modifiers.remove(next_dupe)
			dupe(collision)
		var next_bounce = modifiers.find(Modifier.RUBBER)
		if (next_bounce != -1):
			modifiers.remove(next_bounce)
			bounce(collision)
			return
	kill()

func reset():
	velocity = Vector2()
	damage = 0
	speed = 500
	modifiers.clear()

func kill():
	hide()
	reset()
	root.spawn_particle("bullet_impact", global_position)
	root.despawn_bullet(self)
