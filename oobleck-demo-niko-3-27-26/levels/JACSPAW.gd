extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_shape_exited(shape_idx: int) -> void:
	LevelManager.level_unlocked = LevelManager.level_unlocked + 1
	get_tree().change_scene_to_file("res://levels/LevelSelect.tscn")
	pass # Replace with function body.
