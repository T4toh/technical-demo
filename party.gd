class_name Party
extends Resource

@export var members: Array[Character] = []
var max_members := 5

func add_member(character: Character):
	if members.size() >= max_members:
		return
	members.append(character)

func remove_member(character: Character):
	members.erase(character)

func get_alive_members() -> Array[Character]:
	return members.filter(func(c): return c.is_alive())
