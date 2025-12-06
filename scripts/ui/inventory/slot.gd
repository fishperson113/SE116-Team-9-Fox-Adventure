extends Panel
class_name Slot

@onready var icon: TextureRect = $Icon
@onready var qty: Label = $Number

var item_type: String = ""
var item_detail        # Variant (Resource hoặc Dictionary)
var quantity: int = 0

func set_item(texture: Texture2D, type: String, detail, amount: int = 1):
	icon.texture = texture

	item_type = type
	item_detail = detail   # resource không cần duplicate
	quantity = amount

	qty.text = str(quantity)
	qty.visible = quantity > 1


func clear_slot():
	icon.texture = null
	qty.visible = false

	item_type = ""
	item_detail = null
	quantity = 0


func _get_drag_data(at_position):
	if icon.texture == null:
		return null

	var data := {
		"texture": icon.texture,
		"item_type": item_type,
		"item_detail": item_detail,
		"count": quantity,
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

	# Backup current slot
	var cur_tex = icon.texture
	var cur_type = item_type
	var cur_detail = item_detail
	var cur_count = quantity

	# Set new data from src
	set_item(
		data["texture"],
		data["item_type"],
		data["item_detail"],
		data["count"]
	)

	# Put old data into source slot
	if cur_tex == null:
		src.clear_slot()
	else:
		src.set_item(cur_tex, cur_type, cur_detail, cur_count)
