extends CharacterBody2D

const SPEED = 1000.0
const CAST_DURATION = 0.5
const SPELL_DURATION = 1  # Durée en secondes avant de rendre le portail invisible
const ATTACK_RANGE = 2000.0  # Portée d'attaque du monstre
const SPELL_RANGE = 2500.0
@onready var givedamage = $givedamage

# Définissez le chemin de la scène du portail ici
const PORTAL_SCENE_PATH = "res://path/to/PortalSkill.tscn"

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath
@onready var playerlife = $"../../WorldDetails/3/StatusLife"
@onready var body = $Sprite2D
@onready var patrol_a = get_node(patrol_point_a)
@onready var patrol_b = get_node(patrol_point_b)
@onready var area2D = $Sprite2D/PlayerDetection
@onready var animationTree = $AnimationTree
@onready var player = $"../../CharacterBody2D"
@onready var portal_Animationplayer = $AnimationPlayer

var is_spelling = false
var IsInDamage = false
var IsIn = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var cast_time = 0.0
var spell_time = 0.0
var is_casting = false
var patrol_direction = -1  # 1 = vers B, -1 = vers A
var life = 100
var isHit =false
var ImDead = false
func _ready():
	pass


func UpdateAnimationParameters():
	if velocity == Vector2.ZERO:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isWalking", false)
	else:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isWalking", true)
		animationTree.set("parameters/conditions/isIdle", false)

	if IsIn:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isCasting", true)
	else:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isCasting", false)
		animationTree.set("parameters/conditions/isIdle", true)
	if player_in_range() and player.is_dead == false:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isWalking", false)
		animationTree.set("parameters/conditions/isAttacking", true)
	else:
		animationTree.set("parameters/conditions/isAttacking", false)

func _physics_process(delta):
	if life < 100:
		print("Imdead")
		Death()
	if not ImDead:
		if player_in_range() and is_within_patrol_area(player.global_position) and player.is_dead == false :
			attack_player(delta)
		else:
			patrol(delta)

		if player_in_skill_range() and player.is_dead == false:
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

		if is_casting:
			cast_time += delta
		if is_spelling:
			spell_time += delta
		if not isHit:
			UpdateAnimationParameters()
		else:
			isHit=false
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
		area2D.position.x = 0
	if direction.x > 0:
		body.flip_h = true
		area2D.position.x = 60
	animationTree.set("parameters/conditions/isAttacking", true)
	if givedamage.is_stopped():
		givedamage.start(0.6)

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
		var portal_scene = load("res://Scenes/portal_skill.tscn")
		var portal_instance = portal_scene.instantiate()
		portal_instance.playerlife = playerlife
		portal_instance.player = player
		portal_instance.scale = Vector2(20, 20)
		var portal_position = player.global_position - Vector2(0, -550)
		portal_instance.global_position = portal_position
		get_parent().get_parent().add_child(portal_instance)
		
		var portal_animation_player = portal_instance.get_node("AnimationPlayer")
		if portal_animation_player:
			portal_animation_player.play("portalSkill")


		
func is_within_patrol_area(position: Vector2) -> bool:
	return position.x >= min(patrol_a.global_position.x, patrol_b.global_position.x) and position.x <= max(patrol_a.global_position.x, patrol_b.global_position.x)


func _on_player_detection_body_entered(body):
	if body == player:
		IsInDamage = true


func _on_player_detection_body_exited(body):
	if body == player:
		IsInDamage = false
		


func _on_take_damage_timeout():
	if IsInDamage:
		playerlife.takedamage(5)
		
func take_damage(damage):
	isHit =true
	life -= damage
	animationTree.set("parameters/conditions/isHit",true)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isCasting",false)
	animationTree.set("parameters/conditions/isWalking",false)
	animationTree.set("parameters/conditions/isIdle",false)
	
func Death():
	ImDead = true
	animationTree.set("parameters/conditions/isHit",false)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isCasting",false)
	animationTree.set("parameters/conditions/isWalking",false)
	animationTree.set("parameters/conditions/isIdle",false)
	animationTree.set("parameters/conditions/isDead",true)
	
