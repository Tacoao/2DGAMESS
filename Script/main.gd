extends Node2D
@onready var rope = $Rope
@onready var Handle = $RopeHandle
@onready var player = $CharacterBody2D
@onready var life = $"WorldDetails/3/StatusLife"
const FRAME_HEIGHT = 25
func _ready():
	rope.visible = false
var action = false
func _input(event):
	if Input.is_action_just_pressed("RightClick"):
		if player.bowMod:
			action = true
			rope.global_position = player.get_hook_position()
	if Input.is_action_just_released("RightClick"):
		if player.bowMod:
			action = false
func _process(delta):
	if action:
		if player.get_hook_position():
			Handle.global_position = player.global_position + Vector2(-20, -FRAME_HEIGHT / 2)
			rope.rope_length = (Handle.global_position - player.global_position).length() +200
			Handle.global_position.y -= 15
			rope.visible = true
	else:
		rope.visible = false


func _on_instant_fall_death_body_entered(body):
	if body == player:
		player.death()

@onready var AmbiantSound = $sound/AmbiantSound
@onready var cinematic = $Camera2D/CanvasLayer2
@onready var endTimer = $EndTiming
var cinematic_played = false
func _on_in_cinematic_body_entered(body):
	if body == player and not cinematic_played:
		cinematic.visible = true
		player.InCinematic = true
		endTimer.start()
		AmbiantSound.stop()
		cinematic.play()


func _on_end_timing_timeout():
	cinematic.visible = false
	player.InCinematic = false
	AmbiantSound.play()



func _on_in_cinematic_body_exited(body):
	if body == player:
		cinematic_played=true
