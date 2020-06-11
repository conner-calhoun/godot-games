extends RigidBody2D

var show_indi = true
var thrown = false
var indi_bounce = 0.3
var indi_count = 0
var player_contact = false

# Handle area entered signal
func handle_area_enter(area):
	if area.get_name() == "PlayerArea":
		player_contact = true

# Handle area exited signal
func handle_area_exit(area):
	if area.get_name() == "PlayerArea":
		player_contact = false

# Hide and show the indicator
func set_indicator(show):
	show_indi = show
	
func thrown():
	thrown = true
	
# Run on init, connect signals
func _ready():
	$RockArea.connect("area_entered", self, "handle_area_enter")
	$RockArea.connect("area_exited", self, "handle_area_exit")

# Framerate independent update
func _physics_process(delta):
	# Show indicator for pick up
	if player_contact and show_indi:
		$Indicator.frame = 1
		$Indicator.position.y = sin(indi_count)
		indi_count += indi_bounce
	else:
		$Indicator.frame = 0
		indi_count = 0
		
	if len(get_colliding_bodies()) > 0:
		if thrown:
			Globals.shake_screen(.1)
			thrown = false
	else:
		thrown = true