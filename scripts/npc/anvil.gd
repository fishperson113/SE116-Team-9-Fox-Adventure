extends InteractiveArea2D

@export var miniggame_ui: Control
@export var material_panel: Control
@onready var key_signal: Sprite2D=$KeySignal
var player_in_area = false

func _ready() -> void:
	key_signal.visible = false
	interacted.connect(_on_interacted)
	interaction_unavailable.connect(_on_exit_area)
	material_panel.material_selected.connect(_start_minigame)
	super._ready()


func _on_interacted(): 
	print("interact with anvil") 
	material_panel.open() 


func _start_minigame(mat_id):
	material_panel.close()
	miniggame_ui.open(mat_id)


func _on_exit_area():
	# nếu người chơi ra khỏi vùng → tự đóng popup
	if material_panel.visible:
		material_panel.close()
		
func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true
		key_signal.visible = true

func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false
		key_signal.visible = false
