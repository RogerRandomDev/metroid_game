extends Node2D


var stored_scenes = {}
var current_point_offset = Vector2(0,0)
var already_on_map = []
var my_size = Vector2(32,19)
var prev_scene = null
var prev_scene_size = Vector2(32,19)
var points = 0
func _ready():
	load_next_scene("map_0",my_size,0,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO)
	$Player.position = Vector2(932,512)
	$Camera2D.active= true
	$Player.can_move=true
	Global.play_music("base_song")
var last_scene = null
var cur_Scene_name=""
var prev_scene_offset=Vector2.ZERO


# warning-ignore:unused_argument
func load_next_scene(scene_name,view_size,player_enter_point,my_position,_my_offset,sign_of_scene,increase_offset_by):
	#used this to fix the scene camera going everywhere on the minimap
	#was a total pain to fix but i did it
	var returned_to_prior = false
	#used to check if it can even enter a new room yet
	if get_node_or_null("a")!=null:return
	
	#kills all bullets in the room when you leave
	for bul in get_tree().get_nodes_in_group("bullet"):bul.queue_free()
	
	
	last_scene = get_node_or_null("cur_scene")
	
	if(get_node_or_null('last_scene')!=null):get_node_or_null("last_scene").queue_free()
	#updates the name of the previous scene
	if(last_scene!=null):
		last_scene.name = "last_scene"
		last_scene.add_to_group("last_scene")
	
	#begin creating the new room
	var new_scene = load("res://scenes/map/"+scene_name+".tscn").instance()
	new_scene.name = "cur_scene"
	cur_Scene_name=scene_name
	
	#player position is changed by these and also gets the room tile size distance from the first room
	var p_pos = $Player.position
	var entered_from = new_scene.get_node("enter_points").get_child(player_enter_point)
	if increase_offset_by!=Vector2.ZERO:
		current_point_offset=increase_offset_by
	var enter_pos = entered_from.scene_enter_offset
	
	#used to generate the map sprites for the minimap view
	if(!already_on_map.has(scene_name)):
		already_on_map.append(scene_name)
		var n_sprite = generate_map(new_scene,view_size,sign_of_scene)
		if increase_offset_by!=Vector2.ZERO:
			n_sprite.position = increase_offset_by
	##
	#this prevents the minimap from moving excessively when entering a large room then a small one
	#i know why it did that but i would have to rewrite most of this to fix it,
	#so this will have to do for now
	##
	if current_point_offset+my_size*sign_of_scene==prev_scene_offset:
		current_point_offset+=my_size*sign_of_scene
		returned_to_prior=true
	else:
		prev_scene_offset=current_point_offset
		current_point_offset+=view_size*sign_of_scene
		my_size=view_size

	#updates map position so it centers on the current room
	$CanvasLayer/map_points/Viewport/Node2D.position= -current_point_offset*2+Vector2(128,75)-view_size
	if increase_offset_by!=Vector2.ZERO:
		$CanvasLayer/map_points/Viewport/Node2D.position = -increase_offset_by*2-view_size+Vector2(128,75)
	#makes it so if the enter offset for the room is zero on an axis,
	#it will use the current position on that axis
	if(enter_pos.x==0):enter_pos.x=p_pos.x;else:enter_pos.x=entered_from.enter_position().x
	if(enter_pos.y==0):enter_pos.y=p_pos.y;else:enter_pos.y=entered_from.enter_position().y
	
	if(!stored_scenes.has(scene_name)):
		var store_data = {}
		var en_dat = []
		
		for enemy in new_scene.get_node("Entities").get_children():
			en_dat.append(true)
		#adds enemies to the enemy list as true so they will respawn when you re-enter if not killed
		store_data["Ent"]=en_dat
		stored_scenes[scene_name]=store_data
		#creates a duplicate of the current scene data so if you die in the room, the enemies killed
		#in the time in that room will be respawned
		cur_Scene_data=store_data.duplicate(true)
	else:
		#removes entities if they are labelled as false by the enemy list
		var dat = stored_scenes[scene_name]
		
		for ent in new_scene.get_node("Entities").get_child_count():
			if !dat["Ent"][ent]:
				
				var n_ent = new_scene.get_node("Entities").get_child(ent)
				
				if n_ent.has_method("trigger_animation"):
					n_ent.trigger_animation()
				elif n_ent.has_method("open_path"):
					n_ent.open_path()
				else:
					n_ent.queue_free()
				
	
	#moves player to enter position and creates the new scene
	$Player.position=enter_pos
	call_deferred('add_child',new_scene)
	#updates camera range and stops it from updating itself
	$Camera2D.camera_limits=(view_size-Vector2(32,19))*32
	$Camera2D.active=false
	last_scene=get_node_or_null("last_scene")
	if increase_offset_by!=Vector2.ZERO:
		current_point_offset=increase_offset_by
	##
	#moves last scene to the side it should be on
	#to make sure that the camera transition is smooth
	#and they look like one complete map
	##
	if(last_scene!=null):
		var n_size=view_size
		last_scene.position = -n_size*32*sign_of_scene
		if returned_to_prior:
			last_scene.position = -prev_scene_size*32*sign_of_scene
		else:
			prev_scene_size = view_size
		
		#god-damn clunky but it works
		#updates the target position for the camera
		$Camera2D.position+=last_scene.position
		var t_pos = $Camera2D.position
		$Camera2D.position = $Player.position
		$Camera2D.update_pos()
		var n_pos = $Camera2D.position+Vector2(512,308)
		
		
		$Tween.interpolate_property($Camera2D,"position",t_pos,n_pos,0.75,Tween.TRANS_CUBIC)
		last_scene.name = "a"
		$Player.can_move=false
		$Tween.start()
	prev_scene=new_scene
	#store player stats when entering the scene
	$Player.store_stats()
	

func _on_Tween_tween_all_completed():
	#lets you move when the scene has been transitioned
	$Player.can_move=true
	$Camera2D.active=true
	for node in get_tree().get_nodes_in_group("last_scene"):
		node.queue_free()
		pass

#removes an object when killed from entities
#prevents respawning enemies when entering a room a second time
func remove_char_from_scene(id):
	stored_scenes[cur_Scene_name]["Ent"][id]=false

##
#map generation was nice
#more relaxing than getting
#room-changing to work thats for sure
##
var img_size = Vector2(0,0)
var current_texture=[null,null]
func generate_map(scene_from,cur_Scene_size,_scene_sign):
	#setup for the new image here#
	var img = Image.new()
	var tex = ImageTexture.new()
	img.create(cur_Scene_size.x,cur_Scene_size.y,false,Image.FORMAT_RGB8)
	img.fill(Color(0.25,0.25,0.25))
	img.lock()
	
	#this gets the map, and if the tile is within the map size, sets the pixel at that point to solid#
	for point in scene_from.get_node("TileMap").get_used_cells():
		if(cur_Scene_size.x<=point.x||point.x<0||point.y<0||point.y>=cur_Scene_size.y):continue
		img.set_pixelv(point,Color(1,1,1))
	
	
	tex.create_from_image(img,4)
	#applies the new image to a texture and creates a sprite to hold the texture
	var map_sprite = Sprite.new()
	map_sprite.texture = tex
	$CanvasLayer/map_points/Viewport/Node2D.add_child(map_sprite)
	
	map_sprite.position = current_point_offset+cur_Scene_size*_scene_sign
	map_sprite.centered = false
	current_texture = [map_sprite,img]
	return map_sprite
var cur_Scene_data = {}

#allows you to change the pixel in a texture to a specific color in the minimap
func update_current_texture(cell,color):
	if current_texture[0]==null:return
	var text = ImageTexture.new()
	current_texture[1].set_pixelv(cell,color)
	text.create_from_image(current_texture[1],4)
	current_texture[0].texture = text

#if i have to descrive what this does, you shouldn't be looking at the code#
func get_cell_at_position(pos):
	var out = pos/32
	out.x=round(out.x-0.5)
	out.y=round(out.y-0.5)
	
	var current = get_node_or_null("cur_scene/TileMap")
	if current!=null:return current.get_cellv(out)
	return -1


##
#resets the current scene when you die
#basically, its a mini-version of entering a new room
#since it gets most of the code from that
#slightly different since you dont need to load a new room as well
##
func reload_scene():
	var current = get_node_or_null("cur_scene")
	if current!=null:
		current.name="a"
		current.queue_free()
	var new_scene = load("res://scenes/map/"+cur_Scene_name+".tscn").instance()
	new_scene.name = "cur_scene"
	
# warning-ignore:unused_variable
	var scene_name = cur_Scene_name
	var dat = cur_Scene_data
	
	for ent in new_scene.get_node("Entities").get_child_count():
		if !dat["Ent"][ent]:
			var n_ent = new_scene.get_node("Entities").get_child(ent)
			
			if n_ent.has_method("trigger_animation"):
				n_ent.trigger_animation()
			else:
				n_ent.queue_free()
	
	call_deferred('add_child',new_scene)

##
#this should't even need an explanation
#but i'll give you one anyways:
#changes the text of the player health
#to the given value
##
func update_player_health(val):
	$CanvasLayer/stat_panel/HP_label.text = str(val)


#perfection mode returns to start
func set_scene_to_start():
	stored_scenes = {}
	load_next_scene("map_0",Vector2(32,19),1,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO)
	current_point_offset=Vector2.ZERO
	for map_sprite in $CanvasLayer/map_points/Viewport/Node2D.get_children():
		map_sprite.queue_free()
	already_on_map=[]
	$Player.set_deferred('position',Vector2(932,512))
	$Player.health=1
	$Player.store_stats()
