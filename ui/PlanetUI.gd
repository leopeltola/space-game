extends Control

var planet: Planet

var solar_prices = [100, 200, 300, 400, 500]
var mines_prices = [100, 200, 300, 400, 500]


func _ready():
	$Colonize/Button.connect("pressed", self, "_colonize_pressed")

	$Default/EconB.connect("pressed", self, "_econ_tab")
	$Default/TechB.connect("pressed", self, "_tech_tab")
	$Default/DefB.connect("pressed", self, "_def_tab")
	$Default/ShipB.connect("pressed", self, "_ship_tab")

	$Default/Econ/MinesButton.connect("pressed", self, "_mine_upgraded")
	$Default/Econ/SolarButton.connect("pressed", self, "_solar_upgraded")


func _physics_process(delta):
	update()


# Other functions


func set_planet(pl):
	planet = pl
	$Name.text = planet.planet_name
	$Minerals.text = str(int(planet.mineral_density * 100)) + "%"
	$Credits.text = str(int(planet.credit_density * 100)) + "%"

	if not planet.owner_id:
		# Not owned by anyone
		$Colonize.show()
		$Default.hide()
		$Owned.hide()
	elif planet.owner_id == Network.local_id:
		# Owned by you
		$Colonize.hide()
		$Default.show()
		$Owned.hide()
	else:
		# Owned by another
		$Colonize.hide()
		$Default.hide()
		$Owned.show()


func update():
	# Econ
	if planet:
		if not solar_maxed():
			$Default/Econ/SolarLabel.text = "Solar Panels %sm" % solar_prices[planet.credit_level]
			$Default/Econ/Solar.text = "%s / 5" % planet.credit_level
			$Default/Econ/SolarButton.disabled = not Players.can_spend_minerals(
				solar_prices[planet.credit_level]
			)
		else:
			$Default/Econ/SolarLabel.text = "Solar Panels MAX"
			$Default/Econ/Solar.text = "%s / 5" % planet.credit_level
			$Default/Econ/SolarButton.disabled = true
		if not mines_maxed():
			$Default/Econ/MinesLabel.text = "Mineral Mines %sc" % mines_prices[planet.mineral_level]
			$Default/Econ/Mines.text = "%s / 5" % planet.mineral_level
			$Default/Econ/MinesButton.disabled = not Players.can_spend_credits(
				mines_prices[planet.mineral_level]
			)
		else:
			$Default/Econ/MinesLabel.text = "Mineral Mines MAX"
			$Default/Econ/Mines.text = "%s / 5" % planet.mineral_level
			$Default/Econ/MinesButton.disabled = true


func _hide_tabs():
	$Default/Econ.hide()
	$Default/Tech.hide()
	$Default/Def.hide()
	$Default/Ship.hide()


func solar_maxed() -> bool:
	return solar_prices.size() <= planet.credit_level


func mines_maxed() -> bool:
	return mines_prices.size() <= planet.mineral_level


# Signal calbacks


func _colonize_pressed():
	if Players.spend_credits(300) and not planet.owner_id:
		planet.colonize()
		$Colonize.hide()
		$Default.show()


func _econ_tab():
	_hide_tabs()
	$Default/Econ.show()


func _tech_tab():
	_hide_tabs()
	$Default/Tech.show()


func _def_tab():
	_hide_tabs()
	$Default/Def.show()


func _ship_tab():
	_hide_tabs()
	$Default/Ship.show()


func _mine_upgraded():
	if Players.spend_credits(mines_prices[planet.mineral_level]):
		planet.mineral_level += 1
		planet.sync_planet_for_everyone()


func _solar_upgraded():
	if Players.spend_minerals(solar_prices[planet.credit_level]):
		planet.credit_level += 1
		planet.sync_planet_for_everyone()
