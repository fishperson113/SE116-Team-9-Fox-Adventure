class_name Raft
extends AnimatableBody2D

enum State { IDLE, MOVING, DISEMBARKING }
var current_state: State = State.IDLE
@export var speed = 100.0
@export var travel_range_x = 400.0
@onready var boat_sail: AnimatedSprite2D = $BoatSail
@onready var ship_helm: AnimatedSprite2D = $ShipHelm
@onready var detector_area: Area2D = $Detector
var jump_force = Vector2(500,-250)
var player_on_boat = false
var _player: Player = null
var _start_position: Vector2
var _target_position: Vector2

func _ready():
	_start_position = self.position
	_target_position = _start_position + Vector2(travel_range_x, 0)	
	
	ship_helm.play("idle")
	boat_sail.stop()

func _physics_process(delta):
	match current_state:
		State.IDLE:
			_state_idle()
		State.MOVING:
			_state_moving(delta)
		#State.DISEMBARKING:
			#_state_disembarking()

func _state_idle():
	if ship_helm.animation != "idle":
		ship_helm.play("idle")
	if boat_sail.is_playing():
		boat_sail.stop()

func _state_moving(delta):
	if self.position.is_equal_approx(_target_position):
		#_player.fsm.change_state(_player.fsm.states.launch)
		current_state = State.IDLE
		return
	
	if ship_helm.animation != "turn":
		ship_helm.play("turn")
	if not boat_sail.is_playing():
		boat_sail.play("default")
		
	self.position = self.position.move_toward(_target_position, speed * delta)
	#if(Input.is_action_just_pressed("jump")):
		#skip()f

func _state_disembarking():
	_player.fsm.change_state(_player.fsm.states.launch)
	current_state = State.IDLE
	
func _on_detector_area_body_entered(body):
		#var player = body as Player
		#if player:  
		player_on_boat = true
		current_state=State.MOVING
			#_player = player
			#if "player_on_boat" in player:  
				#player.player_on_boat = true

func _on_detector_area_body_exited(body):
		#var player = body as Player
		#if player:  
			#player_on_boat = false
			#if "player_on_boat" in player:  
				#player.player_on_boat = false
			#_player = null
		player_on_boat = false
		current_state=State.IDLE
		
func start_moving():
	if player_on_boat and current_state == State.IDLE:
		current_state = State.MOVING

func skip():
	boat_sail.stop()
	ship_helm.play("idle")
	self.position = _target_position
	_player.position = _target_position
	_player.position.y -= 20
	current_state = State.DISEMBARKING
