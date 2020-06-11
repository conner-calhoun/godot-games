extends Node2D

onready var player = $PlayerBody
onready var weapon = $PlayerBody/Weapon
onready var grapple = $Grapple
onready var grapple_sprite = $Grapple/Sprite

const FLOOR = Vector2(0, -1)
const GRAVITY = 30
const JUMP = -400
const MAX_SPEED = 50
const ACCEL = 25

var velocity = Vector2()
var grappled = false
var reel = false
var rope_length = 0

func _physics_process(delta):
	# Rotate gun to cursor
	var cursor = get_viewport().get_mouse_position()
	weapon.look_at(cursor)
	
	# Friction
	velocity.x = lerp(velocity.x, 0, .1)
	
	# Movement
	if Input.is_action_pressed("left"):# and not reel:
		velocity.x = min(velocity.x - ACCEL, -MAX_SPEED)
	if Input.is_action_pressed("right"):# and not reel:
		velocity.x = max(velocity.x + ACCEL, MAX_SPEED)
	
	# Jumping / Gravity
	if player.is_on_floor():
		velocity.y = GRAVITY
		if Input.is_action_just_pressed("jump") and not reel:
			velocity.y = JUMP
	else:
		velocity.y += GRAVITY
		
	if player.is_on_ceiling():
		velocity.y = GRAVITY
		
	# Grappling hook
	if grappled:
		var start_reel = 0
		var start_pos = Vector2()
		if Input.is_action_just_pressed("reel"):
			if reel:
				print("Cutting")
				reel = false
				grappled = false
				grapple.active = false
			else:
				print("Reeling in")
				reel = true
		if Input.is_action_just_pressed("cut"):
			print("Cutting")
			reel = false
			grappled = false
			grapple.active = false
		if reel:
			rope_length = grapple.position.distance_to(player.position)
			if rope_length <= 14:
				reel = false
				grappled = false
				grapple.active = false
			else:
				velocity += (grapple.position - player.position).normalized() * 40
	else:
		grapple.position = player.position
		grapple_sprite.set_offset(Vector2(14, 0))
		grapple.look_at(cursor)
		
		if Input.is_action_just_pressed("fire"):
			grapple_sprite.set_offset(Vector2(0, 0))
			grappled = true
			grapple.active = true
			grapple.launch()
	
	player.move_and_slide(velocity, FLOOR)