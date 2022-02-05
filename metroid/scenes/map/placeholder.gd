extends Node2D
func _ready():$AnimationPlayer.play("first_enter")
func remove_self():
	get_parent().get_parent().get_parent().remove_char_from_scene(0)
	queue_free()
func remove_cells(cell_array=[]):
	for cell in cell_array:
		get_parent().get_parent().get_node("TileMap").set_cellv(cell,-1)
		get_parent().get_parent().get_parent().update_current_texture(cell,Color(0.25,0.25,0.25))
func trigger_animation():
	$AnimationPlayer.playback_speed=100000
	$AnimationPlayer.play("first_enter")
