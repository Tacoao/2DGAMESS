extends CharacterBody2D


@export var  ATTACK_RANGE = 1000.0  # Portée d'attaque du monstre
@onready var sprite = $AnimatedSprite2D
@onready var body = $AnimatedSprite2D
@onready var animationTree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@export var player: CharacterBody2D
@export var initialPostion : Node2D
@export var playerlife : Node2D 
@onready var timer = $timerattack
@onready var NavigationAgent = $Navigation/NavigationAgent2D
@onready var area2D = $Area2D
@onready var runningSound = $RunSound
@onready var attqueSound = $attaqueSound
var speed = 2000
var acceleration = 50
var is_spelling = false
var IsIn = false
var atInitialePoint = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var patrol_direction = -1  
var IsInZone = false
var isHit = false
var life = 20
var ImDead = false
func take_damage(damage):
	isHit =true
	life -= damage
	print(life)
	animationTree.set("parameters/conditions/isHit",true)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isRunning",false)
	animationTree.set("parameters/conditions/isIdle",false)

func UpdateAnimationParameters():
	if velocity == Vector2.ZERO or atInitialePoint:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", true)
		animationTree.set("parameters/conditions/isRunning", false)
	else:
		if runningSound.playing == false:
			runningSound.play()
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isRunning", true)
		animationTree.set("parameters/conditions/isIdle", false)

	if IsInZone and player.is_dead == false:
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isIdle", false)
		animationTree.set("parameters/conditions/isRunning", false)
		animationTree.set("parameters/conditions/isAttacking", true)
	else :
		animationTree.set("parameters/conditions/isHit",false)
		animationTree.set("parameters/conditions/isAttacking", false)
func update_direction():
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
func _physics_process(delta):
	if life <= 0:
		Death()
	if not ImDead:
		if IsInZone :
			attack_player(delta)
		var direction = Vector2.ZERO
		direction = NavigationAgent.get_next_path_position() - global_position
		direction = direction.normalized()

		velocity = velocity.lerp(direction * speed, acceleration * delta)
		update_direction()
		if not isHit:
			UpdateAnimationParameters()
		else:
			isHit=false
		move_and_slide()
		

func player_in_range() -> bool:
	if player != null:
		return global_position.distance_to(player.global_position) <= ATTACK_RANGE
	else:
		return false


func attack_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * speed
	if direction.x <0:
		body.flip_h = true
		area2D.position.x = -65
	if direction.x >0:
		body.flip_h = false
		area2D.position.x = 0
	if attqueSound.playing ==false :
		attqueSound.play()
	animationTree.set("parameters/conditions/isAttacking", true)
	if timer.is_stopped():
		timer.start(1.2)

func _on_timer_timeout():
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE:
		NavigationAgent.target_position = player.global_position
		atInitialePoint = false
	else:
		NavigationAgent.target_position = initialPostion.global_position
		atInitialePoint = true
		
func _on_area_2d_body_entered(body):
	if body == player:
		IsInZone = true

func Death():
	ImDead = true
	animationTree.set("parameters/conditions/isHit",false)
	animationTree.set("parameters/conditions/isAttacking",false)
	animationTree.set("parameters/conditions/isWalking",false)
	animationTree.set("parameters/conditions/isIdle",false)
	animationTree.set("parameters/conditions/isDead",true)
		
func _on_area_2d_body_exited(body):
	if body == player:
		IsInZone = false


func _on_timerattack_timeout():
	if IsInZone and not ImDead:
		playerlife.takedamage(5)
