extends KinematicBody2D


export(PackedScene)var Bullet_scene
export(PackedScene)var Enemy_Scene
export(bool)var can_hurt=false
export(Vector2)var target_position=Vector2.ZERO
export(int)var health=5
export(Array,String)var previous_action_set=["none","none"]
export(Array,String)var action_set=["Move_To_Position","Summon_Enemies","Fire_Bullets"]
export(Array,Vector2)var move_positions = []
export(int)var max_bullets=8

var invul_next=5
var summons_count = 4
var cur_hover_rate = 0.0
var max_enemies = 5
var emitting_flames=false
var player=null
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	randomize()
	$AnimationPlayer.play("action_chooser")
	for child in $Protecting_orbs.get_children():
		child.position = Vector2(sin(child.get_position_in_parent()*PI*2/5),cos(child.get_position_in_parent()*PI*2/5))*48

#loads action the boss will choose
func load_next_action():
	invul_next-=1
	if invul_next!=5:
		$Protecting_orbs.get_child(invul_next).visible = false
	if invul_next<=0:
		$AnimationPlayer.play("vulnerable_time")
		can_hurt=true
		invul_next=5
		$AnimationPlayer.playback_speed = 0.5
		return
	emitting_flames=false
	$AnimationPlayer.playback_speed=1.0
	var chosen_action = "none"
	while chosen_action=="none"||previous_action_set.has(chosen_action):
		chosen_action=action_set[round(rand_range(0.0,action_set.size()-1))]
	previous_action_set.append(chosen_action)
	previous_action_set.remove(0)
	call(chosen_action)
	can_hurt=true
	for child in $Protecting_orbs.get_children():
		if child.visible:can_hurt=false
	

func Move_To_Position():
	var tiles=get_parent().get_parent().get_node("TileMap")
	var done=false
	while tiles.get_cellv(tiles.world_to_map(target_position))!=-1||!done:
		target_position = random_position()
		done=true
	var travel_time = position.distance_to(target_position)/512
	$Tween.interpolate_property(self,"position",position,target_position,travel_time,Tween.TRANS_CUBIC)
	$Tween.start()
	$AnimationPlayer.playback_speed=1/max(travel_time,0.05)
func Summon_Enemies():
	if get_parent().get_child_count()<max_enemies:
		$AnimationPlayer.play("summon_enemies")
		$AnimationPlayer.playback_speed = 0.25
func create_enemy():
	var enemy = Enemy_Scene.instance()
	enemy.position = random_enemy_position()
	var tween = Tween.new()
	add_child(tween)
	enemy.shoots = rand_range(0.0,5.0)>4.5
	get_parent().add_child(enemy)
	enemy.walk_at_player=true
	enemy.non_continuous=true
	enemy.set_process(false)
	enemy.set_physics_process(false)
	tween.interpolate_property(enemy,"position",enemy.position+Vector2(0,64),enemy.position,0.5,Tween.TRANS_CUBIC)
	tween.start()
	tween.connect("tween_all_completed",self,"enable_enemy",[tween,enemy])
func enable_enemy(tween,enemy):
	tween.disconnect("tween_all_completed",self,"enable_enemy")
	tween.queue_free()
	enemy.set_process(true)
	enemy.set_physics_process(true)
func Fire_Bullets():
	$AnimationPlayer.play("shoot_bullets")
func create_bullet(id):
	var tiles = get_parent().get_parent().get_node("TileMap")
	if tiles.get_cellv(tiles.world_to_map((position+Vector2(sin(id*PI*2/max_bullets),cos(id*PI*2/max_bullets))*32+Vector2(16,16))/2))!=-1:return
	var n_bul = Bullet_scene.instance()
	n_bul.position = position+Vector2(sin(id*PI*2/max_bullets),cos(id*PI*2/max_bullets))*32
	n_bul.fired_by="boss"
	n_bul.damage = 10
	get_parent().get_parent().get_node("misc").add_child(n_bul)
	n_bul.set_process(false)
	n_bul.scale=Vector2.ZERO
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(n_bul,"scale",Vector2.ZERO,Vector2.ONE,0.5,Tween.TRANS_CUBIC)
	tween.start()
	tween.connect("tween_all_completed",self,"fire_off_bullet",[tween,n_bul])
	
func fire_off_bullet(tween,bullet):
	bullet.set_process(true)
	tween.disconnect("tween_all_completed",self,"fire_off_bullet")
	tween.queue_free()
	bullet.direction = Vector2(-512,0).rotated(bullet.position.angle_to_point(player.position))

func random_position():
	return move_positions[round(rand_range(0.0,move_positions.size()-1))]
func random_enemy_position():
	return Vector2(round(rand_range(1.0,28.0))*32,560)

func hit(val):
	if can_hurt:
		health -= 1
		can_hurt=false
		for child in $Protecting_orbs.get_children():
			child.visible=true
		$AnimationPlayer.play("action_chooser")
		get_parent().get_parent().get_parent().get_node("Camera2D").add_trauma(0.5)
		Global.load_audio("screen_shake")
		$Sprite.modulate = Color.white
		if health <=0:
			position = Vector2(512,127)
			$AnimationPlayer.stop()
			get_parent().get_parent().get_node("misc/Label/AnimationPlayer").play("boss_death")
			for child in get_parent().get_children():
				if child!=self:child.queue_free()

func _process(delta):
	if health<=0:return
	$Protecting_orbs.rotation+=delta*PI
	if !$AnimationPlayer.is_playing():$AnimationPlayer.play("action_chooser")
func reset_invulnerability():
	for child in $Protecting_orbs.get_children():
		child.visible=true
func choose_actions():
	$AnimationPlayer.play("action_chooser")
	$AnimationPlayer.playback_speed=1.0
func delay_animation():
	$AnimationPlayer.play("action_chooser")
	$AnimationPlayer.playback_speed=rand_range(0.5,1.0)
