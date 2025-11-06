extends Raft

func _ready() -> void:
	_start_position = self.position
	_target_position = _start_position + Vector2(travel_range_x, 0)	
	
	ship_helm.play("idle")
	boat_sail.stop()

func _physics_process(delta):
	match current_state:
		State.IDLE:
			_state_idle()
		State.MOVING:
			_state_moving(delta)
		State.DISEMBARKING:
			_state_disembarking()
			
func _state_moving(delta):
	if self.position.is_equal_approx(_target_position):
		_player.fsm.change_state(_player.fsm.states.launch)
		current_state = State.IDLE
		return
	
	if ship_helm.animation != "turn":
		ship_helm.play("turn")
	if not boat_sail.is_playing():
		boat_sail.play("default")
		
	self.position = self.position.move_toward(_target_position, speed * delta)
	if(Input.is_action_just_pressed("jump")):
		skip()
		
func _on_detector_area_body_entered(body):
	var player = body as Player
	if player:  
		player_on_boat = true
		current_state=State.MOVING
		_player = player
		if "player_on_boat" in player:  
			player.player_on_boat = true
				
func _on_detector_area_body_exited(body):
	var player = body as Player
	if player:
		player_on_boat = false
		if "player_on_boat" in player:
			player.player_on_boat = false
		_player = null
		current_state = State.IDLE
