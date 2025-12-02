class_name Player
extends BaseCharacter

signal gemsChanged
signal keysChanged
signal coinsChanged

@export var jump_step: int = 2
@export var current_jump: int = 0

@export var max_dash: int = 1
@export var current_dash: int = 0

var weapon_thrower: WeaponThrower

@onready var inventory: Inventory = $Inventory
@onready var item_storer: ItemStorer = $ItemStorer
var is_invulnerable: bool = false
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

# This will be used to accept reflect damage
@onready var hit_area: HitArea2D = $Direction/HitArea2D
var decorator_manager: DecoratorManager = null
var weapon_manager: WeaponEquipmentManager= null
var attack_damage
var attack_speed
var base_speed
var is_equipped: bool = false
var is_dash: bool = false

func _ready() -> void:
	get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
	fsm = FSM.new(self, $States, $States/Idle)
	weapon_thrower = $WeaponThrower
	decorator_manager= DecoratorManager.new()
	decorator_manager.initialize(self)
	weapon_manager=WeaponEquipmentManager.new()
	# Set the attacker to take damage from reflect
	hit_area.set_attacker(self)
	super._ready()
	GameManager.player = self
	base_speed=movement_speed
	maxHealth=1000
	currentHealth=maxHealth
	equip_weapon(GameManager.equipped_weapon_path)

func _process(delta: float) -> void:
	print(current_dash)
	
	if current_dash == max_dash:
		animated_sprite.modulate = ColorManager.dash_color
	else:
		animated_sprite.modulate = ColorManager.normal_color
	pass
		
func change_player_type(char_type: int) -> void:
	var base_anim = current_animation if current_animation != null else "idle"
	var animation_reset = get_reset_animation_name(base_anim)
	character_type = char_type
	change_animation(animation_reset)

func get_animation_prefix() -> String:
	var char_type: String
	
	if character_type == 0: char_type = ""
	elif character_type == 1: char_type = "hat_"
	elif character_type == 2: char_type = "blade_"
	elif character_type == 3: char_type = "hat_blade_"
	
	return char_type

func change_animation(new_animation: String) -> void:
	if new_animation == "attack" and character_type == 0:
		return
	
	var char_type = get_animation_prefix()
	_next_animation = char_type + new_animation

func get_reset_animation_name(animation_name: String) -> String:
	var next_name: String = animation_name
	var char_type = get_animation_prefix()
	
	next_name = next_name.replace(char_type, "")
	return next_name

func _on_save_inventory_button_pressed() -> void:
	inventory.save_inventory()
	item_storer.save_slots()
	pass # Replace with function body.

func _on_hurt_area_2d_hurt(_attacker: BaseCharacter, direction: Vector2, damage: float) -> void:
	if is_invulnerable:
		return
	fsm.current_state.take_damage(damage)
	is_invulnerable = true
	invulnerability_timer.start(1.0)

func _on_invulnerability_timer_timeout() -> void:
	is_invulnerable = false

func set_empty_health() -> void:
	fsm.current_state.take_damage(currentHealth)
	pass
func equip_weapon(tres_path: String):
	if tres_path =="":
		return
	is_equipped=true
	var w := load(tres_path) as WeaponData
	if w == null:
		push_error("WeaponData load failed: " + tres_path)
		return

	# Update stats
	if w.blade:
		attack_damage = w.blade.damage

	if w.crossguard:
		maxHealth += w.crossguard.max_health

	if w.grip:
		attack_speed = w.grip.attack_speed

	if w.pommel:
		_apply_special_skill(w.pommel.special_skill)

	change_player_type(2)
	print("Player equipped craft weapon successfully!")
func unequip_weapon():
	if !is_equipped:
		return
	is_equipped=false
	_reset_weapon_stats()
	if character_type == 3:
		change_player_type(1) # còn hat
	else:
		change_player_type(0) # không còn gì
	print("Weapon unequipped.")
	
func _apply_special_skill(skill: String):
	match skill:
		"triple_jump":
			jump_step = 3
		"speed_up":
			movement_speed = base_speed * 2
		"dash":
			is_dash = true
		_:
			_reset_weapon_stats()

func _reset_weapon_stats():
	jump_step = 2   
	movement_speed=base_speed
	is_dash = false

func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}
	
func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
