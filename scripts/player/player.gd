class_name Player
extends BaseCharacter

signal gemsChanged
signal keysChanged
signal coinsChanged

@export var jump_step: int = 2
@export var current_jump: int = 0

var weapon_thrower: WeaponThrower

@onready var inventory: Inventory = $Inventory
@onready var item_storer: ItemStorer = $ItemStorer
var is_invulnerable: bool = false
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer

# This will be used to accept reflect damage
@onready var hit_area: HitArea2D = $Direction/HitArea2D

func _ready() -> void:
	get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
	fsm = FSM.new(self, $States, $States/Idle)
	weapon_thrower = $WeaponThrower
	# Set the attacker to take damage from reflect
	hit_area.set_attacker(self)
	super._ready()
	GameManager.player = self

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_form"):
		var new_type: int
		if character_type == 3:
			new_type = 0
		else:
			new_type = character_type + 1
		change_player_type(new_type)

func change_player_type(char_type: int) -> void:
	var animation_reset = get_reset_animation_name(current_animation)
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

#func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	#print("player speed: ", velocity.y)
