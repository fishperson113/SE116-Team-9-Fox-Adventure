class_name AmbienceArea2D
extends Area2D

@export var ambience_music_id: String = "boss_fight"  # ID music ambience
@export var volume_db: float = 0.0  # Volume for ambience music
@export var fade_in: float = 0.5  # Time fade in (seconds)


# Save current music id to restore when exiting the area
var previous_music_id: String = ""
var is_player_inside: bool = false

func _ready() -> void:
	if not AudioManager:
		push_error("AudioManager not found! Make sure it's in autoload.")
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(_body: Node2D) -> void:
	if is_player_inside:
		return  # already handled
	is_player_inside = true
	# save current music id (get from AudioManager)
	previous_music_id = AudioManager.get_current_music_id()
	# play ambience music with fade in
	AudioManager.play_music(ambience_music_id, volume_db, fade_in)
	print("Ambience music started: ", ambience_music_id)


func _on_body_exited(_body: Node2D) -> void:
	if not is_player_inside:
		return
	is_player_inside = false
	# play previous music with fade in
	AudioManager.play_music(previous_music_id, volume_db, fade_in)
	print("Restored previous music: ", previous_music_id)
