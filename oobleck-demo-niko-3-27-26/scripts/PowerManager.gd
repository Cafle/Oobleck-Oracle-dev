extends Node

enum Power { NONE, FIRE, ICE, LIGHTNING }
var current_power: Power = Power.LIGHTNING
signal power_changed(power: Power)

func set_power(p: Power) -> void:
	current_power = p
	power_changed.emit(p)
	print("Power changed to: ", Power.keys()[p])

func reset_power() -> void:
	current_power = Power.NONE
	power_changed.emit(Power.NONE)
	print("Power reset to NONE")
