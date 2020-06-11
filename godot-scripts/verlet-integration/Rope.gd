extends Node2D

const SEGMENT_NUM = 50
const SEGMENT_LEN = 5
const CONSTRAINTS = 50
const GRAVITY = Vector2(0, 20)

var head = null
var segments = []

class Segment:
	var object
	var old_pos

func _ready():
	var y_placement = 0
	for x in range(SEGMENT_NUM):
		var object = preload("res://Segment.tscn").instance()
		add_child(object)
		object.init(Vector2(0, y_placement))
		
		var segment = Segment.new()
		segment.object = object
		segment.old_pos = Vector2(0, y_placement)
		segments.append(segment)
		y_placement += SEGMENT_LEN
		
	head = segments[0]
	
func _physics_process(delta):
	for segment in segments:
		var velocity = segment.object.position - segment.old_pos
		segment.old_pos = segment.object.position
		velocity += GRAVITY * delta
		segment.object.position += velocity
		
	for x in range(CONSTRAINTS):
		apply_constraints()
		
func apply_constraints():
	head.object.position = get_viewport().get_mouse_position()

	for x in range(len(segments) - 1):
		var curr = segments[x]
		var next = segments[x+1]
		
		var dist = curr.object.position.distance_to(next.object.position)
		var err = dist - SEGMENT_LEN
		
		var change_dir = (curr.object.position - next.object.position).normalized();
		var change_amt = change_dir * err
		
		if x != 0:
			curr.object.position -= change_amt * .5
			next.object.position += change_amt * .5
		else:
			next.object.position += change_amt * .5
