extends Button

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	var inv := get_parent() 
	if inv:
		inv.close_inventory()
	else:
		print("❌ Button không nằm trong AllInventory!")
