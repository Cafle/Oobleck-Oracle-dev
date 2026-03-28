extends StaticBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var burn_time: float = 2.0
var is_burning: bool = false

func catch_fire() -> void:
	if is_burning:
		return
	is_burning = true
	print(name + " is burning!")
	
	

	
	await get_tree().create_timer(burn_time).timeout
	print(name + " burned down!")
	queue_free()
