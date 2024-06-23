extends Node2D

@onready var player = $CharacterBody2D as CharacterBody2D
@onready var HALLSALLE = preload("res://Scenes/HALLSALLE.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	# Check if the "ENTRER" action is pressed
	if event.is_action_pressed("ENTRER"):
		# Check if the player's x position is within the range
		if player.position.x >= 15000 and player.position.x <= 18000:
			print("is in ")
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().change_scene_to_packed(HALLSALLE)
