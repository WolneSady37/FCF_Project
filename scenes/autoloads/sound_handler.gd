# Copyright 2025 Absynth Studio & Free Courts Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Plays music and/or sound non-positionally.
extends Node

## @experimental
## When enabled, all sounds are played with randomized pitch.
@export var randomize_pitch: bool = false
## @experimental
## Maximum pitch change allowed when using pitch randomizer.
@export var rand_scale: float = 0.1
## When enabled, loops music playback if there is nothing left in queue.
@export var loop_on_empty_queue: bool = true

## Corresponds to current music playback position when adding a layer.
## When music layer is added, it starts playback from this moment.
var music_saved_pos: float = 0.0
## Whether music playback should loop when finished or not.
var is_looping: bool = false

# Fadein tween for music.
var _music_fadein: Tween
# Fadeout tween for music.
var _music_fadeout: Tween
# Prevents accidental fade overlap when fading music.
var _fading: bool = false

## Reference to Music player.
@onready var music: AudioStreamPlayer = $Music
## Reference to Sounds group node.
@onready var sounds: Node = $Sounds
# RandomNumberGenerator used in pitch randomizer.
@onready var _shrng := RandomNumberGenerator.new()

func _ready() -> void:
	_shrng.randomize()

#region MUSIC
## Starts the playback of music. Requires an OGG sound resource (NOT path!).[br]
## Does nothing when trying to play the same music as the one currently played.
func play_music(stream: AudioStreamOggVorbis, volume_db: float = 0, 
		pitch: float = 1.0, stream_pos: float = 0.0) -> void:
	# Do not play the same music.
	if music.stream == stream || stream == null:
		if !music.is_playing():
			music.play(stream_pos)
		return

	# Setup music
	music.stream = stream
	music.set_volume_db(volume_db)
	music.set_pitch_scale(pitch)
	music.play(stream_pos)
	is_looping = music.stream.has_loop()


## Pauses the current music playback (including layers).
func pause_music() -> void:
	if music.stream_paused:
		push_warning("Music already paused.")
		return
	
	music.stream_paused = true


## Pauses the current music playback (including layers).
func resume_music() -> void:
	if !music.stream_paused:
		push_warning("Music already resumed.")
		return
	
	music.stream_paused = false

## Starts music playback again from the begining.
func restart_music() -> void:
	music.play(0.0)


## @experimental
## Toggles music pause (including layers).
func toggle_pause() -> void:
	music.stream_paused =! music.stream_paused


## Instantly stops any current music playback (including layers).
func stop_music() -> void:
	music.stop()


## Enables music loop (including layers).
func enable_loop() -> void:
	if music.stream == null:
		push_warning("No music resource loaded.")
		return
	
	music.stream.loop = true
	is_looping = true


## Disables music loop (including layers).
func disable_loop() -> void:
	if music.stream == null:
		push_warning("No music resource loaded.")
		return
	
	music.stream.loop = false
	is_looping = false


## Smoothly fades out the music over time and sets it to paused once finished.
## Includes layers only if [param fade_layers] is set to [code]true[/code].
func fadeout_music(time: float = 1.0) -> void:
	if _fading:
		return
	
	_fading = true
	_music_fadeout = music.create_tween()
	_music_fadeout.finished.connect(_on_fadeout_tween_completed
			.bind(_music_fadeout))
	_music_fadeout.tween_property(music, ^"volume_db", -80, time)\
		.set_ease(Tween.EASE_IN)


## Smoothly fades in the music over time and sets it to unpaused once finished.
func fadein_music(time: float = 1.0, volume: float = 0) -> void:
	if _fading:
		return
	
	_fading = true
	resume_music()
	_music_fadein = music.create_tween()
	_music_fadein.finished.connect(_on_fadein_tween_completed
			.bind(_music_fadein))
	music.play(music_saved_pos)
	_music_fadein.tween_property(music, ^"volume_db", volume, time)\
		.set_ease(Tween.EASE_IN)

#endregion

#region SOUNDS
## Starts the playback of sound. Requires absolute path to the sound file.
## Note: Sounds played this way will NOT loop.
func play_sound(stream: AudioStreamOggVorbis, volume_db: float = 0, 
		pitch: float = 1.0, stream_pos: float = 0.0) -> void:
	var sound := AudioStreamPlayer.new()
	# Setup sound
	sound.set_stream(stream)
	sound.set_volume_db(volume_db)
	var p: float = pitch * _shrng.randf_range(
			pitch - rand_scale, pitch + rand_scale) \
			if randomize_pitch else pitch
	
	sound.set_pitch_scale(p)
	sound.seek(0.0)
	sound.stream.set_loop(false)
	sound.set_bus(&"Sound")
	
	sounds.add_child(sound)
	sound.play(stream_pos)
	await sound.finished
	sound.queue_free()
#endregion

#region SIGNAL CONNECTIONS
func _on_fadeout_tween_completed(tween: Tween) -> void:
	tween.kill()
	music_saved_pos = music.get_playback_position()
	pause_music()
	_fading = false


func _on_fadein_tween_completed(tween: Tween) -> void:
	tween.kill()
	_fading = false
#endregion
