extends CanvasLayer

@onready var num_blade_ui: Label = $"Items/4/NumBlade"
@onready var num_coin_ui: Label = $"Items/3/NumCoin"
@onready var num_copper_ui: Label = $"Items/5/NumCopper"
@onready var num_iron_ui: Label =$"Items/6/NumIron"
@onready var num_gold_ui: Label = $"Items/7/NumGold"

@onready var special_skill_bar: TextureProgressBar = $SpecialSkillBar
@onready var special_skill_text: Label = $SpecialSkillBar/ProgressText
@onready var special_skill_countdown_bar: TextureProgressBar = $SpecialSkillCountDown
func _ready() -> void:
	$SettingsButton.connect("button_down", Callable(self, "_on_settings_button_down"))
	$TutorialButton.connect("button_down", Callable(self, "_on_tutorial_button_down"))
	change_blade_ui()
	change_coin_ui()
	change_material_ui()
	
	special_skill_bar.max_value = GameManager.player.max_special_skill_attempt
	special_skill_countdown_bar.max_value = GameManager.player.special_skill_resolve_timer.wait_time
	change_progress_text()
	GameManager.modifyBlade.connect(change_blade_ui)
	GameManager.coinChange.connect(change_coin_ui)
	GameManager.materialChange.connect(change_material_ui)
	GameManager.inspectSkillBar.connect(inspect_special_skill_bar)
	GameManager.player.specialSkillResolveChanged.connect(change_countdown_ui)
	GameManager.player.skillAttemptChanged.connect(change_attempt_ui)
	
func _on_settings_button_down():
	var scene = load("res://scenes/ui/Setting.tscn").instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.add_child(scene)
	
	var nine_patch = scene.get_node("NinePatchRect")
	if nine_patch:
		var viewport_size = get_viewport().get_visible_rect().size
		nine_patch.position = (viewport_size - nine_patch.size) / 2
	
	get_tree().paused = true

func _on_tutorial_button_down():
	var scene = load("res://scenes/ui/tutorial.tscn").instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.add_child(scene)
	
	get_tree().paused = true

func change_blade_ui():
	num_blade_ui.text = str(GameManager.blade_count)
	
func change_coin_ui():
	num_coin_ui.text= str(GameManager.coin_count)

func change_material_ui():
	num_copper_ui.text = str(GameManager.materials_wallet.get("copper", 0))
	num_iron_ui.text = str(GameManager.materials_wallet.get("iron", 0))
	num_gold_ui.text = str(GameManager.materials_wallet.get("gold", 0))

func inspect_special_skill_bar(is_toggle: bool):
	special_skill_bar.visible = is_toggle
	special_skill_countdown_bar.visible = is_toggle

func change_attempt_ui(att_value: float):
	special_skill_bar.value = att_value
	change_progress_text()

func change_countdown_ui(time_value: float):
	special_skill_countdown_bar.value = time_value

func change_progress_text():
	special_skill_text.text = str(int(special_skill_bar.value)) + "/" + str(int(special_skill_bar.max_value))
