extends PlayerState

@onready var trajectory_line: Line2D = $"../../WeaponThrower/TrajectoryLine"

func _enter() -> void:
	AudioManager.play_sound("player_hurt")
	trajectory_line.visible = false
	obj.change_animation("hit")
	obj.velocity.y = -250
	obj.velocity.x = -250 * sign(obj.velocity.x)
	timer = 0.5
	obj.invulnerable_effect.play("invulnerable")
	pass

func _update(_delta: float) -> void:
	if update_timer(_delta):
		if obj.is_on_floor():
			obj.current_jump = 0
			obj.current_dash = 0
			change_state(fsm.states.idle)
		else:
			change_state(fsm.states.fall)
