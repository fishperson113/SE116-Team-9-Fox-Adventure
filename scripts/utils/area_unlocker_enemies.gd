extends Node2D

@onready var enemy_test_area: Area2D = $EnemyTestArea

func _ready():
	print(enemy_test_area.get_overlapping_bodies().size())
