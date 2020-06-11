extends KinematicBody2D

# Consts
const ACCELERATION = 20
const MAX_SPEED = 100
const GRAVITY = 25
const JUMP_HEIGHT = -250
const UP = Vector2(0, -1)
const THROW_FORCE = Vector2(200, 350)

# Keep track of oonga's attacks, and other stuff
var rock = null # The rock item (set when player enters the ares)
var velocity = Vector2() # player's movement velocity
var rock_grab = false # whether or not the player can grab the rock (set when player enters the grab zone)
var on_rock = false # is player on top of rock

# State Machine
enum {
		IDLE, # not doing anything
		MOVING, # moving left or right
		JUMPING, # going up
		FALLING, # going down
		ATTACKING, # attack state
		HOLDING, # holding an object
		DONE # used for exiting certain states
	}
var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerArea.connect("area_entered", self, "handle_area_enter")
	$PlayerArea.connect("area_exited", self, "handle_area_exit")
	set_anim("idle")

# Handle attack action
# @param right: True/False
func attack(right):
	set_flip(right)
	
	set_state(ATTACKING)
	
	# wait for anim to be done
	yield(get_tree().create_timer(.4), "timeout")
	# This is about when the club collides with the ground
	Globals.shake_screen(.4)
	yield(get_tree().create_timer(.4), "timeout")
	
	set_state(DONE)

# Safely set the players animation.
func set_anim(anim):
	if anim == "smash":
		$AnimatedSprite.offset = Vector2(0, -8)
	else:
		$AnimatedSprite.offset = Vector2(0, 0)
		
	$AnimatedSprite.play(anim)
		
# Safely flips the sprite
func set_flip(flip):
	if state != ATTACKING:
		$AnimatedSprite.flip_h = flip
		
# Controls the finite state machine transitions
func set_state(new_state):
	match state:
		IDLE: 												# if our state is IDLE we can go to...
			if new_state in [MOVING, JUMPING, ATTACKING, HOLDING]: # MOVING or JUMPING or ATTACKING
				state = new_state
		MOVING:
			if new_state in [IDLE, JUMPING, ATTACKING, HOLDING, FALLING]:
				state = new_state
		JUMPING:
			if new_state in [FALLING, ATTACKING, HOLDING]:
				state = new_state
		FALLING:
			if new_state in [ATTACKING]:
				state = new_state
			if is_on_floor() or on_rock:
				if new_state in [IDLE, MOVING]:
					state = new_state
		ATTACKING:
			if new_state in [DONE]:
				state = new_state
		HOLDING:
			if new_state in [DONE]:
				state = new_state 
		DONE:
			state = new_state
		
# Handle area entered signal
func handle_area_enter(area):
	if area.get_name() == "RockArea":
		if rock == null:
			rock = area.get_parent()
		
		rock_grab = true
		var rock_top = round(rock.position.y - position.y)
		if state in [FALLING, JUMPING, MOVING, IDLE] and rock_top >= 12:
			on_rock = true
		
# Handle area exited signal
func handle_area_exit(area):
	if area.get_name() == "RockArea":
		rock_grab = false
		on_rock = false
		
# Handles actions (attacks and throws and picking stuff up, etc)
func handle_actions():
	if Input.is_action_just_pressed("l_action"):
		attack(true)
	if Input.is_action_just_pressed("r_action"):
		attack(false)
	if rock_grab:
		if Input.is_action_just_pressed("d_action"):
			grab_rock()
			
# Locks the rock to the player position
func lock_rock():
	rock.set_sleeping(true) # to not monitor collisions while being held
	rock.position.y = lerp(rock.position.y, position.y - 4, .8)
	rock.position.x = lerp(rock.position.x, position.x, .8)
	
# Grabs the rock and puts us in the holding state
func grab_rock():
	set_state(HOLDING)
	on_rock = false
		
# Handles user input when oonga is holding something
func handle_hold_actions():
	if Input.is_action_just_pressed("l_action"):
		var angle = Vector2(rock.position.x - 1, rock.position.y - 1)
		var direction = (angle - rock.position).normalized() * THROW_FORCE
		rock.apply_impulse(rock.position, direction)
		set_state(DONE)
		yield(get_tree().create_timer(.1), "timeout")
		rock.set_indicator(true)
	if Input.is_action_just_pressed("r_action"):
		var angle = Vector2(rock.position.x + 1, rock.position.y - 1)
		var direction = (angle - rock.position).normalized() * THROW_FORCE
		rock.apply_impulse(rock.position, direction)
		set_state(DONE)
		yield(get_tree().create_timer(.1), "timeout")
		rock.set_indicator(true)
	if Input.is_action_just_pressed("u_action"):
		var angle = Vector2(rock.position.x, rock.position.y - 1)
		var direction = (angle - rock.position).normalized() * THROW_FORCE
		rock.apply_impulse(rock.position, direction)
		set_state(DONE)
		yield(get_tree().create_timer(.1), "timeout")
		rock.set_indicator(true)
	if Input.is_action_just_pressed("d_action"):
		set_state(DONE)
		yield(get_tree().create_timer(.1), "timeout")
		rock.set_indicator(true)

# Handles x direction movement
func handle_movement():
	if Input.is_action_pressed("left"):
		set_state(MOVING)
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		set_flip(true)
	elif Input.is_action_pressed("right"):
		set_state(MOVING)
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		set_flip(false)
	else:
		set_state(IDLE)
		velocity.x = lerp(velocity.x, 0, .5)
		
# Handles jump commands
func handle_jump():
	if is_on_floor() or on_rock:
		if Input.is_action_just_pressed("jump"):
			set_state(JUMPING)
			velocity.y = JUMP_HEIGHT

# Called every frame (framerate independent)
func _physics_process(delta):
	
	# Handle Gravity
	if is_on_floor() and state != JUMPING:
		velocity.y = GRAVITY
	else:
		if velocity.y > GRAVITY:
			set_state(FALLING)
		if on_rock:
			position.y = rock.position.y - 14
			velocity.y = 0
		else:
			velocity.y += GRAVITY
		
	# for the future state machine
	match state:
		IDLE:
			set_anim("idle")
			handle_actions()
			handle_movement()
			handle_jump()
		MOVING:
			set_anim("walk")
			handle_actions()
			handle_movement()
			handle_jump()
		JUMPING:
			set_anim("jump")
			handle_actions()
			handle_movement()
		FALLING:
			set_anim("jump")
			handle_actions()
			handle_movement()
		ATTACKING:
			handle_movement()
			handle_jump()
			set_anim("smash")
			velocity.x = velocity.x * .8
		HOLDING:
			rock.set_indicator(false)
			# Carry animations
			var anim = null
			if not is_on_floor():
				anim = "jump"
			elif round(velocity.x) > 0 or round(velocity.x) < 0:
				anim ="walk"
			else:
				anim = "idle"
			set_anim(anim)
			lock_rock()
			handle_hold_actions()
			handle_movement()
			handle_jump()
		DONE:
			set_state(IDLE)
		
	move_and_slide(velocity, UP)
	
