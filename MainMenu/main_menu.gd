class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Play as Button
@onready var continue_button = $MarginContainer/HBoxContainer/VBoxContainer/Continue as Button 
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button

@onready var LightPlay = $MarginContainer/HBoxContainer/VBoxContainer/LightPlay as Light2D
@onready var LightContinue = $MarginContainer/HBoxContainer/VBoxContainer/LightContinue as Light2D
@onready var LightQuit = $MarginContainer/HBoxContainer/VBoxContainer/LightQuit as Light2D

@onready var Video = $Video

@onready var bg = $Background
@onready var Fog = $Fog
@onready var Logo = $Logo
@onready var margin = $MarginContainer
@onready var Audio = $AudioStreamPlayer


@onready var start_level = preload("res://Scenes/main.tscn") as PackedScene

func _ready():
	start_button.button_down.connect(on_start_button_pressed)
	continue_button.button_down.connect(on_continue_button_pressed)
	quit_button.button_down.connect(on_exit_button_pressed)	

	start_button.mouse_entered.connect(on_start_button_hover)
	continue_button.mouse_entered.connect(on_continue_button_hover)

	quit_button.mouse_entered.connect(on_quit_button_hover)

	start_button.mouse_exited.connect(on_start_button_exited)
	continue_button.mouse_exited.connect(on_continue_button_exited)
	quit_button.mouse_exited.connect(on_quit_button_exited)



func on_start_button_pressed() -> void :
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	Video.play()
	bg.hide()
	Fog.hide()
	Logo.hide()
	margin.hide()
	Audio.stop()
	await Video.finished
	get_tree().change_scene_to_packed(start_level)
	

func on_continue_button_pressed() -> void :
	get_tree().change_scene("res://ContinueMenu.tscn")
	$ClickSound.play()

func on_exit_button_pressed() -> void :
	get_tree().quit()
	$ClickSound.play()


func on_start_button_hover() -> void:
	LightPlay.show()
	LightContinue.hide()
	LightQuit.hide()
	$Hoversound.play()

func on_continue_button_hover() -> void:
	LightPlay.hide()
	LightContinue.show()
	LightQuit.hide()
	$Hoversound.play()

func on_quit_button_hover() -> void:
	LightPlay.hide()
	LightContinue.hide()
	LightQuit.show()
	$Hoversound.play()

func on_start_button_exited() -> void:
	LightPlay.hide()
	
func on_continue_button_exited() -> void:
	LightContinue.hide()


func on_quit_button_exited() -> void:
	LightQuit.hide()



