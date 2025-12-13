class_name ThreatMarker
extends BaseMarker

var target: Node2D

func set_target(body: Node2D) -> void:
	target = body

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		print("ThreatMarker freed: target invalid")
		return

	super._process(delta)
