@tool
extends Spawner

func _ready():
	super._ready()
	_init_timer()
	pass
	
func _init_timer():
	var timer := $Timer
	timer.timeout.connect(_on_timeout)
	pass

func _on_timeout():
	super.bias_spawn()
