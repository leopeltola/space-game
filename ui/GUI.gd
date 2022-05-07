extends Control

var can_dock = false setget set_can_dock
var docked = false
var planet = null


func _ready():
	$Radio/Next.connect("pressed", self, "_next_song_pressed")
	$Radio/Prev.connect("pressed", self, "_prev_song_pressed")


func _process(delta):
	$Credits.text = str(int(Players.credits))
	$Minerals.text = str(int(Players.minerals))
	$Radio/Artist.text = Audio.get_current_song_artist()
	$Radio/Name.text = Audio.get_current_song_name()
	$Distance.text = "Distance to Sun:\n%.2f AU" % (((Players.local_player.distance_to_sun()) - 58) / 500.0)
	$HPBar.value = Players.local_player.hp

	if can_dock and Input.is_action_just_pressed("dock") and not docked:
		Players.local_player.dock_to_planet(planet)
		examine_planet()
		docked = true
		$DockInfo.text = "Undock [Space]"
	elif can_dock and Input.is_action_just_pressed("dock") and docked:
		Players.local_player.undock()
		close_planet()
		$DockInfo.text = "Dock [Space]"
		docked = false


func examine_planet():
	$UI.set_planet(planet)
	$UI.show()


func close_planet():
	$UI.hide()


# Setters


func set_can_dock(val):
	can_dock = val
	if can_dock == true:
		$DockInfo.show()
	elif can_dock == false:
		$DockInfo.hide()


# Signals


func _next_song_pressed():
	Audio.soundtrack_next_song()


func _prev_song_pressed():
	Audio.soundtrack_prev_song()
