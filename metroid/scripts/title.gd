extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$TitleAnim.play("open_game")


func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_game.tscn")
