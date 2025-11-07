extends Sprite2D

func _ready():
	var width = 77
	var height = 9
	
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	var red = Color(1.0, 0.2, 0.2, 1.0)
	
	# Vẽ với cắt xiên: hàng đầu cắt 2, hàng cuối cắt 1
	for y in range(height):
		for x in range(width):
			var cut_amount
			
			if y == 0:
				# Hàng đầu tiên: cắt 2 pixels
				cut_amount = 2
			elif y == height - 1:
				# Hàng cuối cùng: cắt 1 pixel
				cut_amount = 2
			else:
				# Các hàng giữa: interpolate từ 2 xuống 1
				var progress = float(y) / float(height - 1)
				cut_amount = int(2.0 - progress)  # Giảm dần từ 2 xuống 1
			
			# Vẽ nếu x nằm trong vùng không bị cắt
			if x < width - cut_amount:
				img.set_pixel(x, y, red)
	
	var tex = ImageTexture.create_from_image(img)
	texture = tex
	img.save_png("res://progress_76x14_cut_2_to_1.png")
	print("✅ Đã cắt: hàng 0 (2px), hàng 13 (1px)!")
