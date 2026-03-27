extends Node

var current_level: int = 1
var level_unlocked: int = 1
var max_level: int = 5

func _unlock_level(level_to_unlock: int) -> void:
	if level_to_unlock > level_unlocked:
		level_unlocked = level_to_unlock
		
func _load_level(level_to_load: int) -> String:
	if level_to_load > max_level:
		return "res://credits.tscn"
	return str("res://levels/Level", level_to_load,".tscn")
