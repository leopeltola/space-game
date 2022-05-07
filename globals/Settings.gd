extends Node


func _process(delta):
	if Input.is_action_just_pressed("full_screen"):
		OS.window_fullscreen = not OS.window_fullscreen
