extends HBoxContainer

@onready var name_label = $NameLabel
@onready var hp_label = $HpLabel
@onready var atk_label = $AtkLabel
@onready var def_label = $DefLabel

var character: Character  # 🔥 ahora sí guardamos referencia


func set_character(c: Character):
	character = c
	update_display()


func update_display():
	if character == null:
		return
	
	name_label.text = character.name
	hp_label.text = str(character.current_hp) + " / " + str(character.max_hp)
	atk_label.text = "ATK " + str(character.attack)
	def_label.text = "DEF " + str(character.defense)