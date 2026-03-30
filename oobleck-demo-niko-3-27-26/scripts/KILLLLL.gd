extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print("illimng")	
	var PLAYER = get_node("../PLAYER")
	PLAYER.velocity = Vector2(0,0)
	
	create_tween().tween_property(PLAYER, "modulate", Color.BLACK, 0.4)
	
	await get_tree().create_timer(0.4).timeout
	LevelManager.music_time = get_node("../AudioStreamPlayer").get_playback_position()
	LevelManager._load_level(int(get_tree().current_scene.name))
	pass # Replace with function body.
