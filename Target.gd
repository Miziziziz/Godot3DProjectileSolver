extends Spatial


var velocity = Vector3(1.0, 0.5, 0.0).normalized() * 10 #Vector3.ZERO #

func _physics_process(delta):
	translate(velocity * delta)

func toggle_velocity():
	velocity *= -1
