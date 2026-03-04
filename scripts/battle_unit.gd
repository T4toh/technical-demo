extends Control

var character: Character
var attack_direction := 1  # 1 = derecha, -1 = izquierda
var is_enemy: bool = false

@onready var rect = $ColorRect

func set_character(char: Character, enemy := false):
	character = char
	is_enemy = enemy
	update_visual()

func set_attack_direction(dir: int):
	attack_direction = dir
	
	if dir == -1:
		rect.scale.x = -1

func play_attack_animation():
	var original_pos = rect.position
	
	var tween = create_tween()
	tween.tween_property(rect, "position:x", original_pos.x + (40 * attack_direction), 0.15)
	tween.tween_property(rect, "position:x", original_pos.x, 0.15)

func play_hit_animation():
	var original_pos = rect.position
	
	var tween = create_tween()
	tween.tween_property(rect, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(rect, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(rect, "position:x", original_pos.x, 0.05)

func update_visual():
	if is_enemy:
		rect.color = Color.RED
	else:
		rect.color = Color.BLUE

	if character.current_hp <= 0:
		rect.modulate = Color(0.3, 0.3, 0.3)  # gris oscuro
