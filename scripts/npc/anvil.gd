extends InteractiveArea2D

@export var minigame_ui: Control
@export var material_panel: Control

func _ready() -> void:
	interacted.connect(_on_interacted)
	super._ready()
	
func _on_interacted():
	print("interact with anvil")
	material_panel.open()
	material_panel.material_selected.connect(_start_minigame)
		
func _start_minigame(mat_id):
	minigame_ui.open(mat_id)
