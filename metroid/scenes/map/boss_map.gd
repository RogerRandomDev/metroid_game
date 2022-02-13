extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.play_music("fight_song")


func change_scene(scene_name):
	Global.play_music("base_song",4.0)
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(load("res://Scenes/"+scene_name+".tscn"))
