extends Minion

#-	Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Người chơi chạm vào sẽ bị mất máu theo Spike
#Không có khả năng tấn công

func _ready() -> void:
	super._ready()
	_init_hit_area()
	pass

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(spike)
