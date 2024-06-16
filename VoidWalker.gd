extends CharacterBody2D

const SPEED = 1000.0
const CAST_DURATION = 0.5
const SPELL_DURATION = 1  # Durée en secondes avant de rendre le portail invisible
const ATTACK_RANGE = 2000.0  # Portée d'attaque du monstre
const SPELL_RANGE = 2500.0

# Définissez le chemin de la scène du portail ici
const PORTAL_SCENE_PATH = "res://path/to/PortalSkill.tscn"

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath

@onready var body = $Sprite2D
@onready var patrol_a = get_node(patrol_point_a)
@onready var patrol_b = get_node(patrol_point_b)
@onready var portal = $PortalSkill/Sprite2D
@onready var area2D = $PlayerDetection
@onready var animationTree = $AnimationTree
@onready var player = $"../../CharacterBody2D"
@onready var portal_Animationplayer = $AnimationPlayer

var is_spelling = false
var IsIn = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var cast_time = 0.0
var spell_time = 0.0
var is_casting = false
var patrol_direction = -1  # 1 = vers B, -1 = vers A

var portal_instance = null

func _ready():
	pass

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
	else:
		animationTree.set("parameters/conditions/isCasting", false)
		animationTree.set("parameters/conditions/isIdle", true)
	if player_in_range():
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isWalking", false)
		animationTree.set("parameters/conditions/isAttacking", true)
	else:
		animationTree.set("parameters/conditions/isAttacking", false)

func _physics_process(delta):
	if player_in_range():
		attack_player(delta)
	else:
		patrol(delta)

	if player_in_skill_range():
		IsIn = true
		cast_time = 0.0
		spell_time = 0.0
		is_spelling = false
		is_casting = true  # Reset the cast time when casting
	else:
		IsIn = false

	if is_casting and cast_time >= CAST_DURATION:
		is_casting = false
		is_spelling = true
		spawn_portal()
		portal_Animationplayer.play("portalSkill")

	if is_spelling and spell_time >= SPELL_DURATION:
		is_spelling = false
		remove_portal()

	if is_casting:
		cast_time += delta
	if is_spelling:
		spell_time += delta

	UpdateAnimationParameters()

	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_spelling:
		move_and_slide()

func player_in_range() -> bool:
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE

func player_in_skill_range() -> bool:
	return global_position.distance_to(player.global_position) <= SPELL_RANGE and global_position.distance_to(player.global_position) >= ATTACK_RANGE

func attack_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED
	if direction.x < 0:
		body.flip_h = false
	if direction.x > 0:
		body.flip_h = true
	animationTree.set("parameters/conditions/isAttacking", true)

func patrol(delta):
	if patrol_direction == 1 and abs(global_position.x - patrol_b.global_position.x) <= 10:
		patrol_direction = -1
	elif patrol_direction == -1 and abs(global_position.x - patrol_a.global_position.x) <= 10:
		patrol_direction = 1

	var target = patrol_b.global_position if patrol_direction == 1 else patrol_a.global_position
	var direction = (target - global_position).normalized()
	if direction.x < 0:
		body.flip_h = false
	if direction.x > 0:
		body.flip_h = true
	velocity.x = direction.x * SPEED

func spawn_portal():
	if not portal_instance:
		var portal_scene = load("res://Scenes/portal_skill.tscn")
		portal_instance = portal_scene.instantiate()
		get_parent().add_child(portal_instance)
		var portal_position = player.global_position - Vector2(50,5)
		print("Player Position:", player.global_position)
		print("Portal Position:", portal_position)
		portal_instance.global_position = portal_position
		var portal_animation_player = portal_instance.get_node("AnimationPlayer")
		if portal_animation_player:
			portal_animation_player.play("portalSkill")

func remove_portal():
	if portal_instance:
		portal_instance.queue_free()
		portal_instance = null
