extends Node

# Déclaration de la variable globale
var url := "http://127.0.0.1:5001"
@onready var http_request = $HTTPRequest

func _ready():
	pass

# Fonction pour envoyer le score
func send_score(username, score):
	print(username)
	print(score)

	http_request.connect("request_completed", Callable(self, "_on_score_sent"))
	
	var data = {
		"username": username,
		"score": score
	}
	
	var json = JSON.new()
	var json_string = json.stringify(data)
	
	var headers = ["Content-Type: application/json"]
	
	http_request.request(url + "/add_score", headers, HTTPClient.METHOD_POST, json_string)

func _on_score_sent(result, response_code, headers, body):
	if response_code == 200:
		print("Score successfully sent!")
	else:
		print("Failed to send score. Response code: %d" % response_code)
