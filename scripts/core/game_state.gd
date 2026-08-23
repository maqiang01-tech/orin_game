extends Node

var player: PlayerData


func _ready() -> void:
    player = PlayerData.new()
    ensure_initial_survivors()
    print("GameState initialized for ", player.player_name)


func ensure_initial_survivors() -> void:
    DataManager.ensure_loaded()
    if player == null:
        player = PlayerData.new()

    var starter_ids := ["player_chenmo", "lin_mei"]
    for partner in DataManager.partners:
        if partner.get("id", "") not in starter_ids:
            continue

        var already_owned := false
        for survivor in player.survivors:
            if survivor.get("id", "") == partner.get("id", ""):
                already_owned = true
                break

        if not already_owned:
            player.survivors.append(partner.duplicate(true))


func explore() -> void:
    if player.supplies.get("food", 0) <= 0:
        return
    player.add_resource("food", -1)
    player.advance_half_day()
