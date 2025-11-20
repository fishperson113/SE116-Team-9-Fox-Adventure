extends ProgressBar

## HealthBar tự động cập nhật từ BaseCharacter parent
## Ẩn ban đầu, chỉ hiện khi bị damage lần đầu

var tracked_character: BaseCharacter = null
var is_first_damage: bool = true  # Theo dõi lần damage đầu tiên

func _ready() -> void:
	# Ẩn healthbar ban đầu
	hide()
	
	# Tìm BaseCharacter trong parent hierarchy
	tracked_character = _find_character_parent()
	
	if tracked_character:
		print("✅ HealthBar tìm thấy character: ", tracked_character.name)
		print("   - Health: ", tracked_character.currentHealth, "/", tracked_character.maxHealth)
		
		# Kết nối signal
		tracked_character.healthChanged.connect(_on_health_changed)
		print("   - Đã kết nối signal healthChanged")
		
		# Thiết lập giá trị ban đầu (nhưng vẫn ẩn)
		max_value = tracked_character.maxHealth
		min_value = 0
		value = tracked_character.currentHealth
		print("   - HealthBar value: ", value, "/", max_value)
	else:
		push_warning("❌ HealthBar: Không tìm thấy BaseCharacter parent!")

# Tìm BaseCharacter trong parent nodes
func _find_character_parent() -> BaseCharacter:
	var current = get_parent()
	
	# Duyệt lên các parent node cho đến khi tìm thấy BaseCharacter
	while current != null:
		if current is BaseCharacter:
			return current
		current = current.get_parent()
	
	return null

# Callback khi health thay đổi
func _on_health_changed():
	print("🔔 Signal healthChanged được gọi!")
	
	if tracked_character:
		print("   - Health mới: ", tracked_character.currentHealth, "/", tracked_character.maxHealth)
		
		# Hiện healthbar lần đầu tiên bị damage
		if is_first_damage and tracked_character.currentHealth < tracked_character.maxHealth:
			show()
			is_first_damage = false
			print("   - Hiện HealthBar lần đầu")
		
		# Cập nhật max value nếu thay đổi
		if max_value != tracked_character.maxHealth:
			max_value = tracked_character.maxHealth
		
		# Cập nhật giá trị hiện tại
		value = tracked_character.currentHealth
		print("   - HealthBar value mới: ", value)
		
		# Ẩn healthbar khi chết
		if tracked_character.currentHealth <= 0:
			hide()
			print("   - Enemy đã chết, ẩn HealthBar")
