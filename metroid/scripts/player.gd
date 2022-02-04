extends KinematicBody2D




export var bullet:PackedScene
var gravity = 512
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var jump_force = 320
var can_move = true
var double_jumped = false
var spin = false

func _process(delta):
	if !can_move:return
	if spin:
		$Psprite_top.rotation += delta*PI*2*sign(velocity.x)

	velocity += direction*delta*256
	velocity.y+=gravity*delta
	if is_on_floor()&&velocity.y > 0:
		velocity.y -= velocity.y*delta*5
		velocity.x -= velocity.x*delta*10*int(direction.x==0||sign(direction.x)!=sign(velocity.x))
		double_jumped = false
		change_animation("default")
	if(is_on_wall()&&((velocity.x>0&&$R.is_colliding())||(velocity.x<0&&$L.is_colliding()))):
		velocity.x=0
		
	if(abs(velocity.x)>8):
		flip_sprite(velocity.x<0)
	toggle_sprite(abs(velocity.x)>8)
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.UP)
func _input(_event):
	direction=Vector2.ZERO
	direction.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
	if Input.is_action_just_pressed("jump")&&(is_on_floor()||!double_jumped||($L.is_colliding()||$R.is_colliding())):
		velocity.y = -jump_force
		velocity.x += direction.x*128
		if(!is_on_floor()):
			if(($L.is_colliding()||$R.is_colliding())):velocity.x = (int($L.is_colliding())-int($R.is_colliding()))*256
			else:double_jumped=true
		change_animation("jump")
	if Input.is_mouse_button_pressed(1):
		if !$PAnim.is_playing():
			$PAnim.play("shoot")
	elif !Input.is_mouse_button_pressed(1):
		$PAnim.stop()
func shoot():
	var n_bul = bullet.instance()
	n_bul.position = position
	n_bul.fired_by = self
	n_bul.direction = get_local_mouse_position().normalized()*256
	get_parent().add_child(n_bul)

func flip_sprite(val):
	$Psprite_bottom.flip_h=val
	$Psprite_top.flip_h=val
func toggle_sprite(val):
	$Psprite_bottom.playing=val
	$Psprite_top.playing = val
func change_animation(val):
	if $Psprite_bottom.animation!=val:
		$Psprite_bottom.play(val)
		$Psprite_top.play(val)
	if $Psprite_bottom.animation=="jump":
		$Psprite_top.offset.y = 4
		spin=true
	else:
		spin=false
		$Psprite_top.rotation=0
		$Psprite_top.offset.y = 0
