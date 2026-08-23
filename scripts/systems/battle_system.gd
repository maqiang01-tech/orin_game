class_name BattleSystem
extends RefCounted


const DAMAGE_TYPES: Array[String] = ["physical", "spirit"]


static func physical_damage(attacker: Dictionary, defender: Dictionary, multiplier: float = 1.0) -> int:
	return calculate_damage(attacker, defender, "physical", multiplier)


static func spirit_damage(attacker: Dictionary, defender: Dictionary, multiplier: float = 1.0) -> int:
	return calculate_damage(attacker, defender, "spirit", multiplier)


static func calculate_damage(attacker: Dictionary, defender: Dictionary, damage_type: String, multiplier: float = 1.0, critical: bool = false) -> int:
	var attacker_stats: Dictionary = attacker.get("stats", attacker)
	var defender_stats: Dictionary = defender.get("stats", defender)
	var attack_value: float = attacker_stats.get("attack" if damage_type == "physical" else "spirit", 0)
	var defense_value: float = defender_stats.get("defense" if damage_type == "physical" else "resistance", 0)
	var damage := attack_value * multiplier * (100.0 / (100.0 + defense_value))
	damage *= affinity_modifier(attacker.get("type", attacker.get("profession", "")), defender.get("type", ""))
	if critical:
		damage *= 1.8
	return maxi(1, roundi(damage))


static func affinity_modifier(attacker_type: String, defender_type: String) -> float:
	if (attacker_type == "physical" and defender_type == "灵能") or (attacker_type == "灵能" and defender_type == "异兽") or (attacker_type == "异兽" and defender_type == "物理"):
		return 1.3
	if (attacker_type == "火系" and defender_type == "水系") or (attacker_type == "水系" and defender_type == "火系"):
		return 1.3
	return 1.0


static func critical_rate(agility: float) -> float:
	return 5.0 + agility * 0.4


static func evasion_rate(agility: float) -> float:
	return 8.0 + agility * 0.3


static func hit_rate(target_agility: float) -> float:
	return maxf(70.0, 95.0 - evasion_rate(target_agility))


static func create_battle(player_survivor: Dictionary, beast: Dictionary) -> Dictionary:
	return {
		"player": player_survivor.duplicate(true),
		"enemy": beast.duplicate(true),
		"round": 1,
		"log": []
	}


static func player_basic_attack(battle: Dictionary) -> Dictionary:
	var damage := physical_damage(battle["player"], battle["enemy"])
	battle["enemy"]["hp"] = maxi(0, battle["enemy"]["hp"] - damage)
	battle["log"].append({"type": "damage", "value": damage})
	return battle