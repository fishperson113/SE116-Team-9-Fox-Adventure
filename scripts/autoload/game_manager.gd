extends Node

#target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}

var current_stage = ""
var player: Player = null
var player_has_blade: bool = false
func _ready() -> void:
	# Load checkpoint data when game starts
	load_checkpoint_data()
	
	pass
func collect_blade():
	if player_has_blade:
		return

	player_has_blade = true
	
	if player != null:
		player.collected_blade()
		print("GameManager: Player has collected the blade!")
	else:
		printerr("GameManager: Could not find player node to give blade to.")
#change stage by path and target portal name
func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	target_portal_name = _target_portal_name
	#change scene to stage path
	get_tree().change_scene_to_file(stage_path)


#call from dialogic
func call_from_dialogic(msg:String = ""):
	#Dialogic.VAR["PlayerScore"] = 30
	print("Call from dialogic " + msg)


#respawn at portal or door
func respawn_at_portal() -> bool:
	if not target_portal_name.is_empty():
		player.global_position = current_stage.find_child(target_portal_name).global_position
		GameManager.target_portal_name = ""
		true
	return false


# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state":player_state_dict,
		"stage_path": current_stage.scene_file_path
	}
	print("Checkpoint saved: ", checkpoint_id)


func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

#respawn at checkpoint
func respawn_at_checkpoint() -> void:
	if current_checkpoint_id.is_empty():
		print("No checkpoint available")
		return
	
	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		print("Checkpoint data not found")
		return
	
	# Load the stage if different
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	
	if current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		return
		
	# Can change stage if different but not implemented yet to test
	#	change_stage(checkpoint_stage, "")
	#	# Wait for scene to load
	#	await get_tree().process_frame

	if player != null:
		var player_state: Dictionary = checkpoint_info.get("player_state")
		if player_state == null:
			return
		player.load_state(player_state)
		print("Player respawned at checkpoint: ", current_checkpoint_id)
	else:
		print("Player not found for respawn")

#check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded from save file")

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")
