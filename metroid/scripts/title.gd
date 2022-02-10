extends Control



func _ready():
	$TitleAnim.play("open_game")


func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_game.tscn")


func _on_settings_pressed():
	pass # Replace with function body.
