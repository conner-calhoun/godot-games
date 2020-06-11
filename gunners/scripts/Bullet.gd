extends Sprite

onready var area = $Area2D
onready var blast_radius = $BlastRadius/CollisionShape2D

export var SPEED = 250

var shot_dir = Vector2.ZERO
var body_hit = false

func init(start_pos, shot_dir):
	position = start_pos
	look_at(start_pos + shot_dir)
	self.shot_dir = shot_dir
	
func handle_body_enter(body):
	# create some debris
	var debris = preload("res://objects/Debris.tscn").instance()
	debris.init(position)
	get_parent().add_child(debris)
	
	if body is RigidBody2D:
		var push_back = shot_dir * 300
		
		# Center + the place where we collided
		var hit_loc = Vector2.ZERO + (position - body.position)
		body.apply_impulse(hit_loc, push_back)
	
	queue_free()
	
func _ready():
	area.connect("body_entered", self, "handle_body_enter")
	
func _physics_process(delta):
	position += shot_dir * SPEED * delta
	