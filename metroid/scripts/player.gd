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
var health = 100
var rot_rate = 0.0
var stats_on_scene_enter=[10,Vector2(0,0)]
export var can_hurt=true
export var can_input=true
var cur_animation = "default"
func _ready():
	can_input=true
	store_stats()
func _process(delta):
	if !can_move:return
	check_cell(get_parent().get_cell_at_position(position))
	#makes you wobble back and forth when walking if not spinning in air
	if !spin:
		rot_rate+=min(velocity.length()*delta/8,delta*8)*int(abs(velocity.length_squared())>64)
		$Psprite.rotation = sin(rot_rate)/4
	else:
	#makes you spin when in air
		$Psprite.rotation += delta*PI*2*sign(velocity.x)
	
	velocity += direction*delta*move_speed
	velocity.y+=gravity*delta
	
	if is_on_floor()&&velocity.y > -1&&can_input:
		velocity.y = 0
		velocity.x -= velocity.x*delta*10*int(direction.x==0||sign(direction.x)!=sign(velocity.x))
		double_jumped = false
		change_animation("default")
	
	#if you hit a wall, it stops you from keeping inertia in that direction
	if(is_on_wall()&&((velocity.x>0&&$R.is_colliding())||(velocity.x<0&&$L.is_colliding()))):
		velocity.x=0
	
	#flips your facing direction if you are going above a very low speed#
	if(abs(velocity.x)>8):flip_sprite(velocity.x<0)
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector2.UP)

#inputs
func _input(_event):
	#resets current velocity
	direction=Vector2.ZERO
	if !can_input:return
	
	direction.x = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
	if Input.is_action_just_pressed("jump")&&(is_on_floor()||!double_jumped||(($L.is_colliding()||$R.is_colliding()))&&!is_on_ceiling()):
		velocity.y = -jump_force
		velocity.x += direction.x*move_speed*2
		
		if(!is_on_floor()):
			#checks if on wall to enable wall jumps
			if((($L.is_colliding()||$R.is_colliding())&&!is_on_ceiling())):
				velocity.x = (int($L.is_colliding())-int($R.is_colliding()))*move_speed
			else:
				#if not on wall, set it to a double jump
				double_jumped=true
		change_animation("jump")
	
	if Input.is_action_pressed("shoot"):
		if !$PAnim.is_playing()||$PAnim.current_animation_position>=$PAnim.current_animation_length:
			$PAnim.play("shoot")
	#disables animation player if it is not meant to be active
	else:if !Input.is_action_pressed("shoot")&&$PAnim.current_animation=="shoot":
		$PAnim.stop(false)

#fire bullet
func shoot():
	var n_bul = bullet.instance()
	n_bul.position = position
	n_bul.fired_by = "player"
	n_bul.direction = get_local_mouse_position().normalized()*256
	get_parent().add_child(n_bul)

#face the move direction
func flip_sprite(val):$Psprite.flip_h=!val
func change_animation(val):
	cur_animation = val
	#makes you spin in the air
	if val=="jump":spin=true
	else:spin=false

#hurts the current entity, AKA the player#
func hit(val):
	if !can_hurt:return
	health = max(health-val,0)
	$invul_anim.play("temp_invul")
	get_parent().get_node("Camera2D").add_trauma(val/20+0.125)
	if health <= 0:
		get_parent().get_node("scene_Anims").play("player_dead")
		get_parent().reload_scene()
	get_parent().update_player_health(health)
##
#melee range for player, faster to do it on only player than on enemies as well,
#so the player does the check for most interactions with themselves
##
func _on_melee_hurt_body_entered(body):
	#reaches melee range of an enemy
	if body.is_in_group("enemy"):
		var enemy_damage = body.damage
		var bounce_angle = position.angle_to_point(body.position)
		velocity=velocity*0.125
		velocity+=Vector2(cos(bounce_angle),sin(bounce_angle)-1)*128
		hit(enemy_damage)
		$PAnim.play("hurt")
	#pick-up a healing item
	if body.is_in_group("heal_item"):
		body.queue_free()
		health=min(health+5,100)
		get_parent().update_player_health(health)

#finish animation in-case it decides to not work on its own#
func _on_PAnim_animation_finished(_anim_name):
	$PAnim.stop()
	
#checks the tile you are in to see what it is#
func check_cell(cell_id):
	#bounces if you are in lava#
	if cell_id==3:
		velocity.y= -256
		hit(1)

#stores stats for player when they die#
func store_stats():
	stats_on_scene_enter=[health,position,get_parent().points]

#updates stats when you die to respawn as you were when entering the level for the first time
func load_stats():
	health = stats_on_scene_enter[0]
	position = stats_on_scene_enter[1]
	get_parent().points = stats_on_scene_enter[2]
	get_parent().update_player_health(health)
