extends Node

signal delete_player(id)
signal create_player(id)
signal world_data_requested(id)
signal sync_timer

var is_server = false
var peer
var local_id
var player_data := {}


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	$Timer.connect("timeout", self, "_timer_timeout")


# Server init functions


func init_server():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(5000)
	get_tree().network_peer = peer
	local_id = 1
	is_server = true
	print("Server Initialized")
	$Timer.start()
	player_data[1] = {
		"name": Players.local_player_name,
	}


func init_client(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, 5000)
	get_tree().network_peer = peer
	local_id = get_tree().get_network_unique_id()
	print("Client Initialized")


# Other functions


remote func register_player(id, player_name):
	# Called on new player when joining by other players. Used to send data over
	player_data[id] = {
		"name": player_name,
	}
	emit_signal("create_player", id)


remote func requesting_player_data(id):
	# Called by clients to everyone
	rpc_id(id, "register_player", local_id, Players.local_player_name)


remote func requesting_world_init(id):
	# Called by clients to the server
	print_debug("Client has requested world data: ", id)
	if get_tree().is_network_server():
		emit_signal("world_data_requested", id)
	else:
		assert(false, "requesting_world_init can't be called on client!")


func signal_ready():
	# Called from client when it has loaded World
	rpc("requesting_player_data", local_id)
	rpc_id(1, "requesting_world_init", local_id) # requests world data from server
	rpc("register_player", local_id, Players.local_player_name)


func get_player_name_by_id(id) -> String:
	return player_data[id]["name"]


# Signal callbacks


func _player_connected(id):
	# Called on both clients and server when a peer connects.
#	rpc_id(id, "register_player", local_id)
#	register_player(id, Players.local_player_name)
	pass


func _player_disconnected(id):
	emit_signal("delete_player", id)


func _connected_ok():
	# Only called on clients, not server.
	print_debug("Connected OK")


func _server_disconnected():
	get_tree().change_scene("res://scenes/MainMenu.tscn")


func _connected_fail():
	 # Could not even connect to server; abort.
	print_debug("Connection failed")


func _timer_timeout():
	emit_signal("sync_timer")
