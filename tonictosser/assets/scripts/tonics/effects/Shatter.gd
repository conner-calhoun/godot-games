extends Node2D

var rng = RandomNumberGenerator.new()

func init(spawn):
	position = spawn

func _ready():
	$AnimatedSprite.play("explode")
	var shard_count = (randi() % 3)
	for x in range(shard_count):
		var shard = $Shard.duplicate()
		var force = rng.randi_range(-250, 250)
		shard.apply_impulse(position, Vector2(force, force))
		add_child(shard)
		
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()
		
func _physics__process(delta):
	pass