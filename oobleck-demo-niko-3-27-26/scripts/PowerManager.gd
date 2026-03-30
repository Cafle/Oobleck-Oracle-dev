extends Node

enum Power { NONE, FIRE, ICE, LIGHTNING }
var current_power: Power = Power.ICE

func set_power(p: Power) -> void:
	current_power = p
	print("Power changed to: ", Power.keys()[p])

func reset_power() -> void:
	current_power = Power.NONE
	print("Power reset to NONE")
