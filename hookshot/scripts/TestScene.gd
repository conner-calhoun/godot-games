extends Node2D

onready var camera = $Camera2D
onready var player = $Camera2D/Player/PlayerBody
onready var portal_area = $Portal/Area2D
onready var time = $Time

var player_dead = false
var screen_shaking = false

var elapsed_time = 0.0

func reload(duration):
	screen_shaking = true
	
	# wait for anim to be done
	yield(get_tree().create_timer(duration), "timeout")
	get_tree().reload_current_scene()
	screen_shaking = false
	camera.set_offset(Vector2(0, 0))
	
func _physics_process(delta):
	var player_y = player.get_global_transform().origin.y
	
	elapsed_time += delta
	time.text = "TIME: " + str(stepify(elapsed_time, 0.1))
	
	if player_y > get_viewport_rect().size.y and not player_dead:
		player_dead = true
		reload(1)
		
	if screen_shaking:
		camera.set_offset(Vector2(rand_range(-1.0, 1.0) * 10, rand_range(-1.0, 1.0) * 10))
		
	for body in portal_area.get_overlapping_bodies():
		if body.get_name() == "PlayerBody":
			reload(1)