extends StatefulEnemy

#Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Tự động thu mình vào mai trong 3 giây
#Người chơi chạm vào rùa hoặc mai rùa đều sẽ mất máu theo Spike
#Mai rùa không thể bị phá huỷ
#Ở trong mai 3 giây rùi lại chui ra

@export var normal_time: float = 3.0
@export var hiding_time: float = 1.0
@export var hide_time: float = 3.0
@export var emerging_time: float = 1.0

var _is_hitted: bool = false

func _ready() -> void:
	super._ready()
	_init_hiding_state()
	_init_hide_state()
	_init_emerging_state()
	pass

func _init_hiding_state() -> void:
	if has_node("States/Hiding"):
		var state : EnemyState = get_node("States/Hiding")
		state.enter.connect(start_hiding)

func _init_hide_state() -> void:
	if has_node("States/Hide"):
		var state : EnemyState = get_node("States/Hide")
		state.enter.connect(start_hide)

func _init_emerging_state() -> void:
	if has_node("States/Emerging"):
		var state : EnemyState = get_node("States/Emerging")
		state.enter.connect(start_emerging)

func start_hide():
	change_animation("hide")
	pass

func start_hiding():
	_movement_speed = 0
	change_animation("hiding")
	pass

func start_emerging():
	change_animation("emerging")
	pass

func start_sleep() -> void:
	_movement_speed = 0
	change_animation("sleep")
	pass

func end_sleep() -> void:
	pass

func update_sleep(_delta: float) -> void:
	if _is_hitted:
		fsm.change_state(fsm.states.normal)
	pass

func _on_hit_area_2d_hitted(body):
	super._on_hit_area_2d_hitted(body)
	_is_hitted = true
	pass
