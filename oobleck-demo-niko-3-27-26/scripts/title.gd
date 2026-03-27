extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("FX"), linear_to_db(0.75))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(0.75))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_up() -> void:
	get_tree().change_scene_to_file("res://levels/LevelSelect.tscn")
	pass # Replace with function body.


func _on_eopitois_button_up() -> void:
	get_node("TITLE").hide()
	get_node("OPTIONS").show()
	pass # Replace with function body.
	

func _on_back_button_up() -> void:
	get_node("OPTIONS").hide()
	get_node("TITLE").show()
	pass # Replace with function body.
	


func _on_quit_button_up() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_fx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("FX"), linear_to_db(value))
	pass # Replace with function body.


func _on_m_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	pass # Replace with function body.
