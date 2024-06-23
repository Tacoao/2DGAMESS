extends Node2D

@onready var GOLDNAME = $StaticElements/GOLDNAME
@onready var GOLDTIME = $StaticElements/GOLDTIME
@onready var SILVERNAME = $StaticElements/SILVERNAME
@onready var SILVERTIME = $StaticElements/SILVERTIME
@onready var BRONZENAME = $StaticElements/BRONZENAME
@onready var BRONZETIME = $StaticElements/BRONZETIME

@onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	timer.wait_time = 2.0 # Attendre 2 secondes avant de regarder dans bestsUser
	timer.one_shot = true
	timer.start()

	print(VariableGlobale.bestsUser)

func _on_timeout():
	set_best_scores()

func set_best_scores():
	if VariableGlobale.bestsUser.size() >= 1:
		GOLDNAME.text = VariableGlobale.bestsUser[0]["username"]
		GOLDTIME.text = format_time(VariableGlobale.bestsUser[0]["score"])
	if VariableGlobale.bestsUser.size() >= 2:
		SILVERNAME.text = VariableGlobale.bestsUser[1]["username"]
		SILVERTIME.text = format_time(VariableGlobale.bestsUser[1]["score"])
	if VariableGlobale.bestsUser.size() >= 3:
		BRONZENAME.text = VariableGlobale.bestsUser[2]["username"]
		BRONZETIME.text = format_time(VariableGlobale.bestsUser[2]["score"])

func format_time(seconds):
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
