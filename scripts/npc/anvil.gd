extends InteractiveArea2D

@export var minigame_ui: Control
func _ready() -> void:
	interacted.connect(_on_interacted)
	super._ready()
	
func _on_interacted():
	print("interact with anvil")
	if minigame_ui:
		minigame_ui.open()
