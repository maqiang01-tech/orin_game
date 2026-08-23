extends Node

var survivors: Dictionary = {}
var beasts: Dictionary = {}
var partners: Array = []
var skills: Dictionary = {}
var chapters: Array = []
var events: Array = []
var endings: Dictionary = {}
var exploration_routes: Array = []
var configs_loaded: bool = false


func _ready() -> void:
	ensure_loaded()


func ensure_loaded() -> void:
	if configs_loaded:
		return

	print("DataManager initialized")

	_load_config("survivors", "res://data/configs/survivors.json")
	_load_config("beasts", "res://data/configs/beasts.json")
	_load_array_config("partners", "res://data/configs/partners.json")
	_load_config("skills", "res://data/configs/skills.json")
	_load_array_config("events", "res://data/configs/events.json")
	_load_config("endings", "res://data/configs/endings.json")

	var chapter_data: Variant = load_json_file("res://data/configs/chapters.json")
	if chapter_data is Array:
		chapters = chapter_data

	var route_data: Variant = load_json_file("res://data/configs/exploration_routes.json")
	if route_data is Array:
		exploration_routes = route_data

	configs_loaded = true
	print("Loaded survivors: ", survivors.size(), " / beasts: ", beasts.size(), " / routes: ", exploration_routes.size())


func _load_config(target: String, path: String) -> void:
	var raw_data: Variant = load_json_file(path)
	if raw_data is Dictionary:
		var data: Dictionary = raw_data
		set(target, data)


func _load_array_config(target: String, path: String) -> void:
	var raw_data: Variant = load_json_file(path)
	if raw_data is Array:
		var data: Array = raw_data
		set(target, data)


func load_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: " + path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + path)
		return null

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(text)
	if error != OK:
		push_error(
            "JSON parse error: %s, line: %d"
			% [json.get_error_message(), json.get_error_line()]
		)
		return null

	return json.data
