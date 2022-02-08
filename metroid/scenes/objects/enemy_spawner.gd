extends Sprite


export(float,0.25,5.0)var max_delay=2.5
export(float,0.25,5.0)var min_delay=0.5
export(int,0,3)var enemy_type=0
export(Vector2)var enemy_curve=Vector2(256,-64)
export(Vector2)var enemy_variance=Vector2(32,16)
const enemy_scene = preload("res://scenes/objects/ent.tscn")

func _ready():
	randomize()
	_on_Timer_timeout()
	$Timer.start()
func _on_Timer_timeout():
	spawn_enemy()
	$Timer.wait_time=rand_range(min_delay,max_delay)
func spawn_enemy():
	var enemy_spawned = enemy_scene.instance()
	enemy_spawned.curved_motion=true
	get_parent().get_parent().get_node("Entities").call_deferred('add_child',enemy_spawned)
	enemy_spawned.position = self.global_position
	enemy_spawned.curve_size = enemy_curve+get_variance()
	enemy_spawned.non_continuous=true
func get_variance():
	return enemy_variance*Vector2(rand_range(-1,1),rand_range(-1,1))
