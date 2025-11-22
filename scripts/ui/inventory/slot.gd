extends Panel
class_name Slot

@onready var icon: TextureRect = $Icon
@onready var qty: Label = $Number

var item_type: String = ""
var item_detail: Dictionary = {}
var quantity: int = 0


func set_item(texture: Texture2D, type: String, detail: Dictionary, amount: int = 1):
	icon.texture = texture
	item_type = type
	item_detail = detail.duplicate(true)
	quantity = amount

	qty.text = str(quantity)

	if quantity > 1:
		qty.show()
	else:
		qty.hide()


func clear_slot():
	icon.texture = null
	qty.hide()

	item_type = ""
	item_detail = {}
	quantity = 0


func _gui_input(event):
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if icon.texture != null:
			set_drag_preview(icon)


func _get_drag_data(at_position):
	if icon.texture == null:
		return null

	var data := {
		"texture": icon.texture,
		"item_type": item_type,
		"item_detail": item_detail.duplicate(true),		"count": quantity,
		"source_slot": self
	}

	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.size = icon.size
	set_drag_preview(preview)

	return data


func _can_drop_data(at_position, data):
	return data is Dictionary and data.has("item_type")


func _drop_data(at_position, data):
	var src: Slot = data["source_slot"]

	if src == self:
		return

	var cur_texture = icon.texture
	var cur_type = item_type
	var cur_detail = item_detail.duplicate(true)
	var cur_count = quantity

	set_item(
		data["texture"],
		data["item_type"],
		data["item_detail"],
		data["count"]
	)

	if cur_texture == null:
		src.clear_slot()
	else:
		src.set_item(cur_texture, cur_type, cur_detail, cur_count)

	if icon.texture == null:
		qty.hide()
