extends Node2D
func _ready():
	if $AnimationPlayer.has_animation("first_enter"):$AnimationPlayer.play("first_enter")
func remove_self():
	get_parent().get_parent().get_parent().remove_char_from_scene(0)
	queue_free()
func remove_cells(cell_array=[]):
	for cell in cell_array:
		get_parent().get_parent().get_node("TileMap").set_cellv(cell,-1)
		get_parent().get_parent().get_parent().update_current_texture(cell,Color(0.25,0.25,0.25))
func trigger_animation():
	$AnimationPlayer.playback_speed=1000
	if $AnimationPlayer.has_animation("first_enter"):
		$AnimationPlayer.play("first_enter")
		$AnimationPlayer.set_deferred('current_animation_position',$AnimationPlayer.current_animation_length-0.25)
