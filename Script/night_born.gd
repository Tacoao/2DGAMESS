extends CharacterBody2D

const SPEED = 5200.0

@export var ATTACK_RANGE = 1500.0  # Portée d'attaque du monstre

# Définissez le chemin de la scène du portail ici
const PORTAL_SCENE_PATH = "res://path/to/PortalSkill.tscn"

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath

@onready var body = $AnimatedSprite2D
@onready var patrol_a = get_node(patrol_point_a)
@onready var patrol_b = get_node(patrol_point_b)
@onready var animationTree = $AnimationTree
@onready var player = $"../../CharacterBody2D"
@onready var playerlife = $"../../WorldDetails/3/StatusLife"
@onready var takendamage = $takenDamage
@onready var remove_after_death = $removeAfterDeath
@onready var area2D = $Area2D
var IsInDamage = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var cast_time = 0.0
var spell_time = 0.0
var patrol_direction = -1  # 1 = vers B, -1 = vers A
var isHit = false
var life = 40
var ImDead = false

func take_damage(damage):
	isHit =true
	life -= damage
	animationTree.set("parameters/conditions/isHit",true)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isWalking",false)
	animationTree.set("parameters/conditions/isIdle",false)

func UpdateAnimationParameters():
	if velocity == Vector2.ZERO:
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isWalking", false)
		animationTree.set("parameters/conditions/isHit",false)
	else:
		animationTree.set("parameters/conditions/isWalking", true)
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isHit",false)
	if IsInDamage and player.is_dead == false:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isWalking", false)
		animationTree.set("parameters/conditions/isAttacking", true)
	else:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isAttacking", false)
func Death():
	ImDead = true
	animationTree.set("parameters/conditions/isHit",false)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isWalking",false)
	animationTree.set("parameters/conditions/isIdle",false)
	animationTree.set("parameters/conditions/isDead",true)
	if remove_after_death.is_stopped():
		remove_after_death.start()
func _physics_process(delta):
	
	if life <= 0:
		Death()
	if not ImDead:
		if IsInDamage and player.is_dead == false :
			attack_player(delta)
		else:
			patrol()
			player_in_range()
		if not isHit:
			UpdateAnimationParameters()
		else:
			isHit = false
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide() 

func player_in_range():
	if global_position.distance_to(player.global_position) <= 10000 and is_within_patrol_area():
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		if direction.x < 0:
			body.flip_h = true
			area2D.position.x = -40
		if direction.x > 0:
			body.flip_h = false
			area2D.position.x = 0
	else :
		patrol()

func attack_player(delta):
	if IsInDamage:
		animationTree.set("parameters/conditions/isAttacking", true)
		if takendamage.is_stopped():
			takendamage.start()
func patrol():
	if patrol_direction == 1 and abs(global_position.x - patrol_b.global_position.x) <= 10:
		patrol_direction = -1
	elif patrol_direction == -1 and abs(global_position.x - patrol_a.global_position.x) <= 10:
		patrol_direction = 1
	var target = patrol_b.global_position if patrol_direction == 1 else patrol_a.global_position
	var direction = (target - global_position).normalized()
	if direction.x < 0:
		body.flip_h = true
		area2D.position.x = -40
	if direction.x > 0:
		body.flip_h = false
		area2D.position.x = 0
	velocity.x = direction.x * SPEED

func is_within_patrol_area() -> bool:
	return position.x >= min(patrol_a.global_position.x, patrol_b.global_position.x) and position.x <= max(patrol_a.global_position.x, patrol_b.global_position.x)


func _on_area_2d_body_exited(body):
	if body == player:
		IsInDamage = false


func _on_area_2d_body_entered(body):
	if body == player:
		IsInDamage = true



func _on_taken_damage_timeout():
	if IsInDamage and not ImDead: 
		playerlife.takedamage(5)
		
func _on_remove_after_death_timeout():
	queue_free()
