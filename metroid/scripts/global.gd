extends Node



#sound effect data
export(Array,int)var sound_count=[]
export(Array,String)var sound_names=[]
export(Array,int,-40,0)var sound_db=[]


func _ready():
	randomize()

#plays the sound effects for the game
func load_audio(audio_name):
	var audio_id =sound_names.find(audio_name)
	if sound_count[audio_id]!=0:audio_name+=str(round(rand_range(0.0,sound_count[audio_id])))
	var sound_out = AudioStreamPlayer.new()
	sound_out.stream = load("res://Audio/sfx/"+audio_name+".wav")
	add_child(sound_out)
	sound_out.connect("finished",self,"remove_sound",[sound_out])
	sound_out.volume_db = sound_db[audio_id]
	sound_out.play()
	
func remove_sound(sound_id):
	sound_id.disconnect("finished",self,"remove_sound")
	sound_id.queue_free()
