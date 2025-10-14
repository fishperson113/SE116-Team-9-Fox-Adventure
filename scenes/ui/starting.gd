extends Node2D

@export var smoke_effect: PackedScene  

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer/ColorRect.visible = false 
	
func _process(delta: float) -> void:
	pass	
	
func _physics_process(delta: float) -> void:
	pass
	
func add_smoke_effect(pos: Vector2):
	var smoke_fx = smoke_effect.instantiate()
	smoke_fx.position = pos
	add_child(smoke_fx)
