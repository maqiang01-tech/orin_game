extends SceneTree

const TEST_SAVE_PATH := "user://integrity_save_test.json"
const TEST_SAVE_BACKUP_PATH := "user://integrity_save_test.json.bak"
const TEST_SAVE_TEMP_PATH := "user://integrity_save_test.json.tmp"
const LEGACY_SAVE_PATH := "user://integrity_legacy_test.json"

var failures: Array[String] = []
var data_manager: Node
var save_manager: Node
var game_state: Node


func _initialize() -> void:
	await process_frame
	data_manager = root.get_node_or_null("/root/DataManager")
	save_manager = root.get_node_or_null("/root/SaveManager")
	game_state = root.get_node_or_null("/root/GameState")
	if data_manager == null:
		_fail("DataManager autoload is not available.")
	if save_manager == null:
		_fail("SaveManager autoload is not available.")
	if game_state == null:
		_fail("GameState autoload is not available.")
	if not failures.is_empty():
		_finish()
		return

	data_manager.call("ensure_loaded")
	_check_main_scene()
	await _check_main_scene_instantiates()
	_check_data_configs()
	_check_balance_rules()
	_check_five_person_boundaries()
	_check_save_manager()
	_check_battle_rng_determinism()
	_cleanup_test_files()
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("PROJECT_INTEGRITY_PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _check_main_scene() -> void:
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene != "res://scenes/main/main.tscn":
		_fail("Main scene must remain res://scenes/main/main.tscn, got: " + main_scene)
	if not ResourceLoader.exists(main_scene):
		_fail("Main scene resource does not exist: " + main_scene)


func _check_main_scene_instantiates() -> void:
	var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
	if packed_scene == null:
		_fail("Main scene could not be loaded as PackedScene.")
		return
	var scene := packed_scene.instantiate()
	if scene == null:
		_fail("Main scene could not be instantiated.")
		return
	root.add_child(scene)
	await process_frame
	await process_frame
	if scene.get_script() == null:
		_fail("Main scene script did not load.")
	scene.queue_free()


func _check_data_configs() -> void:
	_validate_dictionary_config("res://data/configs/survivors.json", ["id", "name", "profession", "level", "stats"], "survivor")
	_validate_dictionary_config("res://data/configs/beasts.json", ["id", "name", "type", "level", "hp", "attack", "defense"], "beast")
	_validate_array_config("res://data/configs/partners.json", ["id", "name", "profession", "rarity", "star", "level", "stats"], "partner")
	if data_manager.get("partners").size() < 5:
		_fail("Full project requires at least five configured partners.")
	var main_story: Dictionary = data_manager.get("main_story")
	if main_story.get("total_chapters", 0) != 48:
		_fail("main_story_config total_chapters must be 48.")


func _check_balance_rules() -> void:
	var rules: Dictionary = data_manager.get("balance_rules")
	if rules.is_empty():
		_fail("balance_rules.json was not loaded.")
		return
	if int(rules.get("schema_version", 0)) < 1:
		_fail("balance_rules schema_version must be >= 1.")
	var battle: Dictionary = rules.get("battle", {})
	var progression: Dictionary = rules.get("progression", {})
	if int(battle.get("max_party_size", 0)) != 5:
		_fail("battle.max_party_size must be 5.")
	if str(battle.get("basic_attack_id", "")) != "skill_basic_shot":
		_fail("battle.basic_attack_id must be skill_basic_shot.")
	if int(progression.get("total_chapters", 0)) != 48:
		_fail("progression.total_chapters must be 48.")
	if int(progression.get("formation_grid_size", 0)) != 9:
		_fail("progression.formation_grid_size must be 9.")


func _check_five_person_boundaries() -> void:
	var player: Variant = game_state.get("player")
	if player == null:
		_fail("GameState.player is not available.")
		return
	var ids: Array[String] = []
	for partner in data_manager.get("partners"):
		if partner is Dictionary:
			ids.append(str(partner.get("id", "")))
		if ids.size() >= 6:
			break
	for i in range(mini(5, ids.size())):
		if not bool(player.call("place_survivor_on_grid", ids[i], i)):
			_fail("Could not place survivor on formation grid: " + ids[i])
	if ids.size() >= 6 and bool(player.call("place_survivor_on_grid", ids[5], 5)):
		_fail("Formation accepted a sixth active survivor.")


func _check_save_manager() -> void:
	_cleanup_test_files()
	var payload := {"player_name": "测试", "day": 3, "story_flags": {"legacy_ok": true}}
	save_manager.call("_write_json", TEST_SAVE_PATH, save_manager.call("_wrap_save_payload", "integrity", payload))
	var loaded: Dictionary = save_manager.call("_read_json", TEST_SAVE_PATH)
	if loaded.get("player_name", "") != "测试" or int(loaded.get("day", 0)) != 3:
		_fail("Versioned save payload did not round-trip.")
	var metadata: Dictionary = save_manager.call("get_save_metadata", TEST_SAVE_PATH)
	if int(metadata.get("save_version", 0)) != int(save_manager.call("get_save_version")):
		_fail("Save metadata version mismatch.")

	save_manager.call("_write_json", TEST_SAVE_PATH, save_manager.call("_wrap_save_payload", "integrity", {"day": 4}))
	if not FileAccess.file_exists(TEST_SAVE_BACKUP_PATH):
		_fail("Save backup was not created when replacing an existing save.")
	var corrupt_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	if corrupt_file == null:
		_fail("Could not corrupt primary save fixture.")
	else:
		corrupt_file.store_string("{broken")
		corrupt_file.close()
	var fallback: Dictionary = save_manager.call("_read_json", TEST_SAVE_PATH)
	if int(fallback.get("day", 0)) != 3:
		_fail("Corrupted primary save did not fall back to backup data.")

	var file := FileAccess.open(LEGACY_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_fail("Could not create legacy save fixture.")
	else:
		file.store_string(JSON.stringify({"player_name": "旧存档", "day": 7, "save_version": 999}))
		file.close()
	var legacy: Dictionary = save_manager.call("_read_json", LEGACY_SAVE_PATH)
	if legacy.get("player_name", "") != "旧存档" or int(legacy.get("day", 0)) != 7:
		_fail("Legacy save did not load through migration path.")
	if legacy.has("save_version"):
		_fail("Legacy migration should not expose wrapper metadata as player data.")


func _check_battle_rng_determinism() -> void:
	var partners: Array = data_manager.get("partners")
	var beasts: Dictionary = data_manager.get("beasts")
	if partners.is_empty() or beasts.is_empty():
		_fail("Cannot run battle determinism check without partners and beasts.")
		return
	var party := [partners[0].duplicate(true)]
	var enemy_id := str(beasts.keys()[0])
	var enemies := [beasts[enemy_id].duplicate(true)]
	var battle_script: GDScript = load("res://scripts/systems/battle_system.gd")
	if battle_script == null:
		_fail("BattleSystem script could not be loaded.")
		return
	var battle_api: Object = battle_script.new()
	var battle_a: Dictionary = battle_api.call("create_battle", party.duplicate(true), enemies.duplicate(true), {}, [0], 12345)
	var battle_b: Dictionary = battle_api.call("create_battle", party.duplicate(true), enemies.duplicate(true), {}, [0], 12345)
	var actor_a := str(battle_api.call("get_current_actor", battle_a))
	var actor_b := str(battle_api.call("get_current_actor", battle_b))
	if actor_a != actor_b:
		_fail("Seeded battle produced different first actors.")
		return
	var target_a: String = str(battle_api.call("get_alive_team_units", battle_a, "enemy")[0])
	var target_b: String = str(battle_api.call("get_alive_team_units", battle_b, "enemy")[0])
	battle_api.call("perform_action", battle_a, actor_a, "attack", [target_a])
	battle_api.call("perform_action", battle_b, actor_b, "attack", [target_b])
	if JSON.stringify(battle_a.get("log", [])) != JSON.stringify(battle_b.get("log", [])):
		_fail("Seeded battle logs diverged.")
	var unit_a: Dictionary = battle_a["units"][target_a]
	var unit_b: Dictionary = battle_b["units"][target_b]
	if absf(float(unit_a.get("hp", 0.0)) - float(unit_b.get("hp", 0.0))) > 0.001:
		_fail("Seeded battle target HP diverged.")


func _cleanup_test_files() -> void:
	for path in [TEST_SAVE_PATH, TEST_SAVE_BACKUP_PATH, TEST_SAVE_TEMP_PATH, LEGACY_SAVE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	failures.append(message)


func _validate_dictionary_config(path: String, required_fields: Array, kind: String) -> void:
	var data: Variant = data_manager.call("load_json_file", path)
	if not (data is Dictionary):
		_fail("%s config root must be a Dictionary: %s" % [kind, path])
		return
	for entry_id in data:
		var entry: Variant = data[entry_id]
		if not (entry is Dictionary):
			_fail("%s '%s' must be a Dictionary" % [kind, entry_id])
			continue
		for field in required_fields:
			if not entry.has(field):
				_fail("%s '%s' missing field: %s" % [kind, entry_id, field])
		if str(entry.get("id", "")) != str(entry_id):
			_fail("%s key '%s' does not match id" % [kind, entry_id])


func _validate_array_config(path: String, required_fields: Array, kind: String) -> void:
	var data: Variant = data_manager.call("load_json_file", path)
	if not (data is Array):
		_fail("%s config root must be an Array: %s" % [kind, path])
		return
	for entry in data:
		if not (entry is Dictionary):
			_fail("%s entry must be a Dictionary" % kind)
			continue
		for field in required_fields:
			if not entry.has(field):
				_fail("%s '%s' missing field: %s" % [kind, entry.get("id", "?"), field])
