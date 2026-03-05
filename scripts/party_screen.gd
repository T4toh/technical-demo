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

@onready var end_combat_dialog = $EndCombatDialog

# Units

@export var battle_unit_scene: PackedScene

@onready var hero_side = $Bot/Combat/BG/HeroSide
@onready var enemy_side = $Bot/Combat/BG/EnemySide




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
	# Conecta el botón de reiniciar combate
	end_combat_dialog.confirmed.connect(reset_combat)


	# Inicial
	hero = Character.new("", 100, 20, 5)
	heroes.add_member(hero)
	
	enemy = Character.new("", 100, 20, 5)
	enemies.add_member(enemy)

	await get_tree().process_frame
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
	
	update_battlefield()
	
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

	var attacker = heroes.get_alive_members_random()
	var target = enemies.get_alive_members_random()

	var damage = target.take_damage(attacker.attack)

	# UNIDADES VISUALES
	var attacker_unit = get_unit_for_character(attacker, hero_side)
	var target_unit = get_unit_for_character(target, enemy_side)

	if attacker_unit:
		attacker_unit.play_attack_animation()

	if target_unit:
		target_unit.play_hit_animation()
		target_unit.update_visual()  # 🔥 refrescar estado muerte

	add_log(
		attacker.name + " atacó a " + target.name + " e hizo " + str(damage) + " DMG",
		Color.GREEN
	)
	refresh_character_rows()
	check_victory()

func on_enemy_attack():
	var alive = heroes.get_alive_members()
	if alive.is_empty():
		return
	var attacker = enemies.get_alive_members_random()
	var target = heroes.get_alive_members_random()

	var damage = target.take_damage(attacker.attack)
	# UNIDADES VISUALES
	var attacker_unit = get_unit_for_character(attacker, enemy_side)
	var target_unit = get_unit_for_character(target, hero_side)

	if attacker_unit:
		attacker_unit.play_attack_animation()
	if target_unit:
		target_unit.play_hit_animation()
		target_unit.update_visual()  # 🔥 refrescar estado muerte



	add_log(
		attacker.name + " atacó a " + target.name + " e hizo "+ str(damage) + " DMG",
		Color.RED
	)
	refresh_character_rows()
	check_victory()


func add_log(text: String, color: Color):
	var label = RichTextLabel.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	label.bbcode_enabled = true
	label.scroll_active = false
	label.fit_content = true
	
	label.text = "[color=%s]%s[/color]" % [color.to_html(), text]

	battle_log.add_child(label)

	await get_tree().process_frame
	battle_scroll.scroll_vertical = battle_scroll.get_v_scroll_bar().max_value

func update_battlefield():
	if battle_unit_scene == null:
		push_error("BattleUnit scene not assigned!")
		return

	for c in hero_side.get_children():
		c.queue_free()

	for c in enemy_side.get_children():
		c.queue_free()
	
	var spacing = 80
	var index = 0

	# HEROES
	for member in heroes.members:
		var unit = battle_unit_scene.instantiate()
		hero_side.add_child(unit)

		unit.set_character(member, false)
		unit.set_attack_direction(1)

		unit.position = Vector2(index * spacing + 20, hero_side.size.y - 120)
		index += 1

	# Reseteo el index para los enemigos
	index = 0

	# ENEMIES
	for member in enemies.members:
		var unit = battle_unit_scene.instantiate()
		enemy_side.add_child(unit)

		unit.set_character(member, true)
		unit.set_attack_direction(-1)

		unit.position = Vector2(
			enemy_side.size.x - (index + 1) * spacing - 20,
			enemy_side.size.y - 120
		)
		index += 1

func get_unit_for_character(character: Character, side: Node) -> Node:
	for unit in side.get_children():
		if unit.character == character:
			return unit
	return null


func check_victory():
	var heroes_alive = heroes.get_alive_members()
	var enemies_alive = enemies.get_alive_members()

	if heroes_alive.is_empty():
		end_combat_dialog.dialog_text = "Los enemigos ganaron.\n¿Reiniciar combate?"
		disable_combat()

	elif enemies_alive.is_empty():
		end_combat_dialog.dialog_text = "Los héroes ganaron.\n¿Reiniciar combate?"
		disable_combat()

func disable_combat():
	attack_hero_button.disabled = true
	attack_enemy_button.disabled = true
	add_enemy.disabled = true
	add_hero.disabled = true

	add_log("COMBATE FINALIZADO", Color.YELLOW)
	end_combat_dialog.popup_centered()  # 🔥 muestra modal

func refresh_character_rows():
	for row in heroes_container.get_children():
		row.update_display()

	for row in enemies_container.get_children():
		row.update_display()

func reset_combat():
	heroes.members.clear()
	enemies.members.clear()
	
	attack_hero_button.disabled = false
	attack_enemy_button.disabled = false
	add_enemy.disabled = false
	add_hero.disabled = false
	
	clear_battle_log()  # 🔥 en vez de battle_log.clear()
	
	end_combat_dialog.hide()
	update_ui()


func clear_battle_log():
	for child in battle_log.get_children():
		child.queue_free()
