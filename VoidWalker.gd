extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CAST_DURATION = 1.5  # Durée en secondes avant de rendre le portail invisible
@onready var portal = $PortalSkill/Sprite2D
@onready var area2D = $PlayerDetection
@onready var animationTree = $AnimationTree
var IsIn = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var cast_time = 0.0

func _ready():
	portal.visible = false

func UpdateAnimationParameters():
	if velocity == Vector2.ZERO:
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isWalking", false)
	else:
		animationTree.set("parameters/conditions/isWalking", true)
		animationTree.set("parameters/conditions/isIdle", false)

	if IsIn:
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isCasting", true)
		portal.visible = true
	else:
		animationTree.set("parameters/conditions/isCasting", false)
		animationTree.set("parameters/conditions/isIdle", true)
		if cast_time >= CAST_DURATION:
			portal.visible = false

func _physics_process(delta):
	if Input.is_action_just_pressed("cast"):
		IsIn = true
		cast_time = 0.0  # Reset the cast time when casting
	else:
		IsIn = false

	if portal.visible:
		cast_time += delta  # Update the cast time

	UpdateAnimationParameters()

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
