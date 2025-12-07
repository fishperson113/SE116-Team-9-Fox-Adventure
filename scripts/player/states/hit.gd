extends PlayerState

@onready var sfx_hit: AudioStreamPlayer = $"../../SFX/Hit"
@onready var trajectory_line: Line2D = $"../../WeaponThrower/TrajectoryLine"

func _enter() -> void:
	sfx_hit.play()
	trajectory_line.visible = false
	obj.change_animation("hit")
	obj.velocity.y = -250
	obj.velocity.x = -250 * sign(obj.velocity.x)
	timer = 0.5
	pass

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.states.idle)
