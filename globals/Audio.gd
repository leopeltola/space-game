extends Node

enum {
	FADE_IN,
	FADE_OUT,
}

var songs_num = 0
var songs = [
	{
		"song": preload("res://audio/music/AKMV-18 - Memoria (Mythic Mix).mp3"),
		"label": "Memoria (Mythic Mix)",
		"artist": "AKMV-18",
	},
	{
		"song": preload("res://audio/music/Avaruuspeli_Apollo.mp3"),
		"label": "Apollo",
		"artist": "KoskenKolistaja",
	},
	{
		"song": preload("res://audio/music/HoliznaCC0 - Lost In Space.mp3"),
		"label": "Lost In Space",
		"artist": "Holizna",
	},
	{
		"song": preload("res://audio/music/Avaruuspeli_Revelation.mp3"),
		"label": "Revelation",
		"artist": "KoskenKolistaja",
	},
	{
		"song": preload("res://audio/music/Avaruuspeli_Uncharted.mp3"),
		"label": "Uncharted",
		"artist": "KoskenKolistaja",
	},
]

var fade_state = FADE_IN
var song_being_played = null
var playing_soundtrack = false


func _ready():
	$Music/MusicPlayer.connect("finished", self, "_on_MusicPlayer_finished")
	play_soundtrack()


func next_song_num():
	songs_num += 1
	if songs_num >= songs.size():
		songs_num = 0
	return songs_num


func prev_song_num():
	songs_num -= 1
	if songs_num <= -1:
		songs_num = songs.size() - 1
	return songs_num


func play_soundtrack():
	playing_soundtrack = true
	songs_num = int(rand_range(0, songs.size() - 1))
	play_music_soundtrack(songs[songs_num]["song"])


func soundtrack_next_song():
	var new_num = next_song_num()
	song_being_played = songs[songs_num]["song"]
	$Music/MusicPlayer.stream = song_being_played
	$Music/MusicPlayer.play()


func soundtrack_prev_song():
	var new_num = prev_song_num()
	song_being_played = songs[songs_num]["song"]
	$Music/MusicPlayer.stream = song_being_played
	$Music/MusicPlayer.play()


func is_playing_music():
	if $Music/MusicPlayer.playing:
		return true
	return false


func play_music_soundtrack(music_clip: AudioStream):
	song_being_played = music_clip

	$Music/MusicPlayer.stream = music_clip
	$Music/MusicPlayer.play()


func play_music(music_clip: AudioStream):
	playing_soundtrack = false
	song_being_played = music_clip
	$Music/MusicPlayer.stream = music_clip
	$Music/MusicPlayer.play()


func stop_music():
	$Music/MusicPlayer.stop()


func get_current_song_name() -> String:
	return songs[songs_num]["label"]


func get_current_song_artist() -> String:
	return songs[songs_num]["artist"]


func play_sfx(audio_clip: AudioStream, volume = 0):
	for child in $Sfx.get_children():
		if not child.playing:
			child.stream = audio_clip
			child.play()
			child.volume_db = volume
			break


func fade(fade_out: bool):
	fade_state = int(fade_out)
	match fade_state:
		FADE_IN:
			print("fade_in")
			$Music/MusicPlayer.volume_db = -30
			$Timer.start()
		FADE_OUT:
			print("fade_out")
			$Music/MusicPlayer.volume_db = 0
			$Timer.start()


func _on_MusicPlayer_finished():
	print("Music finished!")
	if playing_soundtrack:
		soundtrack_next_song()
		return
	print("Not playing soundtrack")
	$Music/MusicPlayer.stream = song_being_played
	$Music/MusicPlayer.play()


func _on_Timer_timeout():
	match fade_state:
		FADE_IN:
			$Music/MusicPlayer.volume_db += 1
			if $Music/MusicPlayer.volume_db >= 0:
				$Timer.stop()
		FADE_OUT:
			$Music/MusicPlayer.volume_db -= 1
			if $Music/MusicPlayer.volume_db <= -30:
				$Timer.stop()
