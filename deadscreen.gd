extends Control


@onready var start_level = preload("res://Scenes/main.tscn") as PackedScene
@onready var deadsound = $deadsound
@onready var deadmusic = $deadmusic


func _ready():
	deadsound.play()
	deadmusic.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("retry"):
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_packed(start_level)
