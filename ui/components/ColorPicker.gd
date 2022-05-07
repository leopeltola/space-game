extends Button


signal color_pressed(color)


var colors = {
	"purple": Color(0.207843, 0.070588, 0.192157),
	"red": Color(0.320313, 0.06131, 0.06131),
	"blue": Color(0, 0.00531, 0.339844),
	"teal": Color(0, 0.433594, 0.403107),
	"green": Color(0.00769, 0.328125, 0.095309),
	"yellow": Color(0.371265, 0.390625, 0.036621),
	"beige": Color(0.386719, 0.386719, 0.386719),
}
export var color = "blue"


func _ready():
	modulate = colors[color]
	connect("pressed", self, "_pressed")
	

# Signals

func _pressed():
	emit_signal("color_pressed", color)
