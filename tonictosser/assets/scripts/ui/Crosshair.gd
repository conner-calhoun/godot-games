extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# set position to the mouse position
	position = get_viewport().get_mouse_position()