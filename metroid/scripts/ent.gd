extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var parent_point = get_position_in_parent()
export(bool)var crawl_on_floor=false
export(bool)var vertical_motion=false
export(int)var move_speed=128
export(int)var move_distance=256
export(int)var move_direction=1
export(float)var min_move_delay=0.0
export(float)var max_move_delay=0.0
export(int,1,40)var health=10
export(int,0,10)var damage=1
export(bool)var shoots=false
export(PackedScene)var bullets
export(bool)var curved_motion=false
export(float)var curved_time=2.0
export(Vector2)var curve_size=Vector2(64,64)
var moved_dist=0
var player = null
const heal_item = preload("res://scenes/objects/item.tscn")
export(bool)var random_look=false


func _ready():
	randomize()
	#lets the enemy change its texture#
	if random_look:
		randomize_texture()
	#grabs who the player is to know who to shoot at
	player = get_tree().get_nodes_in_group("player")[0]
	if shoots:$AnimationPlayer.play("shoot")
func _process(delta):
	
	if $Timer.time_left!=0:return
	var travel_dist = move_speed*delta
	#curved motion lets it move in an arc
	if curved_motion:
		moved_dist+=delta*PI/curved_time
		do_curved_motion()
		return
	#if not curved motion, will follow this
	if(move_distance!=-1):
		moved_dist+=travel_dist
		##
		#if on a ledge, it will switch direction of motion
		#same if it moves passed the given max distance to travel
		##
		if(moved_dist>=move_distance||is_on_wall()||(on_ledge()&&crawl_on_floor)):
			move_direction= - move_direction
			moved_dist=0
			#sets the time to wait to a random amount between the min and max before moving again#
			if(max_move_delay!=0):
				$Timer.wait_time=rand_range(min_move_delay,max_move_delay)
				$Timer.start()
			$Sprite.flip_h = move_direction!=-1
# warning-ignore:return_value_discarded
	move_and_slide(Vector2(int(!vertical_motion),int(vertical_motion))*travel_dist*move_direction/delta,Vector2.UP)

var non_continuous=false
##
#get hurt by a value
#if you go below zero,
#you get killed and freed from the scene
##
func hit(val):
	health-=val
	if health<=0:
		if !non_continuous:get_parent().get_parent().get_parent().remove_char_from_scene(parent_point)
		#drops healing objects at random#
		if rand_range(0.0,1.0)>0.75:generate_heal_drop()
		self.queue_free()


#fires bullets at the player#
func shoot():
	#does a check if the player can move or not
	#to prevent an unfair advantage for the enemy
	if !player.can_move:return
	
	var n_bul = bullets.instance()
	n_bul.fired_by="enemy"
	n_bul.position=position
	n_bul.direction = Vector2(-256,0).rotated(position.angle_to_point(player.position))
	n_bul.damage = damage*2
	get_parent().get_parent().get_parent().add_child(n_bul)

#ledge check#
func on_ledge():return !($L.is_colliding()&&$R.is_colliding())

##
#second form of motion:curved
#
##
func do_curved_motion():
	var motion = Vector2(sin(moved_dist),cos(moved_dist))*curve_size
# warning-ignore:return_value_discarded
	move_and_slide(motion,Vector2.UP)
	rotation = motion.normalized().angle_to_point(Vector2.ZERO)+PI/2
	if moved_dist>=PI:self.queue_free()
func generate_heal_drop():
	var drop = heal_item.instance()
	drop.position = position
	get_parent().get_parent().get_node("misc").call_deferred('add_child',drop)
func randomize_texture():
	var randomized_id = int(round(rand_range(0.0,13.0))+int(shoots)*14);
	$Sprite.region_rect=Rect2(Vector2(10*int(randomized_id%2==0)+30*int(max(round(randomized_id/14-0.5),0)),10*(randomized_id%14)),Vector2(10,10))
