extends KinematicBody2D

# Consts
const ACCEL = 1000
const SPEED = 75

# Vars
var velocity = Vector2()

# Onready
onready var sprite = $Sprite

func _physics_process(delta):
	handle_movement(delta)
	
func handle_movement(delta):
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	axis = axis.normalized()
	
	if axis.x > 0:
		sprite.flip_h = false
	elif axis.x < 0:
		sprite.flip_h = true
	
	if axis == Vector2.ZERO:
		if velocity.length() > ACCEL * delta:
			velocity -= velocity.normalized() * ACCEL * delta
		else:
			velocity = Vector2.ZERO
	else:
		velocity += axis * ACCEL * delta
		velocity = velocity.clamped(SPEED)
	
	velocity = move_and_slide(velocity)	
