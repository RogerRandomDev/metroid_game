extends Node



#sound effect data
export(Array,int)var sound_count=[]
export(Array,String)var sound_names=[]
export(Array,int,-40,10)var sound_db=[]


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

#removes sound effect object after finish
func remove_sound(sound_id):
	sound_id.disconnect("finished",self,"remove_sound")
	sound_id.queue_free()
var cur_music = ""
func play_music(name_of,transition_time=1.5):
	if cur_music == name_of:return
	cur_music = name_of
	var previous_music =get_node_or_null("music")
	var remove_music = get_node_or_null("last_music")
	if remove_music!=null:
		remove_music.queue_free()
	if previous_music!=null:
		previous_music.name="last_music"
	var music_new = AudioStreamPlayer.new()
	music_new.stream = load("res://Audio/Music/"+name_of+".mp3")
	music_new.name = "music"
	add_child(music_new)
	if previous_music!=null:
		$Tween.interpolate_property(previous_music,"volume_db",previous_music.volume_db,-40,transition_time,Tween.TRANS_CUBIC)
	$Tween.interpolate_property(music_new,"volume_db",-40,0,transition_time,Tween.TRANS_CUBIC)
	music_new.play()
	$Tween.start()
