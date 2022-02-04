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
var moved_dist=0
var player = null
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	if shoots:$AnimationPlayer.play("shoot")
func _process(delta):
	if $Timer.time_left!=0:return
	var travel_dist = move_speed*delta
	if(move_distance!=-1):
		moved_dist+=travel_dist
		if(moved_dist>=move_distance||is_on_wall()||(on_ledge()&&crawl_on_floor)):
			move_direction= - move_direction
			moved_dist=0
			if(max_move_delay!=0):
				$Timer.wait_time=rand_range(min_move_delay,max_move_delay)
				$Timer.start()
			$Sprite.flip_h = move_direction!=-1
# warning-ignore:return_value_discarded
	move_and_slide(Vector2(int(!vertical_motion),int(vertical_motion))*travel_dist*move_direction/delta,Vector2.UP)
func hit(val):
	health-=val
	if health<=0:
		get_parent().get_parent().get_parent().remove_char_from_scene(parent_point)
		self.queue_free()
func shoot():
	if !player.can_move:return
	var n_bul = bullets.instance()
	n_bul.fired_by="enemy"
	n_bul.position=position
	n_bul.direction = Vector2(-256,0).rotated(position.angle_to_point(player.position))
	get_parent().get_parent().get_parent().add_child(n_bul)
func on_ledge():
	return !($L.is_colliding()&&$R.is_colliding())
