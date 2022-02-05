extends KinematicBody2D




export var bullet:PackedScene
var gravity = 512
var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var jump_force = 320
export(int)var move_speed=128
export var can_move = true
var double_jumped = false
var spin = false
var health = 10
export var can_input=true
func _process(delta):
	if !can_move:return
	if spin:
		$Psprite.rotation += delta*PI*2*sign(velocity.x)
	
	velocity += direction*delta*move_speed
	velocity.y+=gravity*delta
	if is_on_floor()&&velocity.y > 0&&can_input:
		velocity.y -= velocity.y*delta*5
		velocity.x -= velocity.x*delta*10*int(direction.x==0||sign(direction.x)!=sign(velocity.x))
		double_jumped = false
		change_animation("default")
	if(is_on_wall()&&((velocity.x>0&&$R.is_colliding())||(velocity.x<0&&$L.is_colliding()))):
		velocity.x=0
		
	if(abs(velocity.x)>8):
		flip_sprite(velocity.x<0)
	toggle_sprite(abs(velocity.x)>8||$Psprite.animation=="jump")
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.UP)
func _input(_event):
	direction=Vector2.ZERO
	if !can_input:return
	direction.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
	if Input.is_action_just_pressed("jump")&&(is_on_floor()||!double_jumped||(($L.is_colliding()||$R.is_colliding()))&&!is_on_ceiling()):
		velocity.y = -jump_force
		velocity.x += direction.x*move_speed/2
		if(!is_on_floor()):
			if((($L.is_colliding()||$R.is_colliding())&&!is_on_ceiling())):velocity.x = (int($L.is_colliding())-int($R.is_colliding()))*move_speed
			else:double_jumped=true
		change_animation("jump")
	if Input.is_action_pressed("shoot"):
		if !$PAnim.is_playing():
			$PAnim.play("shoot")
	elif !Input.is_action_pressed("shoot")&&$PAnim.current_animation=="shoot":
		$PAnim.stop(false)
func shoot():
	var n_bul = bullet.instance()
	n_bul.position = position
	n_bul.fired_by = "player"
	n_bul.direction = get_local_mouse_position().normalized()*256
	get_parent().add_child(n_bul)

func flip_sprite(val):$Psprite.flip_h=val
func toggle_sprite(val):$Psprite.playing=val
func change_animation(val):
	if $Psprite.animation!=val:
		$Psprite.play(val)
	if $Psprite.animation=="jump":
		$Psprite.offset.y = 4
		$CollisionShape2D.shape.extents=Vector2(12,12)
		$CollisionShape2D.position.y=0
		spin=true
	else:
		spin=false
		$Psprite.rotation=0
		$CollisionShape2D.shape.extents=Vector2(15,22)
		$CollisionShape2D.position.y=2
	$Psprite.set_deferred("playing",true)

func hit(val):
	health-=val

func _on_melee_hurt_body_entered(body):
	if body.is_in_group("enemy"):
		var enemy_damage = body.damage
		var bounce_angle = position.angle_to_point(body.position)
		velocity=velocity*0.125
		velocity+=Vector2(cos(bounce_angle),sin(bounce_angle)-1)*128
		hit(enemy_damage)
		$PAnim.play("hurt")
