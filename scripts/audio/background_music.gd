extends Node2D

@export var music_id:String = ""

func _ready():
	AudioManager.play_music(music_id) 
