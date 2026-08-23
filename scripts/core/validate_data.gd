extends Node

const SURVIVOR_FIELDS: Array[String] = ["id", "name", "profession", "level", "stats"]
const BEAST_FIELDS: Array[String] = ["id", "name", "type", "level", "hp", "attack", "defense"]
const PARTNER_FIELDS: Array[String] = ["id", "name", "profession", "rarity", "star", "level", "stats"]


func validate_all() -> bool:
    var success := validate_config("res://data/configs/survivors.json", SURVIVOR_FIELDS, "survivor")
    success = validate_config("res://data/configs/beasts.json", BEAST_FIELDS, "beast") and success
    success = validate_array_config("res://data/configs/partners.json", PARTNER_FIELDS, "partner") and success
    return success


func validate_array_config(path: String, required_fields: Array[String], kind: String) -> bool:
    var data: Variant = DataManager.load_json_file(path)
    if not data is Array:
        push_error("%s config root must be an Array: %s" % [kind, path])
        return false

    var success := true
    for entry: Variant in data:
        if not entry is Dictionary:
            push_error("%s entry must be a Dictionary" % kind)
            success = false
            continue
        for field in required_fields:
            if not entry.has(field):
                push_error("%s '%s' missing field: %s" % [kind, entry.get("id", "?"), field])
                success = false
    return success


func validate_config(path: String, required_fields: Array[String], kind: String) -> bool:
    var data: Variant = DataManager.load_json_file(path)
    if not data is Dictionary:
        push_error("%s config root must be a Dictionary: %s" % [kind, path])
        return false

    var success := true
    for entry_id: Variant in data:
        var entry: Variant = data[entry_id]
        if not entry is Dictionary:
            push_error("%s '%s' must be a Dictionary" % [kind, entry_id])
            success = false
            continue
        for field in required_fields:
            if not entry.has(field):
                push_error("%s '%s' missing field: %s" % [kind, entry_id, field])
                success = false
        if entry.get("id", "") != entry_id:
            push_error("%s key '%s' does not match id" % [kind, entry_id])
            success = false
    return success
