extends RigidBody2D

var max_speed = 42
var thruster_power = .7

var thruster: String = ""

onready var right_emit_base = $Right/Base
onready var right_emit_core = $Right/Core
onready var left_emit_base = $Left/Base
onready var left_emit_core = $Left/Core

onready var HealTimer = $HealTimer

var BaseBullet = preload("res://entities/bullets/BaseBullet.tscn")

var can_dock = false
var docked = false
var close_planet = null

var sun = null

var max_hp := 100.0
var hp := max_hp
var healing := true
var dead := false
var can_take_dmg = false

var colors = {
	"purple": Color(0.207843, 0.070588, 0.192157),
	"red": Color(0.320313, 0.06131, 0.06131),
	"blue": Color(0, 0.00531, 0.339844),
	"teal": Color(0, 0.433594, 0.403107),
	"green": Color(0.00769, 0.328125, 0.095309),
	"yellow": Color(0.371265, 0.390625, 0.036621),
	"beige": Color(0.386719, 0.386719, 0.386719),
}
var color = "blue"
var player_name = null


func _ready():
	color = Players.local_player_color
	player_name = Players.local_player_name
	set_ship_color(color)
	sun = get_tree().get_nodes_in_group("star")[0]
	Players.local_player = self
	rset_config("global_position", MultiplayerAPI.RPC_MODE_REMOTE)
	rset_config("rotation", MultiplayerAPI.RPC_MODE_REMOTE)
	rpc("set_ship_color", color)
	# Body collision connect
	connect("body_entered", self, "_body_entered_handler")
	HealTimer.connect("timeout", self, "_HealTimer_timeout")
	
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	can_take_dmg = true



func _physics_process(delta):
	if not dead:
		if healing:
			add_hp(delta)
		aim_turrets()
		if Input.is_action_pressed("move_up"):
			apply_central_impulse((Vector2.UP * thruster_power).rotated(rotation))
			right_emit_base.emitting = true
			right_emit_core.emitting = true
			left_emit_base.emitting = true
			left_emit_core.emitting = true
		else:
			right_emit_base.emitting = false
			right_emit_core.emitting = false
			left_emit_base.emitting = false
			left_emit_core.emitting = false
		if Input.is_action_pressed("move_down"):
			apply_central_impulse((Vector2.DOWN * thruster_power * 0.7).rotated(rotation))
		if Input.is_action_pressed("rotate_left"):
			apply_torque_impulse(-4.4)
		if Input.is_action_pressed("rotate_right"):
			apply_torque_impulse(4.4)
		
		if Input.is_action_just_pressed("shoot"):
			shoot()

	# Network updates
#	rset_unreliable("global_position", global_position)
#	rset_unreliable("rotation", rotation)
	rpc_unreliable("sync_function", global_position, rotation, right_emit_base.emitting)


func _integrate_forces(state):
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed


remote func set_ship_color(color):
	$Color.modulate = colors[color]


func distance_to_sun() -> float:
	return (global_position - sun.global_position).length()


func dock_to_planet(planet):
	docked = true
	mode = MODE_STATIC


func undock():
	docked = false
	mode = MODE_RIGID


# Weapon, dmg and hp functions


func shoot():
	var b = BaseBullet.instance()
	b.global_position = $Gun1.global_position
	var dis = $Gun1.global_position - get_global_mouse_position()
	b.rotation = dis.angle() + PI
	b.linear_velocity = linear_velocity
	$"..".add_child(b)
	
	


func aim_turrets():
	var dis = get_global_mouse_position() - $Gun1.global_position
	$Gun1.rotation = dis.angle() - rotation + PI / 2.0


func take_dmg(val):
	if can_take_dmg and false:
		hp -= val
		if hp <= 0:
			# dead
			die()


func add_hp(val):
	hp += val
	hp = min(hp, max_hp)


func die():
	# Called when out of hp
	rpc("sync_death")
	hide()
	dead = true
	$CollisionPolygon2D.disabled = true


# Equip stuff


func equip(item_name):
	match item_name:
		"Ion Thrusters":
			thruster = item_name
			thruster_power = .9
		"Carbon Plating":
			thruster = item_name


func unequip(item_name):
	match item_name:
		"Ion Thrusters":
			thruster = ""
			thruster_power = .7


# Signal callbacks


func _body_entered_handler(body):
	healing = false
	HealTimer.start()
	var diff: Vector2= global_position - body.global_position
	if body.get_class() == "RigidBody2D":
		var svel = linear_velocity.rotated(-diff.angle())
		var bvel = body.linear_velocity.rotated(-diff.angle())
		var dmg = abs(svel.x - bvel.x)
		print("DMG: ", dmg)
		if dmg > 13:
			take_dmg(dmg)
	else:
		var svel = linear_velocity.rotated(-diff.angle())
		var dmg = abs(svel.x)
		print("DMG: ", dmg)
		if dmg > 13:
			take_dmg(dmg)
		


func _HealTimer_timeout():
	healing = true
