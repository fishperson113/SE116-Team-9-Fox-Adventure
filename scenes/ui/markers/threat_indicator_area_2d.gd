class_name ThreadIndicatorArea2D
extends Area2D

@export var marker: PackedScene = null

var _marker_factory: PackedSceneFactory = null
var _markers: Dictionary = {}

func _ready() -> void:
	_marker_factory = PackedSceneFactory.new(self)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(_body):
	call_deferred("create_marker", _body)
	pass

func create_marker(_target: Node2D):
	var created_marker = _marker_factory.create(marker, "Markers", _target.position) as ThreatMarker
	created_marker.set_target(_target)
	_markers.set(_target, created_marker)

func _on_body_exited(_body):
	if _markers.has(_body):
		_markers.get(_body).queue_free()
	pass
