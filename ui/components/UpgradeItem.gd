extends Control

var label: String
var credit_cost: int
var mineral_cost: int
var desc: String

onready var BuyButton = $Control/Button


func _ready():
	BuyButton.connect("pressed", self, "_buy_pressed")


func _process(delta):
	if Players.can_spend_credits(credit_cost) and Players.can_spend_minerals(mineral_cost):
		BuyButton.disabled = true
	else:
		BuyButton.disabled = false


# Signal callbacks


func _buy_pressed():
	if Players.can_spend_credits(credit_cost) and Players.can_spend_minerals(mineral_cost):
		Players.spend_credits(credit_cost)
		Players.spend_minerals(mineral_cost)
		Players.local_player.equip(label)
		print_debug("Equipped ", label)
