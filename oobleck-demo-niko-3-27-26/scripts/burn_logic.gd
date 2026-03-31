extends StaticBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var burn_time: float = 2.0
var is_burning: bool = false

func catch_fire() -> void:
	if is_burning:
		return
	is_burning = true
	
	

	
	await get_tree().create_timer(burn_time).timeout
	queue_free()
