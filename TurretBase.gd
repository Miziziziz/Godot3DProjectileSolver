extends Spatial

var projectile_speed = 50.0
var projectile_gravity : float = -9.8
var projectile = preload("res://Projectile.tscn")
export(NodePath) var target_path
onready var target : Spatial

func _ready():
	target = get_node(target_path)

#func _process(delta):
#	var target_pos = target.global_transform.origin
#	var our_pos = global_transform.origin
#	var n = target_pos - our_pos
#	rotation.y = atan2(-n.x, -n.z)

func fire():
	var dir = calculate_direction()
	if dir == null:
		return # target out of range
	
	var new_p = projectile.instance()
	get_tree().get_root().add_child(new_p)
	new_p.gravity = projectile_gravity
	
	new_p.velocity = projectile_speed * dir

const NUM_OF_ITERATIONS = 10
func calculate_direction():
	var target_cur_pos = target.global_transform.origin
	var target_velocity = target.velocity
	var our_pos = global_transform.origin
	var final_angle = 0.0
	var target_future_pos = target_cur_pos
	for i in range(NUM_OF_ITERATIONS):
		var dist_to_target = our_pos.distance_to(target_future_pos)
		var target_height = our_pos.y - target_future_pos.y
		var angle = get_angle_to_hit_point(dist_to_target, target_height, projectile_speed, projectile_gravity)
		if angle == null:
			return null# out of range
		var time_in_air = dist_to_target / (cos(angle) * projectile_speed)
		
		target_future_pos = target_cur_pos + target_velocity * time_in_air
		var dist_target_travelled = target_future_pos.distance_to(target_cur_pos)
		final_angle = angle

	var n = target_future_pos - our_pos
	var y_rotation = atan2(-n.x, -n.z)
	return Vector3.FORWARD.rotated(Vector3.LEFT, final_angle).rotated(Vector3.UP, y_rotation)

func get_angle_to_hit_point(x, y, speed, gravity):
	var angle1 = get_one_angle_to_hit_point(x, y, speed, gravity, true)
	var angle2 = get_one_angle_to_hit_point(x, y, speed, gravity, false)
	if angle1 == null:
		return angle2
	if angle2 == null:
		return angle1
	
	return max (angle1, angle2) # optimal angle
	#return min (angle1, angle2) # high angle

func get_one_angle_to_hit_point(x, y, S, G, do_plus=false):
	# the equation: atan(s^2 +- sqrt((s^4 - G(Gx^2 + 2S^2y))) / Gx)
	var root = S * S * S * S - G * ( G * x * x + 2.0 * y * S * S)
	if root < 0.0:
		return null
	root = sqrt(root)
	if do_plus:
		return atan((S * S + root) / (G * x))
	else:
		return atan((S * S - root) / (G * x))
