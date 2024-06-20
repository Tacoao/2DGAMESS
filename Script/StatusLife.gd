extends Node2D

@export var perso : CharacterBody2D
@onready var sprite1 =$StatusLife1
@onready var sprite2=$StatusLife2
@onready var sprite3=$StatusLife3
@onready var cam = $"../../../Camera2D"
@onready var animationPlayer = $StatusAnimationPlayer
@onready var animationTree = $StatusAnimationTree
@onready var audioSound = $"../../../CharacterBody2D/Murmure"
var sprites = [
	preload("res://Assets/MainCHar/ScreenStateLife/State1.png"),
	preload("res://Assets/MainCHar/ScreenStateLife/State2.png"),
	preload("res://Assets/MainCHar/ScreenStateLife/State3.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite1.modulate.a = 0.0
	sprite2.modulate.a = 0.0
	sprite3.modulate.a = 0.0 # reduit l'opaciter a 0pourcent
	
func takedamage(damage):
	perso.take_damage(damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite1.global_position = cam.global_position;
	sprite2.global_position = cam.global_position;
	sprite3.global_position = cam.global_position;
	if perso.life <= 80:
		animationTree.set("parameters/conditions/isState3",false)
		animationTree.set("parameters/conditions/isState2",false)
		animationTree.set("parameters/conditions/isStateFine",false)
		animationTree.set("parameters/conditions/isState1",true)
		audioSound.volume_db = -30.0
		if audioSound.playing == false:
			audioSound.play()
		
	else:
		animationTree.set("parameters/conditions/isState1",false)
		animationTree.set("parameters/conditions/isStateFine",true)
		if audioSound.playing == true:
			audioSound.stop()
	if  perso.life <= 50 :
		animationTree.set("parameters/conditions/isState1",false)
		animationTree.set("parameters/conditions/isState2",true)
		audioSound.volume_db = -20.0
	if perso.life <= 30:
		animationTree.set("parameters/conditions/isState2",false)
		animationTree.set("parameters/conditions/isState3",true)
		audioSound.volume_db = -10.0
