extends Control
# Se usa el nombre del botón
# En este caso es AddHeroButton, lo mismo debería estar en el box.
@onready var add_hero = $Top/PartyList/LeftPanel/AddHero
@onready var name_hero_input = $Top/PartyList/LeftPanel/NameHeroInput

@onready var add_enemy = $Top/PartyList/RightPanel/AddEnemy
@onready var name_enemy_input = $Top/PartyList/RightPanel/NameEnemyInput

@onready var heroes_container = $Top/PartyList/LeftPanel/HeroesContainer
@onready var enemies_container = $Top/PartyList/RightPanel/EnemiesContainer

#Combat

@onready var attack_hero_button = $Bot/Combat/Buttons/HBoard/HAttack
@onready var attack_enemy_button = $Bot/Combat/Buttons/EBoard/EAttack

@onready var battle_log = $Bot/Combat/BattleLogContainer/BattleLog
@onready var battle_scroll = $Bot/Combat/BattleLogContainer




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

	# Conecta botones de ataque
	attack_hero_button.pressed.connect(on_hero_attack)
	attack_enemy_button.pressed.connect(on_enemy_attack)
	
	# Inicial
	hero = Character.new("", 100, 20, 5)
	heroes.add_member(hero)
	
	enemy = Character.new("", 100, 20, 5)
	enemies.add_member(enemy)
	add_log("SI VES ESTO, FUNCIONA", Color.YELLOW)
	print(battle_log)
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


# Combat

func on_hero_attack():
	var alive = enemies.get_alive_members()
	if alive.is_empty():
		return

	var attacker = heroes.get_alive_members()[0]
	var target = alive[randi() % alive.size()]
	var damage = max(attacker.attack - target.defense, 0)

	target.take_damage(attacker.attack)

	add_log(
		attacker.name + " atacó a " + target.name + " e hizo " + str(damage) + " DMG",
		Color.GREEN
	)

	update_ui()

func on_enemy_attack():
	var alive = heroes.get_alive_members()
	if alive.is_empty():
		return

	var attacker = enemies.get_alive_members()[0]
	var target = alive[randi() % alive.size()]
	var damage = max(attacker.attack - target.defense, 0)

	target.take_damage(attacker.attack)

	add_log(
		attacker.name + " atacó a " + target.name + " e hizo " + str(damage) + " DMG",
		Color.RED
	)

	update_ui()


func add_log(text: String, color: Color):
	var label = RichTextLabel.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	label.bbcode_enabled = true
	label.scroll_active = false
	
	label.text = "[color=%s]%s[/color]" % [color.to_html(), text]

	battle_log.add_child(label)

	await get_tree().process_frame
	battle_scroll.scroll_vertical = battle_scroll.get_v_scroll_bar().max_value
