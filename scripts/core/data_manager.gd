extends Node

var survivors: Dictionary = {}
var beasts: Dictionary = {}
var partners: Array = []
var skills: Dictionary = {}
var chapters: Array = []
var events: Array = []
var endings: Dictionary = {}
var exploration_routes: Array = []
var region_data: Dictionary = {}
var beast_assets: Dictionary = {}
var beast_codex: Dictionary = {}
var character_assets: Dictionary = {}
var dungeon_types: Array = []
var bosses: Array = []
var exploration_events: Array = []
var equipment: Dictionary = {}  # id -> equipment dict
var main_story: Dictionary = {}  # id -> 48章主线配置
var act_01_story: Dictionary = {}  # 第一篇章详细剧情剧本（8章）
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

	var region_raw_data: Variant = load_json_file("res://data/configs/region_data.json")
	if region_raw_data is Dictionary:
		region_data = region_raw_data

	var beast_asset_data: Variant = load_json_file("res://data/configs/beast_assets.json")
	if beast_asset_data is Dictionary:
		beast_assets = beast_asset_data

	var beast_codex_data: Variant = load_json_file("res://data/configs/beast_codex.json")
	if beast_codex_data is Dictionary:
		beast_codex = beast_codex_data

	var character_asset_data: Variant = load_json_file("res://data/configs/character_assets.json")
	if character_asset_data is Dictionary:
		character_assets = character_asset_data

	var dungeon_raw_data: Variant = load_json_file("res://data/configs/dungeon_types.json")
	if dungeon_raw_data is Dictionary and dungeon_raw_data.get("dungeon_types") is Array:
		dungeon_types = dungeon_raw_data["dungeon_types"]

	var boss_raw_data: Variant = load_json_file("res://data/configs/bosses.json")
	if boss_raw_data is Dictionary and boss_raw_data.get("bosses") is Array:
		bosses = boss_raw_data["bosses"]

	var exploration_event_data: Variant = load_json_file("res://data/configs/exploration_events.json")
	if exploration_event_data is Dictionary and exploration_event_data.get("events") is Array:
		exploration_events = exploration_event_data["events"]

	# 加载装备配置（武器/防具/饰品）
	var equipment_data: Variant = load_json_file("res://data/configs/equipment.json")
	if equipment_data is Dictionary:
		for slot in equipment_data:
			var slot_items: Array = equipment_data[slot]
			for item in slot_items:
				if item is Dictionary and item.has("id"):
					equipment[item["id"]] = item

	# 加载轮回主线配置（48章/6幕/Boss情报/轮回词缀等）
	var story_data: Variant = load_json_file("res://data/configs/main_story_config.json")
	if story_data is Dictionary:
		main_story = story_data

	# 加载第一篇章详细剧情剧本（8章剧本/地图节点/教学/Boss详细数据/轮回继承）
	var act_01_data: Variant = load_json_file("res://data/configs/act_01_story.json")
	if act_01_data is Dictionary:
		act_01_story = act_01_data

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


func get_equipment_by_id(item_id: String) -> Dictionary:
	return equipment.get(item_id, {})


func get_all_equipment() -> Array:
	var result: Array = []
	for item_id in equipment:
		result.append(equipment[item_id])
	return result


func get_all_equipment_by_slot(slot: String) -> Array:
	var result: Array = []
	for item_id in equipment:
		var item: Dictionary = equipment[item_id]
		if item.get("slot", "") == slot:
			result.append(item)
	return result


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
