extends RigidBody2D


export var dmg := 5
export var velocity := 200
export var max_range := 300

var spawn_origin : Vector2

func _ready():
	spawn_origin = global_position
	apply_central_impulse(Vector2.RIGHT.rotated(rotation) * velocity)
	$CollisionShape2D.disabled = true
	var t = Timer.new()
	t.set_wait_time(.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	$CollisionShape2D.disabled = false
	$DmgBox.connect("body_entered", self, "_body_entered")


func _process(delta):
	if (spawn_origin - global_position).length() > max_range:
		queue_free()


# Signal callbacks


func _body_entered(body):
	if body.is_in_group("damageable"):
		body.take_dmg(dmg)
	queue_free()
