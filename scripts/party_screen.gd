extends Control
# Se usa el nombre del botón
# En este caso es AddHeroButton, lo mismo debería estar en el box.
@onready var add_hero = $MarginContainer/HBoxContainer/LeftPanel/AddHero
@onready var name_hero_input = $MarginContainer/HBoxContainer/LeftPanel/NameHeroInput

@onready var add_enemy = $MarginContainer/HBoxContainer/RightPanel/AddEnemy
@onready var name_enemy_input = $MarginContainer/HBoxContainer/RightPanel/NameEnemyInput

@onready var heroes_container = $MarginContainer/HBoxContainer/LeftPanel/HeroesContainer
@onready var enemies_container = $MarginContainer/HBoxContainer/RightPanel/EnemiesContainer

# Char Row
@export var character_row_scene: PackedScene


var hero: Character
var enemy: Character

var heroes: Party
var enemies: Party

func _ready():
	# Cargo las parties
	heroes = Party.new()
	enemies = Party.new()
	
	# Conecta input con el enter y carga el nombre en la party
	name_hero_input.text_submitted.connect(_on_name_hero_submitted)
	add_hero.pressed.connect(_on_add_hero)
	
	# Conecta input con el enter y carga el nombre en la party
	name_enemy_input.text_submitted.connect(_on_name_enemy_submitted)
	add_enemy.pressed.connect(_on_add_enemy)
	
	# Inicial
	hero = Character.new()
	hero.name = "Hero"
	hero.max_hp = 100
	hero.attack = 20
	hero.defense = 5
	
	heroes.add_member(hero)
	
	enemy = Character.new()
	enemy.name = "Enemy"
	enemy.max_hp = 100
	enemy.attack = 20
	enemy.defense = 5
	
	enemies.add_member(enemy)
	
	update_ui()

func update_ui():

	for child in heroes_container.get_children():
		child.queue_free()

	for member in heroes.members:
		var row = character_row_scene.instantiate()
		row.set_character(member)
		heroes_container.add_child(row)

		
	# Limpiar heroes
	for child in heroes_container.get_children():
		child.queue_free()
	
	# Limpiar enemigos
	for child in enemies_container.get_children():
		child.queue_free()
	
	# Render heroes
	for member in heroes.members:
		var label = Label.new()
		label.text = member.name + " | HP: " + str(member.max_hp)
		heroes_container.add_child(label)
	
	# Render enemigos
	for member in enemies.members:
		var label = Label.new()
		label.text = member.name + " | HP: " + str(member.max_hp)
		enemies_container.add_child(label)
	
func _on_add_hero():
	hero = Character.new()
	
	var input_name = name_hero_input.text.strip_edges()
	
	if input_name == "":
		hero.name = "Hero " + str(heroes.members.size() + 1)
	else:
		hero.name = input_name
	
	hero.max_hp = 100
	hero.attack = 10 + heroes.members.size() * 2
	hero.defense = 5
	
	heroes.add_member(hero)
	
	name_hero_input.text = ""  # limpiar input
	
	update_ui()
	
func _on_add_enemy():
	enemy = Character.new()
	
	var input_name = name_enemy_input.text.strip_edges()
	
	if input_name == "":
		enemy.name = "Enemy " + str(enemies.members.size() + 1)
	else:
		enemy.name = input_name
	
	enemy.max_hp = 100
	enemy.attack = 10 + enemies.members.size() * 2
	enemy.defense = 5
	
	enemies.add_member(enemy)
	
	name_enemy_input.text = ""  # limpiar input
	
	update_ui()

func _on_name_hero_submitted(_new_text):
	_on_add_hero()
	
func _on_name_enemy_submitted(_new_text):
	_on_add_enemy()
