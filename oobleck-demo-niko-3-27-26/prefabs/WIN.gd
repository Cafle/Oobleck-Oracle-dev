extends Area2D

var go = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("AnimatedSprite2D").play("sad")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_slimes():
		get_node("AnimatedSprite2D").play("win")		

func is_slimes() -> bool:
	var children_array := get_tree().current_scene.get_children()
	for x in children_array:
		if "Slime" in x.name:
			return true
	go = true
	return false;
	

func _on_body_entered(body: Node2D) -> void:
	print("bruh")
	if go:
		print("bruhdsd")
		LevelManager.advance_level()
