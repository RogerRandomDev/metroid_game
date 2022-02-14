extends Control



func _ready():
	OS.window_fullscreen=true
	$TitleAnim.play("open_game")


func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_game.tscn")



func _on_settings_pressed():
	$Tween.interpolate_property($main_page,"rect_position",Vector2.ZERO,Vector2(0,616),0.5,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($settings_page,"rect_position",Vector2(0,616),Vector2.ZERO,0.5,Tween.TRANS_CUBIC)
	$Tween.start()


func _on_back_pressed():
	$Tween.interpolate_property($settings_page,"rect_position",Vector2.ZERO,Vector2(0,616),0.5,Tween.TRANS_CUBIC)
	$Tween.interpolate_property($main_page,"rect_position",Vector2(0,616),Vector2.ZERO,0.5,Tween.TRANS_CUBIC)
	$Tween.start()


func _on_FullScreen_toggled(button_pressed):
	OS.window_fullscreen=button_pressed


func _on_quit_pressed():
	get_tree().quit()

#sets the difficulty
func _on_easy_pressed():Global.cur_difficulty="EASY"
func _on_normal_pressed():Global.cur_difficulty="NORMAL"
func _on_hard_pressed():Global.cur_difficulty="HARD"
func _on_rage_pressed():Global.cur_difficulty="RAGE"
func _on_perfection_pressed():Global.cur_difficulty="PERFECTION"
