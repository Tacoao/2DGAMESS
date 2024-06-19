extends TextureRect

# Chemins vers les textures que vous voulez utiliser
var textures = [
	preload("res://.godot/imported/Group 19.png-2dca9ed496e15f760e4cd1e05c9d8ffc.ctex"),
	preload("res://.godot/imported/Group 8.png-f65753fe9983e91fd74f70410e86529d.ctex"),

]

func _ready():
	randomize_texture()

func randomize_texture():
	while true:
		# Choisir une texture aléatoire de la liste
		texture = textures[randi() % textures.size()]
		# Définir le prochain changement de texture
		var next_change = randf_range(1.0, 5.0)
		# Créer un Timer pour le délai
		var timer = Timer.new()
		timer.wait_time = next_change
		timer.one_shot = true
		timer.autostart = true
		add_child(timer)
		# Attendre que le Timer signale `timeout`
		await timer.timeout
		timer.queue_free()  # Libérer le timer de la mémoire après usage
