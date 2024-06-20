extends CanvasLayer

# Liste des textures
var textures = []
var current_texture_index = 0
var texturesweapon = []
var current_textureweapon_index = 0

# Référence au TextureRect
@onready var texture_rect = $PanelContainer/HBoxContainer/TextureRect

# Timer pour changer les textures
@onready var timer = $Timer

@onready var Chronolabel = $PanelContainer/HBoxContainer/HBoxContainer/Chronolabel
@onready var Chrono = $Chrono

@onready var Weapon = $PanelContainer2/TextureRect

# Drapeau pour vérifier si les yeux sont fermés
var eyes_closed = false
var chrono_time = 0

# Drapeau pour le mode Bow
var is_bowmode = false

func _ready():
	# Charger les textures
	textures.append(load("res://Assets/HUD/Group 8.png"))  # Yeux fermés
	textures.append(load("res://Assets/HUD/Group 19.png")) # Yeux ouverts
	
	texturesweapon.append(load("res://Assets/HUD/Group 20.png"))     
	texturesweapon.append(load("res://Assets/HUD/Group 15.png"))

	# Connecter le signal timeout du timer à la fonction _on_Timer_timeout
	timer.timeout.connect(_on_Timer_timeout)
	
	# Connecter le signal timeout du Chrono à la fonction _on_Chrono_timeout
	Chrono.timeout.connect(_on_Chrono_timeout)
	
	# Lancer le timer pour la première fois
	start_random_timer()

	# Définir le temps du Chrono et démarrer le Chrono
	Chrono.wait_time = 1.0 # par exemple, 1 seconde
	Chrono.start()
	
	is_bowmode = false
	
	# Vérifier l'état du bowMod
	update_weapon_texture()

func start_random_timer():
	if eyes_closed:
		# Si les yeux sont fermés, rouvrir après une courte période
		timer.wait_time = 0.1
	else:
		# Si les yeux sont ouverts, les fermer après un temps aléatoire entre 1 et 5 secondes
		var random_time = randi() % 4 + 1
		timer.wait_time = random_time
	
	timer.start()

func _on_Timer_timeout():
	if eyes_closed:
		# Ouvrir les yeux
		current_texture_index = 1
		eyes_closed = false
	else:
		# Fermer les yeux
		current_texture_index = 0
		eyes_closed = true
	
	texture_rect.texture = textures[current_texture_index]

	
	# Relancer le timer avec un temps approprié
	start_random_timer()

func _on_Chrono_timeout():
	# Augmenter la valeur du chrono_time
	chrono_time += 1

	# Calculer les minutes et secondes
	var minutes = chrono_time / 60
	var seconds = chrono_time % 60

	# Formater les secondes pour avoir toujours deux chiffres
	var seconds_str = str(seconds)
	if seconds < 10:
		seconds_str = "0" + seconds_str

	# Formater le texte du Chronolabel
	var formatted_time = str(minutes) + " : " + seconds_str

	# Mettre à jour le texte du Chronolabel
	Chronolabel.text = formatted_time

func update_weapon_texture():
	if is_bowmode:
		current_textureweapon_index = 1
	else:
		current_textureweapon_index = 0
	Weapon.texture = texturesweapon[current_textureweapon_index]

func _input(event):
	if event.is_action_pressed("bowMod"):
		is_bowmode = not is_bowmode
		update_weapon_texture()
