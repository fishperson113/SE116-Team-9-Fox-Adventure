extends Node2D

@onready var tutorial_finish_marker: Marker2D = $World/TutorialFinishedMarker

func _ready() -> void:
	AudioManager.play_music("stage_music")
	#GameManager.initialize_systems()
	if GameManager.is_tutorial_finished:
		print("The tutorial is finished")
		GameManager.player.global_position = tutorial_finish_marker.global_position
