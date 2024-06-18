extends CharacterBody2D

const SPEED = 1000.0
const CAST_DURATION = 0.5
const SPELL_DURATION = 1  # Durée en secondes avant de rendre le portail invisible
const ATTACK_RANGE = 1500.0  # Portée d'attaque du monstre

# Définissez le chemin de la scène du portail ici
const PORTAL_SCENE_PATH = "res://path/to/PortalSkill.tscn"

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath

@onready var body = $AnimatedSprite2D
@onready var patrol_a = get_node(patrol_point_a)
@onready var patrol_b = get_node(patrol_point_b)
@onready var animationTree = $AnimationTree
@onready var player = $"../../CharacterBody2D"


var is_spelling = false
var IsIn = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var cast_time = 0.0
var spell_time = 0.0
var is_casting = false
var patrol_direction = -1  # 1 = vers B, -1 = vers A


func _ready():
	pass

func UpdateAnimationParameters():
	if velocity == Vector2.ZERO:
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isWalking", false)
	else:
		animationTree.set("parameters/conditions/isWalking", true)
		animationTree.set("parameters/conditions/isIdle", false)
	if player_in_range():
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isWalking", false)
		animationTree.set("parameters/conditions/isAttacking", true)
	else:
		animationTree.set("parameters/conditions/isAttacking", false)

func _physics_process(delta):
	if player_in_range() and is_within_patrol_area(player.global_position):
		attack_player(delta)
	else:
		patrol(delta)
	UpdateAnimationParameters()
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()  # Assurez-vous que move_and_slide() est appelé avec le vecteur velocity

func player_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE


func attack_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	if direction.x < 0:
		body.flip_h = true
	if direction.x > 0:
		body.flip_h = false
	if global_position.distance_to(player.global_position) <= 500.0:
		animationTree.set("parameters/conditions/isAttacking", true)

func patrol(delta):
	if patrol_direction == 1 and abs(global_position.x - patrol_b.global_position.x) <= 10:
		patrol_direction = -1
	elif patrol_direction == -1 and abs(global_position.x - patrol_a.global_position.x) <= 10:
		patrol_direction = 1
	var target = patrol_b.global_position if patrol_direction == 1 else patrol_a.global_position
	var direction = (target - global_position).normalized()
	if direction.x < 0:
		body.flip_h = true
	if direction.x > 0:
		body.flip_h = false
	velocity.x = direction.x * SPEED

func is_within_patrol_area(position: Vector2) -> bool:
	return position.x >= min(patrol_a.global_position.x, patrol_b.global_position.x) and position.x <= max(patrol_a.global_position.x, patrol_b.global_position.x)