extends Node2D

@onready var tutorial_finish_marker: Marker2D = $World/TutorialFinishedMarker

func _ready() -> void:
	if GameManager.is_tutorial_finished:
		print("The tutorial is finished")
		GameManager.player.global_position = tutorial_finish_marker.global_position
