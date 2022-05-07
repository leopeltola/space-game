extends StaticBody2D
class_name Planet

var gravity_items = []

var gravity_power = .5
var gravity_distance

var planet_name = ""
var mineral_density = 0
var credit_density = 0
var planet_size = null # 0 = small, 1 = big
var skin_id = null
# Upgrades
var credit_level = 0
var mineral_level = 0
var planetary_tech = 0
var spaceship_tech = 0
var planetary_shields = 0
var defensive_artillery = 0

var planet_owner = null
var owner_id = null

onready var sprite = $Planet

var s_skins = [
	preload("res://art/planets/dry_b_s.png"),
	preload("res://art/planets/dry_r_s.png"),
	preload("res://art/planets/gaia_r_s.png"),
	preload("res://art/planets/gaia_s.png"),
	preload("res://art/planets/ice_s.png"),
	preload("res://art/planets/lava_s.png"),
	preload("res://art/planets/moon_b_s.png"),
	preload("res://art/planets/moon_s.png"),
]

var l_skins = [
	preload("res://art/planets/dry_b_l.png"),
	preload("res://art/planets/dry_r_l.png"),
	preload("res://art/planets/gaia_l.png"),
	preload("res://art/planets/gaia_r_l.png"),
	preload("res://art/planets/ice_l.png"),
	preload("res://art/planets/lava_l.png"),
	preload("res://art/planets/moon_b_l.png"),
	preload("res://art/planets/moon_l.png"),
]


var names_list = [
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
	"Pasuenides",
	"Annuna",
	"Sillars",
	"Mecaro",
	"Cuahiri",
	"Gorix X7RQ",
	"Zilia 82",
	"Xagnoruta",
	"Yothomia",
	"Tamperre",
	"Eunus",
	"Veazuno",
	"Kuoppio",
	"Turkku",
	"Helsinkki",
	"Trepanus",
	"Phillon 2Q6",
	"Thiuq GS",
]


onready var BuildArea = $BuildArea


func _ready():
	gravity_distance = 1
	if get_tree().is_network_server():
		planet_name = generate_name()
		mineral_density = randf()
		credit_density = max(0, 1 - distance_to_sun() / 3000)

		if randf() >= .5:
			# large planet
			planet_size = 1
			gravity_distance = 500
			skin_id = randi() % l_skins.size()
			$Planet.texture = l_skins[skin_id]
			$CollisionShape2D.get_shape().set_radius(40)
			$BuildArea/CollisionShape2D.get_shape().set_radius(40 + 8)
		else:
			# small planet
			planet_size = 0
			gravity_distance = 350
			skin_id = randi() % l_skins.size()
			$Planet.texture = s_skins[skin_id]
			$CollisionShape2D.get_shape().set_radius(25)
			$BuildArea/CollisionShape2D.get_shape().set_radius(25 + 7)
		print(planet_name)
		$Area2D/CollisionShape2D.get_shape().set_radius(gravity_distance)

	BuildArea.connect("body_entered", self, "_on_player_close")
	BuildArea.connect("body_exited", self, "_on_player_close_left")

	$Timer.connect("timeout", self, "_timeout")


func _process(delta):
	for a in gravity_items:
		a.apply_central_impulse(get_item_gravity(a))


func get_item_gravity(item):
	# Returns Vector2
	var diff = global_position - item.global_position # Vector2
	var g_scale = max(0, 1 - (diff.length() / gravity_distance)) # number
	return diff.normalized() * gravity_power * g_scale # Vector2


func generate_name():
	var id = randi() % names_list.size()
	var n = names_list[id]
	names_list.remove(id)
	return n


func distance_to_sun():
	var star = get_tree().get_nodes_in_group("star")
	if star:
		star = star[0]
		return (star.global_position - global_position).length()
	return 0


func credit_income() -> float:
	return credit_density * credit_level


func mineral_income() -> float:
	return mineral_density * mineral_level


func colonize() -> void:
	planet_owner = Players.local_player
	owner_id = get_tree().get_network_unique_id()
	sync_planet_for_everyone()


# Network stuff


func planet_data():
	return {
		"node_name": name,
		"planet_name": planet_name,
		"position": global_position,
		"planet_size": planet_size,
		"mineral_density": mineral_density,
		"credit_density": credit_density,
		"skin_id": skin_id,
		"owner_id": owner_id,
		"upgrades": upgrades_data(),
	}


func upgrades_data():
	return {
		"credit_level": credit_level,
		"mineral_level": mineral_level,
	}


func sync_to_planet_data(data):
	mineral_level = data["upgrades"]["mineral_level"]
	credit_level = data["upgrades"]["credit_level"]
	owner_id = data["owner_id"]
	if owner_id != Network.local_id:
		planet_owner == null
	else:
		planet_owner = Players.local_player
	# Stuff that could be optimized
	global_position = data["position"]
	planet_name = data["planet_name"]
	mineral_density = data["mineral_density"]
	credit_density = data["credit_density"]
	
	if data["planet_size"] != planet_size:
		planet_size = data["planet_size"]
		if planet_size == 0:
			# small planet
			$CollisionShape2D.get_shape().set_radius(25)
			$BuildArea/CollisionShape2D.get_shape().set_radius(25 + 7)
			skin_id = data["skin_id"]
			$Planet.texture = s_skins[skin_id]
		elif planet_size == 1:
			# large planet
			$CollisionShape2D.get_shape().set_radius(40)
			$BuildArea/CollisionShape2D.get_shape().set_radius(40 + 8)
			skin_id = data["skin_id"]
			$Planet.texture = l_skins[skin_id]
	


func sync_planet_for_everyone():
	rpc("update_planet", planet_data())


remote func update_planet(data):
	sync_to_planet_data(data)


# Signal callbacks


func _timeout():
	if planet_owner == Players.local_player:
		Players.credits += credit_income()
		Players.minerals += mineral_income()


func _on_player_close(body):
	if (not planet_owner) or planet_owner == body:
		var gui = get_tree().get_nodes_in_group("gui")
		if gui:
			gui[0].can_dock = true
			gui[0].planet = self
		body.can_dock = true
		body.close_planet = self


func _on_player_close_left(body):
	var gui = get_tree().get_nodes_in_group("gui")
	if gui:
		gui[0].can_dock = false
	body.can_dock = false
	body.close_planet = null


func _on_Area2D_body_entered(body):
	if body.is_in_group("gravity_item"):
		gravity_items.append(body)


func _on_Area2D_body_exited(body):
	if body.is_in_group("gravity_item"):
		gravity_items.erase(body)


func _on_AnimTimer_timeout():
	if sprite.frame >= 199:
		sprite.frame = 0
	else:
		sprite.frame += 1
