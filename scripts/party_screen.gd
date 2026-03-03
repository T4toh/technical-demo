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
	# Para que los nombres random sean diferentes cada vez
	randomize()
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
	hero = Character.new("", 100, 20, 5)
	heroes.add_member(hero)
	
	enemy = Character.new("", 100, 20, 5)
	enemies.add_member(enemy)
	
	update_ui()

func update_ui():

	# Limpiar heroes
	for child in heroes_container.get_children():
		child.queue_free()

	# Limpiar enemigos
	for child in enemies_container.get_children():
		child.queue_free()

	# Render heroes
	for member in heroes.members:
		# Primero creo el row para que no explote
		var row = character_row_scene.instantiate()
		# Luego lo agrego al contenedor para que se muestre
		heroes_container.add_child(row)
		# Finalmente le paso el personaje para que se muestre la info
		row.set_character(member)

	# Render enemigos
	for member in enemies.members:
		var row = character_row_scene.instantiate()
		enemies_container.add_child(row)
		row.set_character(member)
	
func _on_add_hero():
	var input_name = name_hero_input.text.strip_edges()
	var max_hp = 100
	var attack = 10 + heroes.members.size() * 2
	var defense = 5

	hero = Character.new(
		input_name,
		max_hp,
		attack,
		defense
	)
	
	heroes.add_member(hero)
	
	name_hero_input.text = ""  # limpiar input
	
	update_ui()
	
func _on_add_enemy():
	var input_name = name_enemy_input.text.strip_edges()
	var max_hp = 100
	var attack = 10 + enemies.members.size() * 2
	var defense = 5

	enemy = Character.new(
		input_name,
		max_hp,
		attack,
		defense
	)
	
	enemies.add_member(enemy)
	
	name_enemy_input.text = ""  # limpiar input
	
	update_ui()

func _on_name_hero_submitted(_new_text):
	_on_add_hero()
	
func _on_name_enemy_submitted(_new_text):
	_on_add_enemy()
