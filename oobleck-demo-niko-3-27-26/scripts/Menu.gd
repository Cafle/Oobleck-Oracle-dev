extends Node


# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	$FX_SLIDER.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("FX"))
	$M_SLIDER.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		get_tree().get_root().get_node("Node2D/PAUSE").show()
	pass


func _on_m_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	pass # Replace with function body.


func _on_fx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("FX"), linear_to_db(value))
	pass # Replace with function body.


func _on_back_button_up() -> void:
	get_tree().get_root().get_node("Node2D/PAUSE").hide()
	get_tree().paused = false
	pass # Replace with function body.


func _on_lvl_slc_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/LevelSelect.tscn")
	pass # Replace with function body.
