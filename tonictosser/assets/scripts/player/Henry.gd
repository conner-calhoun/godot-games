extends KinematicBody2D

# consts
const UP = Vector2(0, -1)
const F_ACCELERATION = 50 # forward acceleration
const R_ACCELERATION = 25 # reverse acceleration
const F_MAX_SPEED = 140 # forward max speed
const R_MAX_SPEED = 130 # reverse max speed
const JUMP_FORCE = -450
const GRAVITY = 45

# movement
var velocity = Vector2()

# tonic throw cooldown
#const TONIC_COOLDOWN = .25
#var last_throw = .25

func _ready():
	$AnimatedSprite.play()

# Called every frame: safe for physics
# @param delta: The time elapsed since previous frame
func _physics_process(delta):
	
	# Position = Right facing, Negative = Left Facing
	var mouse_pos = get_viewport().get_mouse_position()
	var facing_direction = mouse_pos.x - position.x
	
	# face sprite towards cursor
	if facing_direction > 0:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	
	# x-Axis movement
	var friction = false
	if Input.is_action_pressed("walk_left"):
		if facing_direction < 0:
			velocity.x = max(velocity.x-F_ACCELERATION, -F_MAX_SPEED)
			$AnimatedSprite.play("walk")
		else:
			velocity.x = max(velocity.x-R_ACCELERATION, -R_MAX_SPEED)
			$AnimatedSprite.play("r_walk")
	elif Input.is_action_pressed("walk_right"):
		if facing_direction > 0:
			velocity.x = min(velocity.x+F_ACCELERATION, F_MAX_SPEED)
			$AnimatedSprite.play("walk")
		else:
			velocity.x = min(velocity.x+R_ACCELERATION, R_MAX_SPEED)
			$AnimatedSprite.play("r_walk")
	else:
		$AnimatedSprite.play("idle")
		friction = true
	
	# y-axis movement
	if is_on_floor():
		velocity.y = GRAVITY
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_FORCE
		if friction:
			velocity.x = lerp(velocity.x, 0, 0.7)
			
	else: # in air
		if not friction: # give an x-velocity jump-boost
			if(round(velocity.x) > 0):
				velocity.x += 5
			elif (round(velocity.x) < 0):
				velocity.x -= 5
		velocity.y += GRAVITY
		$AnimatedSprite.play("fall")
		
	# handle tonic throwing
	if Input.is_action_pressed("throw"):
		var red_tonic = preload("res://assets/scenes/tonics/RedTonic.tscn").instance()
		red_tonic.init(position.x, position.y, mouse_pos.x, mouse_pos.y)
		get_parent().add_child(red_tonic)
	
	# move 'em
	move_and_slide(velocity, UP)