extends Area2D
@export var speed: int = 500
var direction: Vector2

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta

func destroy():
	queue_free()

func burn(target: Node) -> void:
	if target.has_method("catch_fire"):
		target.catch_fire()
	else:
		target.queue_free()

#func _on_area_entered(area: Area2D) -> void:
#	print("AREA HIT: ", area)
#	if area is Slime:
#		area.die()
#	elif area.is_in_group("burnable"):
#		burn(area)
#	destroy()

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapEffects:
		var tile_coords: Vector2i = body.local_to_map(body.to_local(global_position))
		body.try_burn_tile(tile_coords)
		body.try_melt_tile(tile_coords)
		
	elif body.is_in_group("burnable"):
		burn(body)
	
	if body is Slime:
		body.die()
	elif body.is_in_group("burnable"):
		burn(body)
	destroy()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
