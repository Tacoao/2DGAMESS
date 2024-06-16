extends CharacterBody2D

const SPEED = 1000.0
const ATTACK_RANGE = 1000.0  # Portée d'attaque du monstre
@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath
@onready var body = $AnimatedSprite2D
@onready var patrol_a = get_node(patrol_point_a)
@onready var patrol_b = get_node(patrol_point_b)
@onready var animationTree = $AnimationTree
@export var player: CharacterBody2D

var is_spelling = false
var IsIn = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var patrol_direction = -1  


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
		animationTree.set("parameters/conditions/isAttacking", true)
	else :
		animationTree.set("parameters/conditions/isAttacking", false)

func _physics_process(delta):
	if player_in_range():
		attack_player(delta)
		
	else:
		patrol(delta)
	UpdateAnimationParameters()
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
		

func player_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE


func attack_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	if direction.x <0:
		body.flip_h = true
	if direction.x >0:
		body.flip_h = false
	animationTree.set("parameters/conditions/isAttacking", true)

func patrol(delta):
	if patrol_direction == 1 and abs(global_position.x - patrol_b.global_position.x) <=20:
		patrol_direction = -1
	elif patrol_direction == -1 and abs(global_position.x - patrol_a.global_position.x) <= 20:
		patrol_direction = 1

	var target = patrol_b.global_position if patrol_direction == 1 else patrol_a.global_position
	var direction = (target - global_position).normalized()
	if direction.x <0:
		body.flip_h = true
	if direction.x >0:
		body.flip_h = false
	velocity.x = direction.x * SPEED
