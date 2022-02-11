extends Control





var active = false



#toggles menu when you press ESC
func _input(_event):
	if Input.is_action_just_pressed("escape"):
		active = !active;get_tree().paused=active
		update_menu()


#transitions the menu
func update_menu():
	$Tween.interpolate_property(self,"rect_position",rect_position,Vector2(0,608)*int(!active),0.5,Tween.TRANS_CIRC)
	$Tween.start()

#continues game
func _on_cont_pressed():
	active = false;get_tree().paused=active
	update_menu()


#returns to title screen
func _on_return_pressed():
	get_tree().paused=false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/title/title.tscn")
