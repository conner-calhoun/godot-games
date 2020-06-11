extends KinematicBody2D

# starting location
var start_pos = Vector2()
var vertex = Vector2()

# parabola values
var a = 0
var h = 0
var k = 0

func init(start_x, start_y, cursor_x, cursor_y):
	start_pos = Vector2(start_x, start_y)
	vertex = Vector2(cursor_x, cursor_y)
	
	# parabola vertex
	# y = -a(x - h)^2 + k : (h, k) is the vertex
	# 0 = -a(0- h)^2 + k
	h = cursor_x - start_x # vertex x
	k = start_y - cursor_y # vertex y
	
	# get a to make the parabola go through the origin
	a = - k / pow((0 - h), 2)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# set starting position
	position = Vector2(start_pos.x, start_pos.y)

# Physics process
var x = 0.0
var y = 0.0
func _physics_process(delta):
	#print("H: %s, K: %s, A: %s" % [h, k, a])
	x += vertex.x / 20
	y = a * pow((x - h), 2) + k
	
	#position.x = start_pos.x + x
	#position.y = start_pos.y - y
	
	var target = Vector2(start_pos.x + x, start_pos.y - y)
	var velocity = (target - position).normalized() * 250
	move_and_slide(velocity)
	
	#print("X: %s, Y: %s" % [x, y])
	#print("X: %s, Y: %s" % [position.x, position.y])