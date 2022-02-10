extends Camera2D
var camera_limits = Vector2.ZERO
var active = true
var trauma = 0
var decay = 0.2
var trauma_power = 2.0
var max_roll=PI/3
var max_offset=Vector2(32,32)
func _ready():
	randomize()


func _process(delta):
	#dont update if not active
	if !active:return
	position = get_parent().get_node("Player").position
	position.x = clamp(position.x,512,camera_limits.x+512)
	position.y = clamp(position.y,308,camera_limits.y+308)
	#shake screen if trauma is not at zero
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()




##
#updates position for imediate updates
#only really needed by the main_game.gd
#for getting the target camera position
##
func update_pos():
	position.x = clamp(position.x,0,camera_limits.x)
	position.y = clamp(position.y,0,camera_limits.y)

#adds an amount of screen shake
func add_trauma(amount):
	amount = max(amount,0.2)
	trauma = max(trauma,amount)

#screen shake
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
