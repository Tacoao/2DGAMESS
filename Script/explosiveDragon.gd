extends CharacterBody2D
const ATTACK_RANGE = 500.0
@onready var NavigationAgent = $Navigation/NavigationAgent2D
@export var target_player : CharacterBody2D
@onready var animationTree = $AnimationTree
@onready var sprite = $AnimatedSprite2D
@onready var InContactTimer = $InContactTimer
@onready var playerlife = $"../../WorldDetails/3/StatusLife"
var speed = 2000
var acceleration = 50
var is_in_contact = false
var IsInDamage = false

func player_in_range() -> bool:
	return global_position.distance_to(target_player.global_position) <= ATTACK_RANGE

func update_direction():
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func UpdateAnimationParameters():
	if velocity == Vector2.ZERO:
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isRunning", false)
	else:
		animationTree.set("parameters/conditions/isRunning", true)
		animationTree.set("parameters/conditions/isIdle", false)

	if player_in_range():
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isRunning", false)
		animationTree.set("parameters/conditions/InContact", true)
		if not is_in_contact:
			print("Starting InContactTimer")
			InContactTimer.start(0.45)  # Start the timer with a 0.5-second delay
			is_in_contact = true
	else:
		animationTree.set("parameters/conditions/InContact", false)
		is_in_contact = false

func _physics_process(delta):
	var direction = Vector2.ZERO
	direction = NavigationAgent.get_next_path_position() - global_position
	direction = direction.normalized()

	velocity = velocity.lerp(direction * speed, acceleration * delta)
	update_direction()
	UpdateAnimationParameters()
	move_and_slide()

func _on_timer_timeout():
	NavigationAgent.target_position = target_player.global_position

func _on_in_contact_timer_timeout():

	playerlife.takedamage(5)
	queue_free()


func _on_area_2d_body_exited(body):
	if body == target_player:
		IsInDamage = false


func _on_area_2d_body_entered(body):
	if body == target_player:
		IsInDamage = true
