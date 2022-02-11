extends StaticBody2D


var triggered = false

export(Array,Vector2)var remove_cells_on_complete=[]
export(String)var method_on_complete=""
export(int)var position_in_parent=-1
func _ready():
	if position_in_parent==-1:
		position_in_parent=get_position_in_parent()
func get_hit():
	Global.load_audio("puzzle_target")
	triggered = true
	var groups = get_groups()
	for group in groups:
		if group=="puzzle_shot":continue
		var do_trigger = true
		var removed_cells=remove_cells_on_complete
		var items = []
		for item in get_tree().get_nodes_in_group(group):
			if !item.triggered:
				do_trigger=false
				break
			else:
				removed_cells.append_array(item.remove_cells_on_complete)
				items.append(item)
		if do_trigger:
			var map = get_parent().get_parent().get_node("TileMap")
			for cell in removed_cells:
				map.set_cellv(cell,-1)
			if method_on_complete!="":
				get_parent().get_parent().call(method_on_complete)
			items.append(self)
			for item in items:
				item.get_parent().get_parent().get_parent().remove_char_from_scene(item.position_in_parent)
				item.queue_free()
	$CollisionShape2D.set_deferred('disabled',true)
	if groups.size()==1&&triggered:
		open_path()
		get_parent().get_parent().get_parent().remove_char_from_scene(position_in_parent)
func open_path():
	var map = get_parent().get_parent().get_node("TileMap")
	for cell in remove_cells_on_complete:
		map.set_cellv(cell,-1)
	if method_on_complete!="":
		get_parent().get_parent().call(method_on_complete)
	queue_free()
