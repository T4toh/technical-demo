extends Control

var character: Character
var attack_direction := 1  # 1 = derecha, -1 = izquierda
var is_enemy: bool = false

var hero_textures = [
	preload("res://assets/hero1.png"),
	preload("res://assets/hero2.png"),
	preload("res://assets/hero3.png"),
	preload("res://assets/hero4.png"),
	preload("res://assets/hero5.png")
]

var enemy_textures = [
	preload("res://assets/enemy1.png"),
	preload("res://assets/enemy2.png"),
	preload("res://assets/enemy3.png"),
	preload("res://assets/enemy4.png"),
	preload("res://assets/enemy5.png")
]

@onready var sprite = $TextureRect

func set_character(char: Character, enemy := false):
	character = char
	is_enemy = enemy
	
	if is_enemy:
		sprite.texture = enemy_textures.pick_random()
	else:
		sprite.texture = hero_textures.pick_random()

	update_visual()

func set_attack_direction(dir: int):
	attack_direction = dir
	
	if dir == -1:
		sprite.scale.x = -1

func play_attack_animation():
	var original_pos = sprite.position
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", original_pos.x + (40 * attack_direction), 0.15)
	tween.tween_property(sprite, "position:x", original_pos.x, 0.15)

func play_hit_animation():
	var original_pos = sprite.position
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(sprite, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(sprite, "position:x", original_pos.x, 0.05)

func update_visual():
	if character.current_hp <= 0:
		sprite.modulate = Color(0.3, 0.3, 0.3)
		return

	if is_enemy:
		sprite.modulate = Color.RED
	else:
		sprite.modulate = Color.BLUE
