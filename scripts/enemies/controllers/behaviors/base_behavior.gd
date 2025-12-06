class_name BaseBehavior
extends RefCounted

signal behave

var owner: BaseCharacter

func _init(_owner: BaseCharacter) -> void:
	owner = _owner

func execute(input: BehaviorInput) -> void:
	# Virtual method — override in subclasses
	pass
