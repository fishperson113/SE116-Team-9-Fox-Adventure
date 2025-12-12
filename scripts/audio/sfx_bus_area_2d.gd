extends Area2D

@export var target_bus_name: String = ""
var previous_bus_name: String = "SFX"

var is_player_inside: bool = false

func _ready() -> void:
	if not AudioManager:
		push_error("AudioManager not found! Make sure it's in autoload.")
		return
	# connect signals to detect player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body: Node2D) -> void:
	if is_player_inside:
		return  # already handled
	is_player_inside = true
   
	if AudioManager:
		previous_bus_name = AudioManager.get_current_sfx_bus_name()
	# switch to target bus
	_switch_sfx_bus(target_bus_name)
	print("Player entered area - Switched to bus: ", target_bus_name)

func _on_body_exited(_body: Node2D) -> void:
	# if not player inside, return
	if not is_player_inside:
		return
	is_player_inside = false
	# switch back to default bus
	_switch_sfx_bus(previous_bus_name)
	print("Player exited area - Switched back to bus: ", previous_bus_name)

func _switch_sfx_bus(bus_name: String) -> void:
	if not AudioManager:
		return
	AudioManager.switch_sfx_bus(bus_name)
