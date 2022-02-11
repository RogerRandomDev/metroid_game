extends Node2D

func _ready():
	#plays the animation for entering the scene for the first time#
	if $AnimationPlayer.has_animation("first_enter"):$AnimationPlayer.play("first_enter")

func remove_self():
	get_parent().get_parent().get_parent().remove_char_from_scene(0)
	queue_free()


func remove_cells(cell_array=[]):
	#removes cells from current map
	for cell in cell_array:
		get_parent().get_parent().get_node("TileMap").call_deferred('set_cellv',cell,-1)
		get_parent().get_parent().get_parent().call_deferred('update_current_texture',cell,Color(0.25,0.25,0.25))
func shake_screen(val):
	get_parent().get_parent().get_parent().get_node("Camera2D").add_trauma(val)




func trigger_animation():
	#exists to ensure that the functions in the animation get played, otherwise updates might be broken in it
	$AnimationPlayer.playback_speed=1000
	if $AnimationPlayer.has_animation("first_enter"):
		$AnimationPlayer.play("first_enter")
		$AnimationPlayer.set_deferred('current_animation_position',$AnimationPlayer.current_animation_length-0.25)
