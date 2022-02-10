extends Control



func _ready():
	$TitleAnim.play("open_game")


func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_game.tscn")



func _on_settings_pressed():
	$Tween.interpolate_property($main_page,"rect_position",Vector2.ZERO,Vector2(0,616),0.5,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($settings_page,"rect_position",Vector2(0,616),Vector2.ZERO,0.5,Tween.TRANS_CUBIC)
	$Tween.start()
