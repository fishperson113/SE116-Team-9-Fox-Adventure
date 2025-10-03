extends BaseCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_form"):
		var new_type: int
		if character_type == 3:
			new_type = 0
		else:
			new_type = character_type + 1
		change_player_type(new_type)
