extends KinematicBody2D

# Remotely controlled ship. Controlled by another player ontheir computer

var second_last_pos: Vector2
var last_pos: Vector2

var player_name = null

var colors = {
	"purple": Color(0.207843, 0.070588, 0.192157),
	"red": Color(0.320313, 0.06131, 0.06131),
	"blue": Color(0, 0.00531, 0.339844),
	"teal": Color(0, 0.433594, 0.403107),
	"green": Color(0.00769, 0.328125, 0.095309),
	"yellow": Color(0.371265, 0.390625, 0.036621),
	"beige": Color(0.386719, 0.386719, 0.386719),
}

onready var rb = $Right/Base
onready var rc = $Right/Core
onready var lb = $Left/Base
onready var lc = $Left/Core


func _ready():
	connect("mouse_entered", self, "_mouse_entered")
	connect("mouse_exited", self, "_mouse_exited")
	second_last_pos = global_position
	last_pos = global_position
	$Name.text = player_name


func _process(delta):
	# Movement prediction
	move_and_slide((last_pos - second_last_pos) * (1.0 / delta))
	# Name rotation
	$Name.rect_rotation = rad2deg(-rotation)


# Networking


remote func set_ship_color(color):
	$Color.modulate = colors[color]


remote func sync_function(pos, rot, flame = false):
	rb.emitting = flame
	rc.emitting = flame
	lb.emitting = flame
	lc.emitting = flame
#	move_and_slide((pos - global_position) * 60)
	global_position = pos
	rotation = rot
	# Positions for mov predict
	second_last_pos = last_pos
	last_pos = pos


remote func sync_death():
	# For when player in question dies. Called by them remotely
	hide()


# Signal callbacks


func _mouse_entered():
	$Name.show()


func _mouse_exited():
	$Name.hide()
