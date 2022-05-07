extends Node2D

var RemotePlayer = preload("res://entities/RemotePlayer.tscn")
var LocalPlayer = preload("res://entities/RigidPlayer.tscn")

var PlanetObj = preload("res://entities/Planet.tscn")
var Asteroid = preload("res://entities/Asteroid.tscn")


func _ready():
	if not get_tree().is_network_server():
		var planets = $Planets
		for child in planets.get_children():
			child.free()
		for child in $Asteroids.get_children():
			child.free()
			
	Players.init()
	

	var lp = LocalPlayer.instance()
	lp.global_position = Vector2(300, 0)
	lp.name = str(Network.local_id)
	add_child(lp)
	
	# Connections
	Network.connect("create_player", self, "_create_player")
	Network.connect("delete_player", self, "_delete_player")
	Network.connect("world_data_requested", self, "send_world_data")
	if not get_tree().is_network_server():
		Network.signal_ready()


# Networking


#var planet_data = [
#	{
#		"node_name": "432",
#		"planet_name": "String",
#		"position": Vector2.ZERO,
#		"size": 0,
#		"skin_id": 0,
#	},
#]


func send_world_data(id):
	send_planet_data(id)
	send_asteroid_data(id)


func send_planet_data(id):
	var planets = get_tree().get_nodes_in_group("planet")
	var planet_data = []
	for planet in planets:
		planet_data.append(planet.planet_data())
	rpc_id(id, "init_planets", planet_data)


remote func init_planets(planet_data):
	var planets = $Planets
#	for child in planets.get_children():
#		child.queue_free()
	for planet in planet_data:
		var pl = PlanetObj.instance()
		pl.set_name(planet["node_name"])
		planets.add_child(pl, true)
		pl.sync_to_planet_data(planet)


func send_asteroid_data(id):
	var asteroids = get_tree().get_nodes_in_group("asteroid")
	var asteroid_data = []
	for asteroid in asteroids:
		asteroid_data.append(asteroid.data())
	rpc_id(id, "init_asteroids", asteroid_data)


remote func init_asteroids(asteroids_data):
	print_debug("Asteroid data received from server")
	var asteroids = $Asteroids
	for asteroid in asteroids_data:
		var ast = Asteroid.instance()
		ast.set_name(asteroid["name"])
		ast.global_position = asteroid["g_pos"]
		ast.rotation = asteroid["rot"]
		ast.linear_velocity = asteroid["l_vel"]
		ast.angular_velocity = asteroid["a_vel"]
		asteroids.add_child(ast, true)


# Signal callbacks


func _create_player(id):
	# Called form Network when player sends data over
	var rp = RemotePlayer.instance()
	rp.global_position = Vector2(300, 0)
	rp.name = str(id)
	rp.player_name = Network.get_player_name_by_id(id)
	add_child(rp)
	print_debug("New ship instanced ID:", id)


func _delete_player(id):
	get_node(str(id)).queue_free()
