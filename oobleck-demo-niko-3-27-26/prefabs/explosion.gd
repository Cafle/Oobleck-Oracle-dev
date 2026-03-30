extends Area2D

@export var speed: int = 500
var direction: Vector2

func _ready() -> void:
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for i in range(3):
		for body in get_overlapping_bodies():
			if body.name == "PLAYER":
				body.dead = false
				create_tween().tween_property(body, "modulate", Color.WHITE, 0)
			_apply_to(body)
			
		for area in get_overlapping_areas():
			_apply_to(area)
			
		await get_tree().physics_frame		
	
	queue_free()
	
func _apply_to(target: Node) -> void:
	if target is Slime and target.slime_type == Slime.SlimeType.GENERIC:
			target.die()
