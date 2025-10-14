extends Enemy

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
	fsm=FSM.new(self,$States,$States/Normal)
	super._ready()
func start_hide_mode():
	_animation_controller.change_animation("hide")
	pass
	
func end_hide_mode():
	pass
	
func update_hide_mode(_delta: float):
	pass

func start_hiding_mode():
	_movement_speed = 0
	
	_animation_controller.change_animation("hiding")
	pass
	
func end_hiding_mode():
	pass
	
func update_hiding_mode(_delta: float):
	pass

func start_emerging_mode():
	_animation_controller.change_animation("emerging")
	pass
	
func end_emerging_mode():
	pass
	
func update_emerging_mode(_delta: float):
	pass
