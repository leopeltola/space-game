extends Control


func _ready():
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("connection_failed", self, "failed_to_connect")
	$NameInput.connect("text_changed", self, "_name_changed")


func _on_CreateGame_pressed():
	randomize()
	Network.init_server()
	get_tree().change_scene("res://scenes/Test.tscn")


func _on_JoinGame_pressed():
	Network.init_client($LineEdit.text)
	$CreateGame.disabled = true
	$JoinGame.disabled = true
	$Load.show()


# Signal callbacks


func connected_to_server():
	get_tree().change_scene("res://scenes/Test.tscn")


func failed_to_connect():
	$CreateGame.disabled = false
	$JoinGame.disabled = false
	$Load.hide()
	print_debug("Failed to connect")


func _name_changed(text):
	$CreateGame.disabled = text == ""
	$JoinGame.disabled = text == ""
	Players.local_player_name = text
