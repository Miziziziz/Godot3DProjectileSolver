extends KinematicBody


var velocity : Vector3
var gravity : float

func _physics_process(delta):
	velocity -= delta * gravity * Vector3.DOWN
	move_and_collide(velocity * delta)
