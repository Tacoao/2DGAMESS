extends PointLight2D

@onready var player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	player.play("light_animation")# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
