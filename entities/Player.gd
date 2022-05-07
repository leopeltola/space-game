extends KinematicBody2D
class_name Player

var ACCELERATION_SPEED = .0034

var velocity = Vector2()
var acceleration = Vector2()

var gravity_forces = {}


func _process(delta):
	if Input.is_action_pressed("rotate_left"):
		rotate(deg2rad(-5))
	if Input.is_action_pressed("rotate_right"):
		rotate(deg2rad(5))

	if Input.is_action_pressed("move_up"):
		$Flame.show()
		acceleration += Vector2(0, -ACCELERATION_SPEED).rotated(rotation)
	else:
		$Flame.hide()
	if Input.is_action_pressed("move_down"):
		acceleration += Vector2(0, ACCELERATION_SPEED * 0.2).rotated(rotation)

	acceleration = acceleration.move_toward(Vector2.ZERO, acceleration.length() * 0.3)
	print(acceleration.length())

	gravity()
	apply_velocity()


func add_gravity_force(label, force):
	gravity_forces[label] = force


func apply_velocity():
	velocity += acceleration
	velocity = velocity.clamped(1.0)
	move_and_slide(velocity * 60)


func gravity():
	for force in gravity_forces:
		acceleration += gravity_forces[force]
	gravity_forces = {}
