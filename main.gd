extends Node2D
@onready var rope = $Rope
@onready var Handle = $Marker2D
@onready var player = $CharacterBody2D
const FRAME_HEIGHT = 25
func _ready():
	rope.visible = false
var action = false
func _input(event):
	if Input.is_action_just_pressed("hook"):
			action = true
			rope.global_position = player.GetHookPosition()
	if Input.is_action_just_released("hook"):
		action = false
func _process(delta):
	if action:
		if player.GetHooked():
			rope.visible = true
			
			Handle.global_position = player.global_position + Vector2(-20, -FRAME_HEIGHT / 2)
			rope.rope_length = (Handle.global_position - player.global_position).length() +200
			Handle.global_position.y -= 15
	else:
		rope.visible = false
