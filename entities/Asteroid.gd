extends RigidBody2D


var syncing = false
var receiving_sync = false
var data = null

var max_hp = 20
var hp = max_hp

onready var timer = $Timer


func _ready():
	connect("body_entered", self, "_on_Asteroid_body_entered")
	Network.connect("sync_timer", self, "sync_state_to_everyone")


func _physics_process(delta):
	if syncing:
		sync_state_to_everyone()


func _integrate_forces(state):
	if data:
		print("syncing")
		state.transform = Transform2D(data["rot"], data["g_pos"])
		state.linear_velocity = data["l_vel"]
		state.angular_velocity = data["a_vel"]
		data = null


# Networking


func data() -> Dictionary:
	return {
		"name": name,
		"g_pos": global_position,
		"rot": rotation,
		"l_vel": linear_velocity,
		"a_vel": angular_velocity,
	}


func sync_state_to_everyone():
	rpc_unreliable("sync_state", data())


remote func sync_state(_data):
	data = _data


remote func set_receiving_sync(val):
	print("Sync state: ", val)
	sleeping = false
	receiving_sync = val


# Damage


func take_dmg(val):
	hp -= val
	if hp <= 0:
		# dead
		rpc("die")


func add_hp(val):
	hp += val
	hp = min(hp, max_hp)


remotesync func die():
	Players.minerals += 100
	queue_free()


# Signal callbacks


func _on_Asteroid_body_entered(body):
	if body.is_in_group("local_player"):
		if not syncing:
			rpc("set_receiving_sync", true)
			syncing = true
			timer.start()
			yield(timer, "timeout")
			rpc("set_receiving_sync", false)
			syncing = false
			data = null
		else:
			timer.start()
