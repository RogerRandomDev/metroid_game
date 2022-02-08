extends Node2D


var stored_scenes = {}
var current_point_offset = Vector2(0,0)
var already_on_map = []
var my_size = Vector2(32,19)
var prev_scene = null
var prev_scene_size = Vector2(32,19)
func _ready():
	cur_Scene_name="map_0"
	var scene_name = cur_Scene_name
	var new_scene = $cur_scene
	if(!stored_scenes.has(scene_name)):
		var store_data = {}
		var en_dat = []
		for enemy in new_scene.get_node("Entities").get_children():
			en_dat.append(true)
		store_data["Ent"]=en_dat
		stored_scenes[scene_name]=store_data
	else:
		var dat = stored_scenes[scene_name]
		for ent in new_scene.get_node("Entities").get_child_count():
			if !dat["Ent"][ent]:new_scene.get_node("Entities").get_child(ent).queue_free()
	if(!already_on_map.has(scene_name)):
		already_on_map.append(scene_name)
		generate_map($cur_scene,Vector2(32,19),Vector2.ZERO)
	prev_scene = new_scene
var last_scene = null
var cur_Scene_name=""
var prev_scene_offset=Vector2.ZERO
# warning-ignore:unused_argument
func load_next_scene(scene_name,view_size,player_enter_point,my_position,_my_offset,sign_of_scene):
	var returned_to_prior = false
	if get_node_or_null("a")!=null:return
	for bul in get_tree().get_nodes_in_group("bullet"):bul.queue_free()
	last_scene = get_node_or_null("cur_scene")
	if(get_node_or_null('last_scene')!=null):get_node_or_null("last_scene").queue_free()
	if(last_scene!=null):
		last_scene.name = "last_scene"
		last_scene.add_to_group("last_scene")
	var new_scene = load("res://scenes/map/"+scene_name+".tscn").instance()
	new_scene.name = "cur_scene"
	cur_Scene_name=scene_name
	var p_pos = $Player.position
	var entered_from = new_scene.get_node("enter_points").get_child(player_enter_point)
	var enter_pos = entered_from.scene_enter_offset
	if(!already_on_map.has(scene_name)):
		already_on_map.append(scene_name)
		generate_map(new_scene,view_size,sign_of_scene)
	if current_point_offset+my_size*sign_of_scene==prev_scene_offset:
		current_point_offset+=my_size*sign_of_scene
		returned_to_prior=true
	else:
		prev_scene_offset=current_point_offset
		current_point_offset+=view_size*sign_of_scene
		my_size=view_size
	$Camera2D/map_points/Viewport/Node2D.position= -current_point_offset*2+Vector2(128,75)-view_size
	if(enter_pos.x==0):enter_pos.x=p_pos.x;else:enter_pos.x=entered_from.enter_position().x
	if(enter_pos.y==0):enter_pos.y=p_pos.y;else:enter_pos.y=entered_from.enter_position().y
	if(!stored_scenes.has(scene_name)):
		var store_data = {}
		var en_dat = []
		for enemy in new_scene.get_node("Entities").get_children():
			en_dat.append(true)
		store_data["Ent"]=en_dat
		stored_scenes[scene_name]=store_data
	else:
		var dat = stored_scenes[scene_name]
		for ent in new_scene.get_node("Entities").get_child_count():
			if !dat["Ent"][ent]:
				var n_ent = new_scene.get_node("Entities").get_child(ent)
				if n_ent.has_method("trigger_animation"):
					n_ent.trigger_animation()
				else:
					n_ent.queue_free()
	$Player.position=enter_pos
	add_child(new_scene)
	$Camera2D.camera_limits=(view_size-Vector2(32,19))*32
	$Camera2D.active=false
	last_scene=get_node_or_null("last_scene")
	if(last_scene!=null):
		var n_size=view_size
		last_scene.position = -n_size*32*sign_of_scene
		if returned_to_prior:
			last_scene.position = -prev_scene_size*32*sign_of_scene
		else:
			prev_scene_size = view_size
		$Camera2D.position+=last_scene.position
		var t_pos = $Camera2D.position
		$Camera2D.position = $Player.position
		$Camera2D.update_pos()
		var n_pos = $Camera2D.position
		$Tween.interpolate_property($Camera2D,"position",t_pos,n_pos,0.75,Tween.TRANS_CUBIC)
		last_scene.name = "a"
		$Player.can_move=false
		$Tween.start()
	prev_scene=new_scene
	

func _on_Tween_tween_all_completed():
	$Player.can_move=true
	$Camera2D.active=true
	for node in get_tree().get_nodes_in_group("last_scene"):
		node.queue_free()
		pass

func remove_char_from_scene(id):
	stored_scenes[cur_Scene_name]["Ent"][id]=false
var img_size = Vector2(0,0)
var current_texture=[null,null]
func generate_map(scene_from,cur_Scene_size,_scene_sign):
	var img = Image.new()
	var tex = ImageTexture.new()
	img.create(cur_Scene_size.x,cur_Scene_size.y,false,Image.FORMAT_RGB8)
	img.fill(Color(0.25,0.25,0.25))
	img.lock()
	for point in scene_from.get_node("TileMap").get_used_cells():
		if(cur_Scene_size.x<=point.x||point.x<0||point.y<0||point.y>=cur_Scene_size.y):continue
		img.set_pixelv(point,Color(1,1,1))
	tex.create_from_image(img,4)
	var map_sprite = Sprite.new()
	map_sprite.texture = tex
	$Camera2D/map_points/Viewport/Node2D.add_child(map_sprite)
	map_sprite.position = current_point_offset+cur_Scene_size*_scene_sign
	map_sprite.centered = false
	current_texture = [map_sprite,img]
func update_current_texture(cell,color):
	if current_texture[0]==null:return
	var text = ImageTexture.new()
	current_texture[1].set_pixelv(cell,color)
	text.create_from_image(current_texture[1],4)
	current_texture[0].texture = text
func get_cell_at_position(pos):
	var out = pos/32
	out.x=round(out.x-0.5)
	out.y=round(out.y-0.5)
	var current = get_node_or_null("cur_scene/TileMap")
	if current!=null:
		return current.get_cellv(out)
