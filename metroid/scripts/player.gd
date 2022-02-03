extends KinematicBody2D




export var bullet:PackedScene
var gravity = 512
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var jump_force = 256
var can_move = true
var double_jumped = false


func _process(delta):
	if !can_move:return
	velocity += direction*delta*256
	velocity.y+=gravity*delta
	if is_on_floor():
		velocity.x -= velocity.x*delta
		double_jumped = false
	if(is_on_wall()&&((velocity.x>0&&$R.is_colliding())||(velocity.x<0&&$L.is_colliding()))):
		velocity.x=0
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.UP)
func _input(_event):
	direction=Vector2.ZERO
	direction.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
	if Input.is_action_just_pressed("jump")&&(is_on_floor()||!double_jumped||($L.is_colliding()||$R.is_colliding())):
		velocity.y = -jump_force
		velocity.x += direction.x*64
		if(!is_on_floor()):
			if(is_on_wall()):velocity.x = (int($L.is_colliding())-int($R.is_colliding()))*256
			else:double_jumped=true
func shoot():
	var n_bul = bullet.instance()
	get_parent().add_child(n_bul)
