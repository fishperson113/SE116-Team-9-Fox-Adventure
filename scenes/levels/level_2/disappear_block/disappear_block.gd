extends RigidBody2D
class_name DisappearBlock

@onready var normal_sprite: Sprite2D = $Direction/Normal
@onready var disappeared_sprite: Sprite2D = $Direction/Disappeared

@onready var normal_collision: CollisionShape2D = $CollisionShape2D
@onready var normal_area: CollisionShape2D = $Direction/Area2D/CollisionShape2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var animation_name: String
@export var shaking_duration: float
var shaking_realtime_duration: float

@export var disappearing_duration: float
var disappearing_realtime_duration: float

enum BlockState {
	NORMAL,
	SHAKING,
	DISAPPEARED,
}
@onready var block_state: BlockState = BlockState.NORMAL

func _ready() -> void:
	change_block_state(BlockState.NORMAL)
	pass

func _process(delta: float) -> void:
	control_shaking(delta)
	control_disappearing(delta)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		change_block_state(BlockState.SHAKING)
	print("YES")
	pass # Replace with function body.

func change_block_state(new_block_state: BlockState) -> void:
	block_state = new_block_state
	implement_block_style()
	
func implement_block_style() -> void:
	if block_state == BlockState.NORMAL:
		normal_sprite.show()
		disappeared_sprite.hide()
		normal_collision.disabled = false
		normal_area.disabled = false
		animation_player.stop()
	
	elif block_state == BlockState.SHAKING:
		animation_player.play(animation_name)
		shaking_realtime_duration = shaking_duration
	
	elif block_state == BlockState.DISAPPEARED:
		normal_sprite.hide()
		disappeared_sprite.show()
		normal_collision.disabled = true
		normal_area.disabled = true
		animation_player.stop()
		disappearing_realtime_duration = disappearing_duration

func control_shaking(delta: float) -> void:
	if block_state == BlockState.SHAKING:
		shaking_realtime_duration -= delta
		if shaking_realtime_duration <= 0:
			change_block_state(BlockState.DISAPPEARED)
	pass
	
func control_disappearing(delta: float) -> void:
	if block_state == BlockState.DISAPPEARED:
		disappearing_realtime_duration -= delta;
		if disappearing_realtime_duration <= 0:
			change_block_state(BlockState.NORMAL)
	pass
