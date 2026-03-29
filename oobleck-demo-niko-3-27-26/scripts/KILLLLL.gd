extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:	
	var PLAYER = get_node("../PLAYER")
	PLAYER.dead = true
	PLAYER.velocity = Vector2(0,0)
	
	create_tween().tween_property(PLAYER, "modulate", Color.BLACK, 0.7)
	
	await get_tree().create_timer(1).timeout
	
	PLAYER.position = get_node("../SPAWN").position
	create_tween().tween_property(PLAYER, "modulate", Color.WHITE , 0)
	await get_tree().create_timer(0.7).timeout
	PLAYER.dead = false
	pass # Replace with function body.
