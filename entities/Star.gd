extends StaticBody2D

export var gravity := true

var gravity_items = []

var gravity_power = .5
var gravity_distance

var planet_name = ""


func _ready():
	planet_name = generate_name()

	gravity_distance = rand_range(500, 300)
	$Area2D/CollisionShape2D.get_shape().set_radius(gravity_distance)


func _process(delta):
	if gravity:
		for item in gravity_items:
			item.apply_central_impulse(get_item_gravity(item))


func generate_name():
	var names = [
		"Zugniaclite",
		"Otracarro",
		"Lebboria",
		"Kolviea",
		"Autune",
		"Genus",
		"Phibalea",
		"Drubazuno",
		"Brilles O9A",
		"Ucaeturn",
		"Kaelia",
		"Earia",
		"Choruclite",
		"Brioclite",
		"Meon MCH",
		"Bagnaria",
		"Paloria",
		"Baehiri",
		"Core RZ45",
	]
	return names[randi() % names.size()]


func get_item_gravity(item):
	var diff = global_position - item.global_position
	var g_scale = max(0, 1 - (diff.length() / gravity_distance))
	return diff.normalized() * gravity_power * g_scale


# Signal callbacks


func _on_Area2D_body_entered(body):
	if body.is_in_group("gravity_item"):
		gravity_items.append(body)


func _on_Area2D_body_exited(body):
	if body.is_in_group("gravity_item"):
		gravity_items.erase(body)
