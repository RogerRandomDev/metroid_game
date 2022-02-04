extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var direction = Vector2.ZERO
var fired_by = null

func _process(delta):
	position+=direction*delta
	rotation+=delta*5*PI


func _on_bullet_body_entered(body):
	if fired_by==body:return
	if(body.has_method("hit")):body.hit()
	self.queue_free()
