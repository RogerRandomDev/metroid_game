extends Node2D



func _ready():pass

var last_scene = null
func load_next_scene(scene_name,view_size,player_enter_point):
	if get_node_or_null("a")!=null:return
	last_scene = get_node_or_null("cur_scene")
	if(get_node_or_null('last_scene')!=null):get_node_or_null("last_scene").queue_free()
	if(last_scene!=null):
		last_scene.name = "last_scene"
		last_scene.add_to_group("last_scene")
	var new_scene = load("res://scenes/map/"+scene_name+".tscn").instance()
	new_scene.name = "cur_scene"
	var p_pos = $Player.position
	var entered_from = new_scene.get_node("enter_points").get_child(player_enter_point)
	var enter_pos = entered_from.scene_enter_offset
	if(enter_pos.x==0):enter_pos.x=p_pos.x;else:enter_pos.x=entered_from.enter_position().x
	if(enter_pos.y==0):enter_pos.y=p_pos.y;else:enter_pos.y=entered_from.enter_position().y
	
	$Player.position=enter_pos
	add_child(new_scene)
	$Camera2D.zoom = view_size/Vector2(32,19)
	last_scene=get_node_or_null("last_scene")
	if(last_scene!=null):
		last_scene.position = $Camera2D.zoom*Vector2(32,19)*Vector2(-sign(entered_from.scene_enter_offset.x),sign(entered_from.scene_enter_offset.y+1))*32-Vector2(0,608)
		$Camera2D.position=last_scene.position
		$Tween.interpolate_property($Camera2D,"position",last_scene.position,new_scene.position,0.75,Tween.TRANS_CUBIC)
		last_scene.name = "a"
		$Player.can_move=false
		$Tween.start()


func _on_Tween_tween_all_completed():
	$Player.can_move=true
	for node in get_tree().get_nodes_in_group("last_scene"):
		node.queue_free()
		pass
