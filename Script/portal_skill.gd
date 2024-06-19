extends Node2D

@export var playerlife : Node2D
@export var player :CharacterBody2D
@onready var takeDamageTimer = $takeDamage
var IsIn = false


func _on_timer_timeout():
	queue_free()

func _process(delta):
	
	if takeDamageTimer.is_stopped():
		takeDamageTimer.start(0.8)
		
func _on_area_2d_body_entered(body):
	if body == player:
		IsIn = true
		
		


func _on_take_damage_timeout():
	if IsIn:
		playerlife.takedamage(5)


func _on_area_2d_body_exited(body):
	if body == player :
		IsIn = false
