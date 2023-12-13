extends Node3D

@export var footstep_sounds : Array[AudioStreamMP3]
@export var ground_pos : Marker3D
@onready var player : CharacterBody3D = get_parent()

func _ready() -> void:
	player.step.connect(play_sound)

func play_sound():
	var audio_player : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	var random_index : int = randi_range(0, footstep_sounds.size() - 1)
	audio_player.stream = footstep_sounds[random_index]
	audio_player.pitch_scale = randf_range(1,1.2)
	audio_player.volume_db = -30
	ground_pos.add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func destroy(): audio_player.queue_free())
