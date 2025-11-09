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

func _ready() -> void:
	super._ready()
	_init_hiding_state()
	_init_hide_state()
	_init_emerging_state()
	_init_hit_area()
	pass

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(spike)

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
