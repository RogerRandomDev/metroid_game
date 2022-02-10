extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var direction = Vector2.ZERO
var fired_by = null
var damage = 1
func _process(delta):
	position+=direction*delta
	rotation+=delta*5*PI


func _on_bullet_body_entered(body):
	if body.is_in_group(fired_by):return
	if(body.has_method("hit")):body.hit(damage)
	if(body.get_class()=="TileMap"):
		var cell_pos = position/32
		cell_pos.x = round(cell_pos.x)
		cell_pos.y = round(cell_pos.y)
		for x in range(-1,2):for y in range(-1,2):
			
			if body.get_cellv(cell_pos+Vector2(x,y))==4:
				body.set_cellv(cell_pos+Vector2(x,y),-1)
	self.queue_free()
