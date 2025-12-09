class_name Chest
extends BaseCharacter

signal unlock_chest

var is_unlockable = true

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Closed)
	super._ready()

func _on__interaction_available() -> void:
	if fsm.current_state == fsm.states.open:
		print("The chest is already open")
		return
	
	if not GameManager.player.inventory.is_key_available():
		print("Player does not have any keys")
		return
	
	print("Player is standing next to the chest")
	pass # Replace with function body.

func _on_interaction_unavailable() -> void:
	print("Player is getting away from the chest")
	pass # Replace with function body.

func _on_interacted() -> void:
	if GameManager.player.inventory.is_key_available() and is_unlockable:
		fsm.change_state(fsm.states.open)
		#GameManager.player.inventory.remove_item("item_key", {})
	pass # Replace with function body.
