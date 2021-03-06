extends Area2D



export(String)var scene_to_enter=""
export(int)var scene_enter_point=0
export(Vector2)var scene_enter_offset=Vector2(0,-32)
export(Vector2)var scene_enter_size=Vector2(32,19)
export(Vector2)var scene_sign = Vector2.ONE
export(Vector2)var increase_scene_offset_by_value=Vector2.ZERO

#changes current zone when entered
func _on_check_event_body_entered(body):
	if body.name!="Player":return
	get_parent().get_parent().get_parent().call_deferred('load_next_scene',scene_to_enter,scene_enter_size,scene_enter_point,position,scene_enter_offset,scene_sign,increase_scene_offset_by_value)

#pretty obvious what this does#
#it gets the position it has and the amount to offset it by for the player to enter from#
func enter_position():
	return position+scene_enter_offset
