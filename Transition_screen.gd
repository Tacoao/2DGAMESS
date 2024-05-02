extends CanvasLayer

@onready var color_react = $ColorRect
@onready var animation_player =$AnimationPlayer
signal on_transition_finished
func _ready():
	color_react.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		animation_player.play("fade_out_black")
	elif anim_name == "fade_out_black":
		color_react.visible = false
func transition():
	color_react.visible = true
	animation_player.play("fade_to_black")
