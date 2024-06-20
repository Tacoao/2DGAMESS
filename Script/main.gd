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
		print(player.bowMod)
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
