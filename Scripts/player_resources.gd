class_name PlayerResources extends Node

@export var blue_souls_amount: int = 100
@export var red_souls_amount: int = 0


func add_souls(type: Souls.Type, amount: int) -> void:
	if type == Souls.Type.BLUE:
		blue_souls_amount += amount
	elif type == Souls.Type.RED:
		red_souls_amount += amount


func has_enough(type: Souls.Type, amount: int) -> bool:
	if type == Souls.Type.BLUE:
		return blue_souls_amount >= amount
	elif type == Souls.Type.RED:
		return red_souls_amount >= amount
	return false


func remove_souls(type: Souls.Type, amount: int) -> void:
	if type == Souls.Type.BLUE:
		blue_souls_amount -= amount
	elif type == Souls.Type.RED:
		red_souls_amount -= amount
