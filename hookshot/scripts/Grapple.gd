extends KinematicBody2D

const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var active = false

func launch():
	var cursor = get_viewport().get_mouse_position()
	velocity = (cursor - get_global_transform().origin).normalized() * 500

func _physics_process(delta):
	if active:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0, .1)
			velocity.y = 15
		else:
			velocity.y += 15
	else:
		velocity = Vector2()
			
	var collision = move_and_collide(velocity, true, true, true)
	velocity = move_and_slide(velocity, FLOOR)