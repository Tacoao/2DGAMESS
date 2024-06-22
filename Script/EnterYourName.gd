extends Control

@onready var bg = $Bg
@onready var LightTop = $LightTop
@onready var Edit = $LineEdit
@onready var Confirm = $MarginContainer/HBoxContainer/VBoxContainer/Confirm as Button
@onready var LightConfirm = $MarginContainer/HBoxContainer/VBoxContainer/LightConfirm
@onready var Fog = $Fog
@onready var PanelContainerEsc = $PanelContainerEsc
@onready var margin = $MarginContainer
@onready var Video = $Video
@onready var Hoversound = $Hoversound

var username : String
var boolescape = false
var video_playing = false  # Variable to track if the video is playing
var transition_in_progress = false  # Variable to track if a transition is in progress
@onready var start_level = preload("res://Scenes/main.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	LightConfirm.hide()
	Confirm.pressed.connect(_on_Confirm_button_pressed)
	Confirm.mouse_entered.connect(_on_Confirm_button_hover)
	PanelContainerEsc.hide()
	Video.hide()

	if boolescape:
		Video.finished.connect(_on_Video_finished)
		Video.play()
		video_playing = true

func _process(delta):
	pass

func _on_Confirm_button_pressed() -> void:
	username = Edit.text
	print("Global value set to: ", username)
	VariableGlobale.username = username
	Video.show()
	Video.play()
	bg.hide()
	Fog.hide()
	margin.hide()
	PanelContainerEsc.show()
	Edit.hide()
	LightTop.hide()
	boolescape = true
	video_playing = true
	# Audio.stop() # Uncomment if you have an audio node to stop

func _on_Confirm_button_hover() -> void:
	LightConfirm.show()
	Hoversound.play()

func _input(event):
	if event.is_action_pressed("echap") and video_playing:
		Video.stop()
		video_playing = false
		_transition_to_start_level()

func _on_Video_finished():
	video_playing = false
	_transition_to_start_level()

func _transition_to_start_level():
	if transition_in_progress:
		return  # Exit if a transition is already in progress

	transition_in_progress = true  # Set the flag indicating a transition is in progress
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	transition_in_progress = false  # Reset the flag after transition is complete
	get_tree().change_scene_to_packed(start_level)
