extends CanvasLayer

@onready var video = $VideoStreamPlayer
# Called when the node enters the scene tree for the first time.
func play():
	video.play()
