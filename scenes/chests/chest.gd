class_name Chest
extends BaseCharacter

signal unlock_chest

var is_unlockable = false
var player: Player = null

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Closed)
	super._ready()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.inventory.is_key_available():
		player = body
		unlock_chest.connect(player.inventory.remove_key)
		is_unlockable = true
		print(is_unlockable)
	pass # Replace with function body.

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		if player:
			unlock_chest.disconnect(player.inventory.remove_key)
		player = null
		is_unlockable = false
		print(is_unlockable)
	pass # Replace with function body.
