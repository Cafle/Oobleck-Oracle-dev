extends Area2D

@export var speed : int = 600
var direction : Vector2 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta
	
func destroy():
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	print(area.name,"\n")
	destroy()

func _on_body_entered(body: Node2D) -> void:
	print(body)
	destroy()
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Left screen")
	destroy()
