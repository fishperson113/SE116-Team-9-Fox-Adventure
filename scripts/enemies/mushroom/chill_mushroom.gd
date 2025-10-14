extends Enemy

#-	Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Người chơi không bị mất máu khi chạm vào
#Không có khả năng tấn công
func _ready() -> void:
	fsm=FSM.new(self,$States,$States/Normal)
	super._ready()
