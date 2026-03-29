extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	$CharacterBody2D PLAYER = get_node("../PLAYER")
	#get_tree().get_root().get_node(get_tree().current_scene.name +"/PAUSE").hide()
	get_node("../PLAYER").position = get_node("../SPAWN").position
	pass # Replace with function body.
