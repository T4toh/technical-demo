class_name Character
extends Resource

@export var name: String
@export var max_hp: int
@export var attack: int
@export var defense: int

static var available_names = [
	"Alice", "Bob", "Charlie", "Diana",
	"Eve", "Frank", "Grace", "Heidi", "Ivan", "Judy", "Karl", "Leo",
	"Mallory", "Nina", "Oscar", "Peggy", "Quentin", "Rupert", "Sybil", "Trent", "Uma", "Victor"
]

var current_hp: int

# Inicializa el character, pero se ejectuta una vez con el .new()
func _init(_name: String, _max_hp: int, _attack: int, _defense: int):
	name = _name if _name != "" else randomName()
	max_hp = _max_hp
	attack = _attack
	defense = _defense
	current_hp = max_hp

func randomName():
	if available_names.is_empty():
		return "Unknown"

	var index = randi() % available_names.size()
	var new_name = available_names[index]
	available_names.remove_at(index)
	return new_name

func take_damage(amount: int) -> int:
	var dmg = max(amount - defense, 0)
	current_hp = max(current_hp - dmg, 0)
	return dmg

func is_alive() -> bool:
	return current_hp > 0
