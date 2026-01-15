extends Node
## GameManager - Globaler Spielzustand
## Singleton für Spieler-Management, Punktestand und Rundenlogik

signal player_eliminated(player_id: int)
signal round_started()
signal round_ended(winner_id: int)

enum GameState { MENU, PLAYING, PAUSED, ROUND_END }

var current_state: GameState = GameState.MENU
var players: Array[Node] = []
var scores: Dictionary = {}  # player_id -> score
var current_round: int = 0
var max_rounds: int = 5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_player(player: Node) -> int:
	var player_id = players.size()
	players.append(player)
	scores[player_id] = 0
	return player_id

func unregister_player(player: Node) -> void:
	var idx = players.find(player)
	if idx != -1:
		players.remove_at(idx)

func start_game() -> void:
	current_state = GameState.PLAYING
	current_round = 1
	for id in scores.keys():
		scores[id] = 0
	round_started.emit()

func eliminate_player(player_id: int) -> void:
	player_eliminated.emit(player_id)

func add_score(player_id: int, points: int = 1) -> void:
	if scores.has(player_id):
		scores[player_id] += points

func get_score(player_id: int) -> int:
	return scores.get(player_id, 0)

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
