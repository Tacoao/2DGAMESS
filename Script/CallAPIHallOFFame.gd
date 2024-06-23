extends Node

# Déclaration de la variable globale


var url := "http://127.0.0.1:5001"

func _ready():
	get_top_scores()

func get_top_scores():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	http_request.request(url + "/top_scores")

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var scores = json.get_data()
			if typeof(scores) == TYPE_ARRAY:
				# Trier les scores par ordre décroissant
				scores.sort_custom(Callable(self, "_compare_scores"))
				# Prendre les trois premiers
				var top_scores = scores.slice(0, 3)
				VariableGlobale.bestsUser.clear() # Vider la variable globale avant d'ajouter les nouveaux scores
				# Ajouter les trois meilleurs à la variable globale
				for score in top_scores:
					VariableGlobale.bestsUser.append({"username": score["username"], "score": score["score"]})
				print(VariableGlobale.bestsUser)
			else:
				print("Expected an array but got: %s" % typeof(scores))

# Fonction de comparaison personnalisée pour trier les scores
func _compare_scores(a, b):
	return int(b["score"]) - int(a["score"])
