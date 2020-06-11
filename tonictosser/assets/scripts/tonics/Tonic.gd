extends RigidBody2D

# const
const MAX_FORCE = 350
const FORCE_MULTIPLIER = 5

# starting location
var start_pos = Vector2()
var cursor_pos = Vector2()
var throw_force = Vector2()
var rotate_force = 10

func init(start_x, start_y, cursor_x, cursor_y):
	start_pos = Vector2(start_x, start_y + 5)
	
	# - (start_y - cursor_y) to account for wonky forces
	cursor_pos = Vector2(cursor_x, cursor_y - 20)
	
	var force = min(cursor_pos.distance_to(start_pos), MAX_FORCE)
	force = min(force * FORCE_MULTIPLIER, MAX_FORCE)
	throw_force = (cursor_pos - start_pos).normalized() * force
		
# Called when the node enters the scene tree for the first time.
func _ready():
	# set starting position
	position = start_pos
	
	# add rotational & thrown force
	if start_pos.y - cursor_pos.y > 120:
		rotate_force = -rotate_force
	if cursor_pos.x < start_pos.x:
		rotate_force = -rotate_force
		
	set_angular_velocity(rotate_force)
	apply_impulse(position, throw_force)
	
# Physics process
func _physics_process(delta):
	var bodies = get_colliding_bodies()
	if not bodies.empty():
		# create shatter
		var shatter = preload("res://assets/scenes/tonics/effects/Shatter.tscn").instance()
		shatter.init(position)
		get_parent().add_child(shatter)
		
		# delete self
		queue_free()
		