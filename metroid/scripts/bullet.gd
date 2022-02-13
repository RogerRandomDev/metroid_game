extends Area2D


var direction = Vector2.ZERO
var fired_by = null
var damage = 1
#plays firing sound on load
func _ready():
	update()
	if !get_overlapping_bodies().size()!=0:
		Global.load_audio("shoot")
#moves by direction value
#and rotates by a set value
func _process(delta):
	position+=direction*delta
	rotation+=delta*5*PI


##
#this is the bulk of the bullet logic
#checks if it is inside the one who fired it or not first
#and then it will check if the target has a hit method
#finally, it checks if it hit the map
#and if so will remove the surrounding breakable tiles
##
func _on_bullet_body_entered(body):
	
	if body.is_in_group(fired_by):return
	if(body.has_method("hit")):body.hit(damage)
	if fired_by!="player":
		self.queue_free();return
	if(body.get_class()=="TileMap"):
		var cell_pos = position/32
		cell_pos.x = round(cell_pos.x)
		cell_pos.y = round(cell_pos.y)
		for x in range(-1,2):for y in range(-1,2):
			
			if body.get_cellv(cell_pos+Vector2(x,y))==4:
				body.set_cellv(cell_pos+Vector2(x,y),-1)
	if(body.is_in_group("puzzle_shot")):body.get_hit()
	self.queue_free()
