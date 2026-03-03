class_name Character
extends Resource

@export var name: String
@export var max_hp: int
@export var attack: int
@export var defense: int

var current_hp: int

func _init():
	current_hp = max_hp

func take_damage(amount: int):
	var dmg = max(amount - defense, 0)
	current_hp = max(current_hp - dmg, 0)

func is_alive() -> bool:
	return current_hp > 0
