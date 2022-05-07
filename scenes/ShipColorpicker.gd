extends Node2D


var colors = {
	"purple": Color(0.207843, 0.070588, 0.192157),
	"red": Color(0.320313, 0.06131, 0.06131),
	"blue": Color(0, 0.00531, 0.339844),
	"teal": Color(0, 0.433594, 0.403107),
	"green": Color(0.00769, 0.328125, 0.095309),
	"yellow": Color(0.371265, 0.390625, 0.036621),
	"beige": Color(0.386719, 0.386719, 0.386719),
}
var color = "purple"


func _ready():
	for child in $"../GridContainer".get_children():
		child.connect("color_pressed", self, "_color_pressed")
	_color_pressed("purple")


# Signal callbacks


func _color_pressed(_color):
	color = _color
	$Color.modulate = colors[color]
	Players.local_player_color = color
