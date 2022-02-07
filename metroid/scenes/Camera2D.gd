extends Camera2D
var camera_limits = Vector2.ZERO
var active = false
func _process(_delta):
	if !active:return
	position = get_parent().get_node("Player").position-Vector2(512,300)
	position.x = clamp(position.x,0,camera_limits.x)
	position.y = clamp(position.y,0,camera_limits.y)
