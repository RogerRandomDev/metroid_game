extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventKey:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/title/title.tscn")
