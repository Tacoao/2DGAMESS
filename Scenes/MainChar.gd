extends CharacterBody2D

# Mouvement Variable
# Run Variable
@export var deathParticle : PackedScene
var maxlife = 100.0
var life = 100.0

var acceleration = 5000.0 # acceleration du personnage
var AttackHCounter = 0
var AttackLCounter = 0
var dashing = false
var canDash = true # peut dash 
const DASH_SPEED = 10000.0 # vitesse du dash
var dashTimer # temp du dash
var canDashTimer # temp avant prochain dash

# Jump Variable
var jumpHeight = 700.0 # Hauteur du saut
var jumpTimeToPeak = 0.3 # Temp t avant hauteur max du saut atteinte ici jumpHeight
var jumpTimeToFall = 0.2 # Temp t avant de descendre
var jumpVelocity = 0.0 # Vitesse du saut
var jumpForce = 1.2 # Force du saut
var jumpGravity = 0.0 # Gravité appliqué aux saut
var fallGravity = 0.0 # gravité de chute
var maxfallGravity = 10000.0 # Gravité max lors de la chute
var jumpBufferCounter = 15 # Permet de rendre les saut plus fluide
var jumpBufferTime = 15
var jumpCounter = 0
var cayotteTime = 15 # Temp d'erreur 
var cayotteCounter = 0 # nombre d'erreur 
var bowMod = false

var animationTree # animation Tree
@onready var collision = $CollisionShape2D
var animatedSprite2D # Texture du personnage

var wallDetect # detecteur de wall

var HookPosition = Vector2()
var motion = Vector2()

var RopeLenght = 500.0

var CurrentRopeLenght
var rope
var hooked = false

var previousDirection = 0.0
var damageTimer
# Animation Link
var is_dead = false
var idleLink = "parameters/conditions/idle"
var runLink = "parameters/conditions/is_moving"
var isJump = "parameters/conditions/is_jump"
var isLanding = "parameters/conditions/is_landed"
var isFalling = "parameters/conditions/isFalling"

var AttackH1 = "parameters/conditions/isAttackH1"
var AttackH2 = "parameters/conditions/isAttackH2"
var AttackH3 = "parameters/conditions/isAttackH3"
var AttackL1 = "parameters/conditions/isAttackL1"
var AttackL2 = "parameters/conditions/isAttackL2"
var AttackL3 = "parameters/conditions/isAttackL3"
@onready var sprite = $Sprite2D
var isHit = "parameters/conditions/isHurt"
var gpuparticle
var ennemi
var ennemi_in_zone = false
@onready var Area =$Area2D
@onready var givedegalight = $givedegatlight
@onready var givedegalourd =$givedegatlourd 
func _ready():
	print("Script Loaded")
	wallDetect = get_node("wallDetect")
	dashTimer = get_node("dashTimer")
	canDashTimer = get_node("canDashTimer")
	animatedSprite2D = get_node("Sprite2D")
	animationTree = get_node("AnimationTree")
	gpuparticle = get_node("GPUParticles2D")
	gpuparticle.emitting = false
	animationTree.active = true
	wallDetect.enabled = true
	jumpVelocity = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
	jumpGravity = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
	fallGravity = ((-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)) * -1.0
	motion = velocity
	CurrentRopeLenght = RopeLenght
	damageTimer = get_node("DamageTimer")

func death():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	_particle.scale.x = 10
	_particle.scale.y = 10
	get_tree().current_scene.add_child(_particle)
	sprite.visible = false
	collision.queue_free()
	is_dead = true
	
func take_damage(damage):
	life -= damage
	change_color_to_red()
	damageTimer.start(0.5)

func change_color_to_red():
	animatedSprite2D.modulate = Color(1, 0, 0)

func _on_damage_timer_timeout():
	animatedSprite2D.modulate = Color(1, 1, 1)

func animation_handler():
	
	if is_on_wall_only():
	
		animationTree.set("parameters/conditions/isWallGrab", true)
		animationTree.set(isFalling, false)
	else:
		animationTree.set("parameters/conditions/isWallGrab", false)
	if is_on_floor() and animationTree.get(isFalling):
		animationTree.set("parameters/conditions/isWallGrab", false)
		animationTree.set(isFalling, false)
		animationTree.set(isLanding, true)
	if not is_on_floor() and not is_on_wall():
		animationTree.set(isFalling, true)
		animationTree.set(idleLink, false)
		animationTree.set(runLink, false)
		animationTree.set(isLanding, false)
	if velocity == Vector2.ZERO and is_on_floor():
		animationTree.set(isHit, false)
		animationTree.set(isFalling, false)
		animationTree.set(isJump, false)
		animationTree.set(idleLink, true)
		animationTree.set(AttackL1, false)
		animationTree.set(AttackL2, false)
		animationTree.set(AttackL3, false)
		animationTree.set(AttackH1, false)
		animationTree.set(AttackH2, false)
		animationTree.set(AttackH3, false)
		animationTree.set(runLink, false)
	elif is_on_floor():
		animationTree.set(isFalling, false)
		animationTree.set(isJump, false)
		animationTree.set(idleLink, false)
		animationTree.set(AttackL1, false)
		animationTree.set(AttackL2, false)
		animationTree.set(AttackL3, false)
		animationTree.set(AttackH1, false)
		animationTree.set(AttackH2, false)
		animationTree.set(AttackH3, false)
		animationTree.set(runLink, true)

	if Input.is_action_just_pressed("LeftClick"):
		light_attack_handler()
	if Input.is_action_just_pressed("RightClick"):
		heavy_attack_handler()
	if Input.is_action_just_pressed("Jump_Only"):
		jumpBufferCounter = jumpBufferTime
	if jumpBufferCounter > 0:
		jumpBufferCounter -= 1
	if jumpBufferCounter > 0 and cayotteCounter > 0:
		jumpBufferCounter = 0
		cayotteCounter = 0
		jump()

func _physics_process(delta):
	if is_dead == false:
		if life < 0 :
			death()
		motion.y += get_gravity() * delta
		if wallDetect.is_colliding():
			var collider = wallDetect.get_collider()
			if collider.name == "TileMap" and collider:
				maxfallGravity = 1000
		else:
			maxfallGravity = 5000
		if motion.y > maxfallGravity:
			motion.y = maxfallGravity
		if is_on_floor():
			cayotteCounter = cayotteTime
			jumpCounter = 0
		if not is_on_floor():
			if cayotteCounter > cayotteTime:
				cayotteCounter -= 1
			if jumpBufferCounter > 0:
				if wallDetect.is_colliding():
					var collider = wallDetect.get_collider()
					if collider.name == "TileMap":
						cayotteCounter = 1
						if animatedSprite2D.flip_h:
							print("push")
							motion.x += 5000
						else:
							motion.x -= 5000
				elif jumpCounter < 1:
					cayotteCounter = 1
					jumpCounter += 1

		animation_handler()
		handle_movement_input(delta)

		if bow_mod():
			hook()
			queue_redraw()
			if hooked:
				swing(delta)
				motion += Vector2(0.975, 0.975)

		velocity = motion
		move_and_slide()
func giveDamage(damage):
	if ennemi_in_zone:
		ennemi.take_damage(damage)
func light_attack_handler():
	if not bowMod:
		AttackLCounter += 1
		if AttackLCounter > 3:
			AttackLCounter = 1
		match AttackLCounter:
			1:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackL1, true)
				animationTree.set(AttackL3, false)
				animationTree.set(AttackH1, false)
				animationTree.set(AttackH2, false)
				animationTree.set(AttackH3, false)

				if givedegalight.is_stopped():
					givedegalight.start(0.35)
				
				
			2:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackL2, true)
				animationTree.set(AttackL1, false)
				animationTree.set(AttackH1, false)
				animationTree.set(AttackH2, false)
				animationTree.set(AttackH3, false)

				if givedegalight.is_stopped():
					givedegalight.start(0.3)
			3:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackL3, true)
				animationTree.set(AttackL2, false)
				animationTree.set(AttackH1, false)
				animationTree.set(AttackH2, false)
				animationTree.set(AttackH3, false)

				if givedegalight.is_stopped():
					givedegalight.start(0.6)

func heavy_attack_handler():
	if not bowMod:
		AttackHCounter += 1
		if AttackHCounter > 3:
			AttackHCounter = 1
		match AttackHCounter:
			1:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackH1, true)
				animationTree.set(AttackH3, false)
				animationTree.set(AttackL1, false)
				animationTree.set(AttackL2, false)
				animationTree.set(AttackL3, false)
				if givedegalourd.is_stopped():
					givedegalourd.start(0.75)
			2:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackH2, true)
				animationTree.set(AttackH1, false)
				animationTree.set(AttackL1, false)
				animationTree.set(AttackL2, false)
				animationTree.set(AttackL3, false)
				if givedegalourd.is_stopped():
					givedegalourd.start(0.6)
			3:
				animationTree.set(idleLink, false)
				animationTree.set(runLink, false)
				animationTree.set(AttackH3, true)
				animationTree.set(AttackH2, false)
				animationTree.set(AttackL1, false)
				animationTree.set(AttackL2, false)
				animationTree.set(AttackL3, false)
				if givedegalourd.is_stopped():
					givedegalourd.start(0.85)

# Mouvement Handler
func handle_movement_input(delta):
	var left = "left"
	var right = "right"

	# Get direction from input: -1 for left, 1 for right, 0 for no input
	var direction = Input.get_action_strength(right) - Input.get_action_strength(left)

	# Mettez à jour la direction précédente
	previousDirection = direction
	# Use Mathf.Sign to handle direction more robustly
	if abs(direction) > 0:
		if Input.is_action_just_pressed("dash") and canDash:
			dashing = true
			canDash = false
			dashTimer.start()
			canDashTimer.start()

		animatedSprite2D.flip_h = direction < 0
		if dashing:
			gpuparticle.emitting = true
			animatedSprite2D.visible = false
			motion.x = direction * DASH_SPEED
		else:
			motion.x = acceleration * direction

		if direction > 0:
			wallDetect.rotation_degrees = 0.0
		else:
			wallDetect.rotation_degrees = 180.0

	else:
		# Smoothly decelerate to a stop using linear interpolation
		motion.x = lerp(motion.x, 0.0, 0.2)

# Fonction de Saut
func jump():
	motion.y = jumpVelocity * jumpForce
	animationTree.set(runLink, false)
	animationTree.set(idleLink, false)
	animationTree.set(isJump, true)
	animationTree.set(idleLink, true)

# Gravity Handler
func get_gravity() -> float:
	if motion.y < 0:
		return jumpGravity
	else:
		return fallGravity

func get_hooked() -> bool:
	return hooked

# Crochet
func hook():
	get_node("RayCast/RayCast2D").look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("RightClick"):
		HookPosition = get_hook_position()
		if HookPosition != Vector2.ZERO:
			hooked = true
			CurrentRopeLenght = global_position.distance_to(HookPosition)
	if Input.is_action_just_released("RightClick") and hooked:
		hooked = false

# Récupere la position du Crochet
func get_hook_position() -> Vector2:
	for rayCast2D in get_node("RayCast").get_children():
		if rayCast2D.is_colliding():
			return rayCast2D.get_collision_point()
	return Vector2.ZERO

# Fonction Balancement
func swing(delta):
	var radius = global_position - HookPosition
	if motion.length() < 0.01 or radius.length() < 10:
		return
	var angle = acos(radius.dot(motion) / (radius.length() * motion.length()))
	var rad = cos(angle) * motion.length()
	motion += radius.normalized() * -rad
	if global_position.distance_to(HookPosition) > CurrentRopeLenght:
		global_position = HookPosition + radius.normalized() * CurrentRopeLenght
	motion += (HookPosition - global_position).normalized() * 15000 * delta

func _on_dash_timer_timeout():
	dashing = false
	gpuparticle.emitting = false
	animatedSprite2D.visible = true

func _on_can_dash_timer_timeout():
	canDash = true

func bow_mod() -> bool:
	if Input.is_action_just_pressed("bowMod") and not bowMod:
		bowMod = true
	elif Input.is_action_just_pressed("bowMod") and bowMod:
		bowMod = false
	return bowMod



func _on_area_2d_body_entered(body):
	if body is CharacterBody2D and body != self:

		ennemi_in_zone = true
		ennemi = body


func _on_area_2d_body_exited(body):
	if body is CharacterBody2D and body != self:

		ennemi_in_zone = false





func _on_givedegatlourd_timeout():
	
	giveDamage(10)


func _on_givedegatlight_timeout():
	
	giveDamage(5)
