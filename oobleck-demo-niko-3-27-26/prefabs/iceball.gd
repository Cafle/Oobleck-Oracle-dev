extends Area2D
@export var speed: int = 500
var direction: Vector2

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta

func destroy() -> void:
	queue_free()

#func _on_area_entered(area: Area2D) -> void:
#	if area is Slime:
#		area.die()
#	destroy()
	
func _on_body_entered(body: Node2D) -> void:
	if body is TileMapEffects:
		var tile_coords: Vector2i = body.local_to_map(body.to_local(global_position))
		print(tile_coords)
		body.try_freeze_tile(tile_coords)
	
	elif body is Slime:
		body.die()
	destroy()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
