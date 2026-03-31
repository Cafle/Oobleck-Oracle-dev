extends Area2D
@export var speed: int =2048
var direction: Vector2

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta

func destroy() -> void:
	queue_free()



func _on_body_entered(body: Node2D) -> void:
	if body is TileMapEffects:
		var tile_coords: Vector2i = body.local_to_map(body.to_local(global_position))
		body.try_shock_tile(tile_coords)
	
	if body is Slime:
		body.die()
	destroy()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
