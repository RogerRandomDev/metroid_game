extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.cur_difficulty=="PERFECTION":
		$Label5.text="|101|Not what you just did|101|"


func _input(event):
	if event is InputEventKey:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/title/title.tscn")
