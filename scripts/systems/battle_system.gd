class_name BattleSystem
extends RefCounted

# ============================================================
# 异变纪元：幸存者编队 - DTB速度回合制战斗系统
#
# 战斗模式：所有单位按速度从高到低依次行动
# 同速判定：玩家方优先 → 按站位顺序（前排→后排，左→右）
# 核心属性：HP / EP(能量) / ATK / SPI / DEF / RES / SPD
# 伤害公式：
#   物理伤害 = 攻击力 × 技能倍率 × (100 / (100 + 防御力))
#   灵能伤害 = 灵能 × 技能倍率 × (100 / (100 + 灵能抗性))
# 属性克制：攻击类型命中目标弱点 +30%
# 暴击率 = 5% + 速度 × 0.3%，暴击伤害 = 基础伤害 × 1.8
# 能量机制：每回合恢复 20% EP
# 状态效果：灼烧/冰冻/中毒/混乱/护盾/嘲讽/加速/减速/攻击提升/防御提升
# 操作模式：手动/半自动/全自动
# ============================================================

const STATUS_NAMES: Dictionary = {
	"burn": "灼烧",
	"freeze": "冰冻",
	"poison": "中毒",
	"confusion": "混乱",
	"shield": "护盾",
	"taunt": "嘲讽",
	"speed_up": "加速",
	"speed_down": "减速",
	"attack_up": "攻击提升",
	"defense_up": "防御提升"
}

const STATUS_DESCRIPTIONS: Dictionary = {
	"burn": "每回合损失HP×5%，持续3回合",
	"freeze": "速度-30%，持续2回合",
	"poison": "每回合损失HP×3%，持续3回合",
	"confusion": "无法控制，随机攻击，持续2回合",
	"shield": "吸收伤害",
	"taunt": "强制敌人攻击自己",
	"speed_up": "速度提升",
	"speed_down": "速度降低",
	"attack_up": "攻击提升",
	"defense_up": "防御提升"
}

# 站位行加成（V3.0）: 0=前排 1=中排 2=后排
# 前排: 受击概率+30% / DEF+10% / 近战伤害+5%
# 中排: ATK+5% / SPI+5%
# 后排: 受近战伤害-15% / 治疗+10% / 辅助+10%
const POSITION_BONUS: Dictionary = {
	0: {"incoming": 0.30, "defense": 0.10, "melee": 0.05},
	1: {"attack": 0.05, "spirit": 0.05},
	2: {"incoming_melee": -0.15, "heal": 0.10, "support": 0.10}
}

const MAX_PARTY_SIZE: int = 5
const BASIC_ATTACK_ID: String = "skill_basic_shot"
const GUARD_DAMAGE_REDUCTION: float = 0.5
const GUARD_DEFENSE_BONUS: float = 0.30
const ENERGY_REGEN_PERCENT: float = 0.20
const CHARGE_MULTIPLIER: float = 2.5
const RESOURCE_REWARD_KEYS: Array[String] = ["food", "medicine", "cores", "memory_shards", "tickets", "spirit_battery", "ammo", "rare_material", "spirit_core"]
const DAMAGE_TYPE_LABELS: Dictionary = {
	"physical": "物理",
	"spirit": "灵能"
}


# ============================================================
# 创建战斗
# party: Array[Dictionary] 玩家出战伙伴（最多5人）
# enemies: Array[Dictionary] 敌方异兽
# formation_bonus: Dictionary 阵型加成 {attack, defense, speed}
# grid_indices: Array[int] 每个玩家对应的九宫格位置
# ============================================================
static func create_battle(
	party: Array,
	enemies: Array,
	formation_bonus: Dictionary = {},
	grid_indices: Array = []
) -> Dictionary:
	var battle: Dictionary = {
		"round": 1,
		"units": {},
		"turn_order": [],
		"turn_index": 0,
		"log": [],
		"mode": "manual",
		"formation_bonus": formation_bonus,
		"battle_over": false,
		"victory": false,
		"rewards": {},
		"result_applied": false,
		"player_party": [],
		"enemy_party": []
	}

	# 添加玩家单位
	for i in range(party.size()):
		var survivor: Dictionary = party[i]
		var grid_index: int = grid_indices[i] if i < grid_indices.size() else i
		var row: int = _grid_index_to_row(grid_index)
		var unit := _build_player_unit(survivor, formation_bonus, row)
		battle["units"][unit["id"]] = unit
		battle["player_party"].append(unit["id"])

	# 添加敌人单位
	for i in range(enemies.size()):
		var beast: Dictionary = enemies[i]
		var unit := _build_enemy_unit(beast, i)
		battle["units"][unit["id"]] = unit
		battle["enemy_party"].append(unit["id"])

	# 计算行动顺序
	battle["turn_order"] = _build_turn_order(battle)

	_add_log(battle, "⚔️ 战斗开始！")
	_add_log(battle, "队伍：%s" % _format_party_names(battle["player_party"], battle["units"]))
	_add_log(battle, "敌人：%s" % _format_party_names(battle["enemy_party"], battle["units"]))

	return battle


static func create_battle_from_encounter(
	party: Array,
	encounter: Dictionary,
	formation_bonus: Dictionary = {},
	grid_indices: Array = []
) -> Dictionary:
	var enemies: Array = []
	for enemy_ref in encounter.get("enemies", []):
		var enemy_id := str(enemy_ref.get("id", "")) if enemy_ref is Dictionary else str(enemy_ref)
		if enemy_id == "" or not DataManager.beasts.has(enemy_id):
			continue
		var enemy: Dictionary = DataManager.beasts[enemy_id].duplicate(true)
		if enemy_ref is Dictionary:
			for key in enemy_ref:
				if key != "id":
					enemy[key] = enemy_ref[key]
		enemies.append(enemy)
	if enemies.is_empty():
		var fallback_id := str(encounter.get("beast_id", ""))
		if fallback_id != "" and DataManager.beasts.has(fallback_id):
			enemies.append(DataManager.beasts[fallback_id].duplicate(true))
	var battle := create_battle(party, enemies, formation_bonus, grid_indices)
	battle["encounter_id"] = str(encounter.get("id", ""))
	battle["stage_id"] = str(encounter.get("stage", ""))
	battle["encounter_rewards"] = encounter.get("rewards", {})
	return battle


static func _grid_index_to_row(grid_index: int) -> int:
	if grid_index >= 0 and grid_index <= 2:
		return 0
	if grid_index >= 3 and grid_index <= 5:
		return 1
	return 2


static func _build_player_unit(survivor: Dictionary, formation_bonus: Dictionary, row: int) -> Dictionary:
	var stats: Dictionary = survivor.get("stats", {})
	var base_stats := {
		"attack": float(stats.get("attack", 10)),
		"defense": float(stats.get("defense", 10)),
		"spirit": float(stats.get("spirit", 10)),
		"resistance": float(stats.get("resistance", 10)),
		"speed": float(stats.get("speed", 10))
	}

	# 阵型加成（V3.0：attack/spirit/defense/resistance/speed/ep_start）
	var formation_attack: float = float(formation_bonus.get("attack", 0.0))
	var formation_spirit: float = float(formation_bonus.get("spirit", 0.0))
	var formation_defense: float = float(formation_bonus.get("defense", 0.0))
	var formation_resistance: float = float(formation_bonus.get("resistance", 0.0))
	var formation_speed: float = float(formation_bonus.get("speed", 0.0))
	var formation_ep_start: float = float(formation_bonus.get("ep_start", 0.0))

	# 站位加成（前排/中排/后排）
	var position: Dictionary = POSITION_BONUS.get(row, {})
	var position_attack: float = float(position.get("attack", 0.0))
	var position_spirit: float = float(position.get("spirit", 0.0))
	var position_defense: float = float(position.get("defense", 0.0))
	var position_resistance: float = float(position.get("resistance", 0.0))

	var computed_stats := {
		"attack": base_stats["attack"] * (1.0 + formation_attack + position_attack),
		"defense": base_stats["defense"] * (1.0 + formation_defense + position_defense),
		"spirit": base_stats["spirit"] * (1.0 + formation_spirit + position_spirit),
		"resistance": base_stats["resistance"] * (1.0 + formation_resistance + position_resistance),
		"speed": base_stats["speed"] * (1.0 + formation_speed)
	}

	# 疾风阵：首回合 EP +20%
	var base_max_energy: float = float(survivor.get("max_energy", survivor.get("energy", 100)))
	var base_energy: float = float(survivor.get("energy", survivor.get("max_energy", 100)))
	var start_energy: float = base_energy
	if formation_ep_start > 0.0:
		start_energy = minf(base_max_energy, base_energy + base_max_energy * formation_ep_start)

	# 技能列表
	var skill_ids: Array[String] = []
	if survivor.has("initial_skills"):
		for ref in survivor["initial_skills"]:
			var skill_id: String = ref.get("id", "") if ref is Dictionary else str(ref)
			if skill_id != "":
				skill_ids.append(skill_id)
	elif survivor.has("skills"):
		for ref in survivor["skills"]:
			var skill_id: String = ref.get("id", "") if ref is Dictionary else str(ref)
			if skill_id != "":
				skill_ids.append(skill_id)

	return {
		"id": "player_" + str(survivor.get("id", "")),
		"base_id": str(survivor.get("id", "")),
		"name": str(survivor.get("name", "伙伴")),
		"team": "player",
		"row": row,
		"position_bonus": position,
		"type": str(survivor.get("profession", "")),
		"level": int(survivor.get("level", 1)),
		"hp": float(survivor.get("hp", survivor.get("max_hp", 100))),
		"max_hp": float(survivor.get("max_hp", survivor.get("hp", 100))),
		"energy": start_energy,
		"max_energy": float(survivor.get("max_energy", survivor.get("energy", 100))),
		"base_stats": base_stats,
		"stats": computed_stats,
		"skills": skill_ids,
		"cooldowns": {},
		"ultimate_used": false,
		"charging": "",
		"guard": false,
		"statuses": {},
		"defeated": false,
		"base_id_ref": survivor
	}


static func _build_enemy_unit(beast: Dictionary, index: int) -> Dictionary:
	var base_stats := {
		"attack": float(beast.get("attack", 10)),
		"defense": float(beast.get("defense", 10)),
		"spirit": float(beast.get("spirit", 10)),
		"resistance": float(beast.get("resistance", 10)),
		"speed": float(beast.get("speed", 10))
	}

	return {
		"id": "enemy_" + str(beast.get("id", "")) + "_" + str(index),
		"base_id": str(beast.get("id", "")),
		"name": str(beast.get("name", "异兽")),
		"team": "enemy",
		"row": 0,
		"type": str(beast.get("type", "普通")),
		"level": int(beast.get("level", 1)),
		"hp": float(beast.get("hp", 100)),
		"max_hp": float(beast.get("max_hp", beast.get("hp", 100))),
		"energy": 100.0,
		"max_energy": 100.0,
		"base_stats": base_stats,
		"stats": base_stats.duplicate(),
		"skills": [],
		"cooldowns": {},
		"ultimate_used": false,
		"charging": "",
		"guard": false,
		"statuses": {},
		"defeated": false,
		"weakness": beast.get("weakness", []),
		"affixes": beast.get("affixes", []),
		"base_id_ref": beast
	}


# ============================================================
# 行动顺序
# ============================================================
static func _build_turn_order(battle: Dictionary) -> Array:
	var units: Dictionary = battle["units"]
	var alive_ids: Array = []
	for unit_id in units:
		var unit: Dictionary = units[unit_id]
		if not unit.get("defeated", false):
			alive_ids.append(unit_id)

	# 按速度排序（降序）
	# 同速：玩家优先 → 站位行(前排0>中排1>后排2) → 站位列(左>右)
	var sorted: Array = alive_ids.duplicate()
	sorted.sort_custom(func(a: String, b: String) -> bool:
		var unit_a: Dictionary = units[a]
		var unit_b: Dictionary = units[b]
		var speed_a := _get_unit_speed(battle, a)
		var speed_b := _get_unit_speed(battle, b)
		if absf(speed_a - speed_b) > 0.01:
			return speed_a > speed_b
		# 同速判定
		if unit_a["team"] != unit_b["team"]:
			return unit_a["team"] == "player"
		if unit_a["row"] != unit_b["row"]:
			return int(unit_a["row"]) < int(unit_b["row"])
		return str(unit_a["id"]) < str(unit_b["id"])
	)
	return sorted


static func _get_unit_speed(battle: Dictionary, unit_id: String) -> float:
	var unit: Dictionary = battle["units"][unit_id]
	var base_speed: float = float(unit["stats"].get("speed", 10.0))
	var speed := base_speed
	var statuses: Dictionary = unit.get("statuses", {})
	if statuses.has("speed_up"):
		var value: float = float(statuses["speed_up"].get("value", 20))
		speed *= 1.0 + value / 100.0
	if statuses.has("speed_down"):
		var value: float = float(statuses["speed_down"].get("value", 20))
		speed *= 1.0 - value / 100.0
	if statuses.has("freeze"):
		speed *= 0.7
	# 词缀：终焉意志（HP<20%全属性+50%）
	if _has_final_will_active(unit):
		speed *= 1.5
	return speed


# 检查单位是否拥有指定词缀
static func _has_affix(unit: Dictionary, affix_id: String) -> bool:
	var affixes: Array = unit.get("affixes", [])
	for affix in affixes:
		if affix is Dictionary and str(affix.get("id", "")) == affix_id:
			return true
	return false


# 检查单位是否处于终焉意志激活状态（HP<20%）
static func _has_final_will_active(unit: Dictionary) -> bool:
	if not _has_affix(unit, "final_will"):
		return false
	var hp_ratio := float(unit.get("hp", 0.0)) / maxf(float(unit.get("max_hp", 1.0)), 1.0)
	return hp_ratio < 0.2


# 词缀：复苏——首次死亡恢复20% HP（每单位一次）
static func _try_revive(battle: Dictionary) -> bool:
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("team", "") != "enemy":
			continue
		if not unit.get("defeated", false):
			continue
		if unit.get("revived", false):
			continue
		if not _has_affix(unit, "revive"):
			continue
		unit["defeated"] = false
		unit["hp"] = float(unit["max_hp"]) * 0.2
		unit["revived"] = true
		_add_log(battle, "%s 触发了[复苏]，恢复 20%% 生命重新站起！" % unit["name"])
		return true
	return false


# 词缀：裂隙召唤——动态添加敌人单位
static func _spawn_enemy(battle: Dictionary, beast_id: String) -> void:
	var beast: Dictionary = DataManager.beasts.get(beast_id, {})
	if beast.is_empty():
		return
	var index: int = battle.get("enemy_party", []).size()
	var unit: Dictionary = _build_enemy_unit(beast.duplicate(true), index)
	battle["units"][unit["id"]] = unit
	battle["enemy_party"].append(unit["id"])


static func _get_final_attack(unit: Dictionary, damage_type: String) -> float:
	var base: float = float(unit["stats"].get("attack", 0)) if damage_type == "physical" else float(unit["stats"].get("spirit", 0))
	var statuses: Dictionary = unit.get("statuses", {})
	if statuses.has("attack_up"):
		var value: float = float(statuses["attack_up"].get("value", 20))
		base *= 1.0 + value / 100.0
	# 蓄力加成
	if unit.get("charging", "") != "" or unit.get("charge_multiplier", 0) > 0:
		base *= CHARGE_MULTIPLIER
	# 词缀：狂暴（HP<30%攻击+20%）
	if _has_affix(unit, "berserk"):
		var hp_ratio := float(unit.get("hp", 0.0)) / maxf(float(unit.get("max_hp", 1.0)), 1.0)
		if hp_ratio < 0.3:
			base *= 1.2
	# 词缀：终焉意志（HP<20%全属性+50%）
	if _has_final_will_active(unit):
		base *= 1.5
	return base


static func _get_final_defense(unit: Dictionary, damage_type: String) -> float:
	var base: float = float(unit["stats"].get("defense", 0)) if damage_type == "physical" else float(unit["stats"].get("resistance", 0))
	var statuses: Dictionary = unit.get("statuses", {})
	if statuses.has("defense_up"):
		var value: float = float(statuses["defense_up"].get("value", 20))
		base *= 1.0 + value / 100.0
	if unit.get("guard", false):
		base *= 1.0 + GUARD_DEFENSE_BONUS
	# 词缀：终焉意志（HP<20%全属性+50%）
	if _has_final_will_active(unit):
		base *= 1.5
	return base


# ============================================================
# 伤害计算
# ============================================================
static func affinity_modifier(damage_type: String, defender: Dictionary) -> float:
	var weaknesses: Array = defender.get("weakness", [])
	var type_label := _get_damage_type_label(damage_type)
	for w in weaknesses:
		if str(w) == type_label:
			return 1.3
	return 1.0


static func _get_damage_type(skill: Dictionary) -> String:
	var type_text: String = str(skill.get("type", "物理·单体"))
	if type_text.begins_with("灵能"):
		return "spirit"
	return "physical"


static func _get_damage_type_label(damage_type: String) -> String:
	return str(DAMAGE_TYPE_LABELS.get(damage_type, damage_type))


static func get_affinity_label(skill: Dictionary, defender: Dictionary) -> String:
	var damage_type := _get_damage_type(skill)
	var modifier := affinity_modifier(damage_type, defender)
	if modifier > 1.01:
		return "克制"
	if modifier < 0.99:
		return "抵抗"
	return ""


static func calculate_damage(
	attacker: Dictionary,
	defender: Dictionary,
	skill: Dictionary,
	critical: bool = false,
	guard: bool = false
) -> int:
	var damage_type := _get_damage_type(skill)

	var multiplier: float = float(skill.get("multiplier", 1.0))
	var attack_value: float = _get_final_attack(attacker, damage_type)
	var defense_value: float = _get_final_defense(defender, damage_type)

	# 无视防御
	if skill.get("ignore_defense", false):
		defense_value = 0.0

	var damage: float = attack_value * multiplier * (100.0 / (100.0 + defense_value))

	# 属性克制
	damage *= affinity_modifier(damage_type, defender)

	# 暴击
	if critical:
		damage *= 1.8

	# 防御（guard）减伤
	if guard:
		damage *= GUARD_DAMAGE_REDUCTION

	return maxi(1, roundi(damage))


static func _calculate_critical(unit: Dictionary) -> bool:
	var speed: float = float(unit["stats"].get("speed", 10.0))
	var rate := 5.0 + speed * 0.3
	return randf() * 100.0 < rate


# ============================================================
# 战斗状态查询
# ============================================================
static func get_current_actor(battle: Dictionary) -> String:
	if battle["turn_index"] >= battle["turn_order"].size():
		return ""
	return str(battle["turn_order"][battle["turn_index"]])


static func is_actor_player(battle: Dictionary, actor_id: String) -> bool:
	var unit: Dictionary = battle["units"].get(actor_id, {})
	return unit.get("team", "") == "player"


static func get_alive_team_units(battle: Dictionary, team: String) -> Array:
	var result: Array = []
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("team", "") == team and not unit.get("defeated", false):
			result.append(unit_id)
	return result


static func get_team_lowest_hp_unit(battle: Dictionary, team: String) -> String:
	var alive: Array = get_alive_team_units(battle, team)
	if alive.is_empty():
		return ""
	var best_id: String = str(alive[0])
	var best_ratio: float = 1.0
	for unit_id in alive:
		var unit: Dictionary = battle["units"][unit_id]
		var ratio: float = float(unit["hp"]) / float(unit["max_hp"])
		if ratio < best_ratio:
			best_ratio = ratio
			best_id = str(unit_id)
	return best_id


static func _get_team_status_label(battle: Dictionary, team: String) -> String:
	var alive: Array = get_alive_team_units(battle, team)
	var parts: Array[String] = []
	for unit_id in alive:
		var unit: Dictionary = battle["units"][unit_id]
		var status_text := _get_unit_status_label(unit)
		if status_text != "":
			parts.append("%s(%s)" % [unit["name"], status_text])
	return "、".join(parts)


static func _get_unit_status_label(unit: Dictionary) -> String:
	var parts: Array[String] = []
	for status_id in unit.get("statuses", {}):
		if status_id == "shield":
			parts.append("护盾%d" % int(unit["statuses"][status_id].get("value", 0)))
		else:
			parts.append(STATUS_NAMES.get(status_id, status_id))
	if unit.get("guard", false):
		parts.append("防御")
	return "、".join(parts)


static func get_flag_status_label(battle: Dictionary) -> String:
	var player_status := _get_team_status_label(battle, "player")
	var enemy_status := _get_team_status_label(battle, "enemy")
	var result: Array[String] = []
	if player_status != "":
		result.append("我方：" + player_status)
	if enemy_status != "":
		result.append("敌方：" + enemy_status)
	return "  ".join(result)


# ============================================================
# 战斗行动执行
# ============================================================
static func perform_action(
	battle: Dictionary,
	actor_id: String,
	action_type: String,
	target_ids: Array = [],
	skill_id: String = ""
) -> void:
	if battle.get("battle_over", false):
		return

	var units: Dictionary = battle["units"]
	var actor: Dictionary = units.get(actor_id, {})
	if actor.is_empty() or actor.get("defeated", false):
		advance_turn(battle)
		return

	# 混乱状态：随机行动
	if actor.get("statuses", {}).has("confusion") and (action_type == "skill" or action_type == "attack"):
		var allies: Array = get_alive_team_units(battle, actor["team"])
		var foes: Array = get_alive_team_units(battle, "player" if actor["team"] == "enemy" else "enemy")
		var pool: Array = allies + foes
		if pool.size() > 0:
			var random_target: String = str(pool[randi() % pool.size()])
			_add_log(battle, "%s 陷入混乱，随机攻击 %s！" % [actor["name"], units[random_target]["name"]])
			_resolve_attack(battle, actor_id, random_target, DataManager.skills.get(BASIC_ATTACK_ID, {}), true)
		else:
			_add_log(battle, "%s 混乱中不知所措。" % actor["name"])
		advance_turn(battle)
		return

	match action_type:
		"attack":
			if target_ids.is_empty():
				target_ids = [_select_optimal_target(battle, actor_id)]
			target_ids = _filter_alive_targets(battle, target_ids)
			if target_ids.is_empty():
				_add_log(battle, "%s 找不到可攻击目标。" % actor["name"])
				advance_turn(battle)
				return
			var target_id: String = str(target_ids[0])
			_resolve_attack(battle, actor_id, target_id, DataManager.skills.get(BASIC_ATTACK_ID, {}), true)
		"skill":
			var skill: Dictionary = DataManager.skills.get(skill_id, {})
			if skill.is_empty():
				_add_log(battle, "%s 尝试使用未知技能。" % actor["name"])
			else:
				_execute_skill(battle, actor_id, skill, target_ids)
		"guard":
			actor["guard"] = true
			_add_log(battle, "%s 进入防御姿态，本回合受到的伤害降低！" % actor["name"])
		"item":
			_add_log(battle, "%s 使用道具。" % actor["name"])

	advance_turn(battle)


static func _resolve_attack(battle: Dictionary, attacker_id: String, target_id: String, skill: Dictionary, is_basic: bool) -> void:
	if target_id == "":
		return
	var units: Dictionary = battle["units"]
	if not units.has(attacker_id) or not units.has(target_id):
		return
	var attacker: Dictionary = units[attacker_id]
	var defender: Dictionary = units[target_id]
	if attacker.get("defeated", false) or defender.get("defeated", false):
		return

	var skill_name: String = str(skill.get("name", "攻击"))
	var hits: int = maxi(1, int(skill.get("hits", 1)))
	var total_damage: int = 0
	var hits_text: Array[String] = []
	var affinity_text := get_affinity_label(skill, defender)

	for h in range(hits):
		var critical := _calculate_critical(attacker)
		var guard: bool = bool(defender.get("guard", false))
		var shield: float = float(defender.get("statuses", {}).get("shield", {}).get("value", 0)) if defender.get("statuses", {}).has("shield") else 0.0
		var damage := calculate_damage(attacker, defender, skill, critical, guard)

		# 护盾吸收
		if shield > 0.0:
			var absorbed := minf(shield, float(damage))
			shield -= absorbed
			damage -= int(absorbed)
			if shield <= 0.0:
				defender["statuses"].erase("shield")
			else:
				defender["statuses"]["shield"]["value"] = shield
			hits_text.append("护盾吸收%d" % int(absorbed))

		defender["hp"] = maxf(0.0, float(defender["hp"]) - float(damage))
		total_damage += damage
		if critical:
			hits_text.append("暴击%d" % damage)
		else:
			hits_text.append("%d" % damage)
		if float(defender["hp"]) <= 0.0:
			defender["defeated"] = true
			_add_log(battle, "%s 被击败！" % defender["name"])
			break

	var suffix := "（%s）" % affinity_text if affinity_text != "" else ""
	if is_basic:
		_add_log(battle, "%s 发起攻击 → %s 受到 %s 点伤害%s。" % [attacker["name"], defender["name"], "、".join(hits_text), suffix])
	else:
		_add_log(battle, "%s 使用[%s] → %s 受到 %s 点伤害%s。" % [attacker["name"], skill_name, defender["name"], "、".join(hits_text), suffix])

	# 词缀：毒血（攻击附带中毒）
	if _has_affix(attacker, "poison_blood") and not defender.get("defeated", false):
		_apply_status(battle, defender, "poison", 3, {"value": 2})
		_add_log(battle, "%s 的毒血侵蚀了 %s！" % [attacker["name"], defender["name"]])

	# 词缀：灵能反噬（灵能攻击反伤20%）
	var skill_type := str(skill.get("type", ""))
	if skill_type.begins_with("灵能") and _has_affix(defender, "spirit_reflect") and not defender.get("defeated", false):
		var reflect := roundi(float(total_damage) * 0.2)
		if reflect > 0:
			attacker["hp"] = maxf(0.0, float(attacker["hp"]) - float(reflect))
			_add_log(battle, "%s 的灵能反噬反弹 %d 点伤害给 %s！" % [defender["name"], reflect, attacker["name"]])

	# 普攻反击
	_check_counter(battle, attacker_id, target_id, total_damage, skill, is_basic)


static func _check_counter(battle: Dictionary, attacker_id: String, target_id: String, damage: int, skill: Dictionary, is_basic: bool) -> void:
	# 反击由被动技能处理（简化：暂无被动反击数据，保留扩展）
	pass


static func _filter_alive_targets(battle: Dictionary, target_ids: Array) -> Array:
	var result: Array = []
	var units: Dictionary = battle.get("units", {})
	for target_ref in target_ids:
		var target_id := str(target_ref)
		if target_id == "":
			continue
		if not units.has(target_id):
			continue
		var target: Dictionary = units[target_id]
		if target.get("defeated", false):
			continue
		result.append(target_id)
	return result


static func _execute_skill(battle: Dictionary, actor_id: String, skill: Dictionary, target_ids: Array) -> void:
	var units: Dictionary = battle["units"]
	var actor: Dictionary = units[actor_id]
	var skill_id: String = str(skill.get("id", ""))

	# 检查技能可用性
	if not _is_skill_usable(battle, actor, skill):
		_add_log(battle, "%s 无法使用[%s]（能量不足或冷却中）。" % [actor["name"], skill.get("name", skill_id)])
		return

	# 终极技能限次
	if actor.get("ultimate_used", false) and skill.get("limit", "") != "":
		_add_log(battle, "%s 的终极技能已使用过！" % actor["name"])
		return
	if skill.get("limit", "") != "":
		actor["ultimate_used"] = true

	# 消耗能量
	var energy_cost: int = int(skill.get("energy", 0))
	actor["energy"] = maxf(0.0, float(actor["energy"]) - float(energy_cost))

	# 设置冷却
	var cooldown: int = int(skill.get("cooldown", 0))
	if cooldown > 0:
		actor["cooldowns"][skill_id] = cooldown

	var type_text: String = str(skill.get("type", "物理·单体"))

	# 确定目标集合
	var targets: Array = []
	if type_text.find("全体") >= 0 or type_text.find("全队") >= 0:
		var target_team := "enemy" if actor["team"] == "player" else "player"
		# 辅助全体 -> 自己方
		if type_text.begins_with("辅助"):
			target_team = actor["team"]
		targets = get_alive_team_units(battle, target_team)
		# 平局防御目标选择
		if targets.is_empty():
			return
	elif type_text.find("自身") >= 0:
		targets = [actor_id]
	elif not target_ids.is_empty():
		targets = [str(target_ids[0])]
	else:
		targets = [_select_optimal_target(battle, actor_id)]
	targets = _filter_alive_targets(battle, targets)
	if targets.is_empty():
		_add_log(battle, "%s 的[%s]没有可用目标。" % [actor["name"], skill.get("name", skill_id)])
		return

	# 伤害类技能
	if type_text.begins_with("物理") or type_text.begins_with("灵能"):
		var hits: int = maxi(1, int(skill.get("hits", 1)))
		for target_id in targets:
			var target: Dictionary = units[target_id]
			if target.get("defeated", false):
				continue
			var total_damage: int = 0
			var critical_hits: int = 0
			for h in range(hits):
				var critical := _calculate_critical(actor)
				var guard: bool = bool(target.get("guard", false))
				var shield: float = _get_shield_value(target)
				var damage := calculate_damage(actor, target, skill, critical, guard)
				if shield > 0.0:
					var absorbed := minf(shield, float(damage))
					shield -= absorbed
					damage -= int(absorbed)
					_set_shield_value(target, shield)
				target["hp"] = maxf(0.0, float(target["hp"]) - float(damage))
				total_damage += damage
				if critical:
					critical_hits += 1
				if float(target["hp"]) <= 0.0:
					target["defeated"] = true
					break
			var damage_text := "%d(暴击%d)" % [total_damage, critical_hits] if critical_hits > 0 else "%d" % total_damage
			var affinity_text := get_affinity_label(skill, target)
			var suffix := "（%s）" % affinity_text if affinity_text != "" else ""
			_add_log(battle, "%s 使用[%s] → %s 受到 %s 点伤害%s。" % [actor["name"], skill.get("name", ""), target["name"], damage_text, suffix])
			if target.get("defeated", false):
				_add_log(battle, "%s 被击败！" % target["name"])
			_apply_skill_status_effects(battle, actor, target, skill)

	# 治疗类技能
	if skill.has("heal_percent"):
		for target_id in targets:
			var target: Dictionary = units[target_id]
			var heal_percent: float = float(skill.get("heal_percent", 0.0))
			var heal_amount: int = roundi(float(target["max_hp"]) * heal_percent / 100.0)
			target["hp"] = minf(float(target["max_hp"]), float(target["hp"]) + float(heal_amount))
			_add_log(battle, "%s 使用[%s] → %s 恢复 %d 点生命。" % [actor["name"], skill.get("name", ""), target["name"], heal_amount])

	# 护盾类技能
	if skill.has("shield_percent"):
		for target_id in targets:
			var target: Dictionary = units[target_id]
			var shield_percent: float = float(skill.get("shield_percent", 0.0))
			var shield_amount: int = roundi(float(target["max_hp"]) * shield_percent / 100.0)
			var statuses: Dictionary = target["statuses"]
			if statuses.has("shield"):
				statuses["shield"]["value"] = float(statuses["shield"]["value"]) + float(shield_amount)
			else:
				statuses["shield"] = {"value": float(shield_amount)}
			_add_log(battle, "%s 使用[%s] → %s 获得 %d 点护盾。" % [actor["name"], skill.get("name", ""), target["name"], shield_amount])

	# 能量恢复技能
	if skill.has("energy_restore"):
		for target_id in targets:
			var target: Dictionary = units[target_id]
			var restore: float = float(skill.get("energy_restore", 0))
			target["energy"] = minf(float(target["max_energy"]), float(target["energy"]) + restore)
			_add_log(battle, "%s 使用[%s] → %s 恢复 %d 点能量。" % [actor["name"], skill.get("name", ""), target["name"], int(restore)])

	# 增益类技能（attack_percent / defense_percent / speed_percent）
	if skill.has("attack_percent") or skill.has("defense_percent") or skill.has("speed_percent"):
		var duration: int = maxi(1, int(skill.get("duration", 2)))
		for target_id in targets:
			var target: Dictionary = units[target_id]
			var statuses: Dictionary = target["statuses"]
			if skill.has("attack_percent"):
				statuses["attack_up"] = {"duration": duration, "value": float(skill.get("attack_percent", 0.0))}
				_add_log(battle, "%s 获得攻击提升 +%.0f%%！" % [target["name"], float(skill.get("attack_percent", 0.0))])
			if skill.has("defense_percent"):
				statuses["defense_up"] = {"duration": duration, "value": float(skill.get("defense_percent", 0.0))}
				_add_log(battle, "%s 获得防御提升 +%.0f%%！" % [target["name"], float(skill.get("defense_percent", 0.0))])
			if skill.has("speed_percent"):
				var speed_value: float = float(skill.get("speed_percent", 0.0))
				if speed_value >= 0:
					statuses["speed_up"] = {"duration": duration, "value": speed_value}
				else:
					statuses["speed_down"] = {"duration": duration, "value": -speed_value}

	# 嘲讽
	if skill.has("duration") and type_text.find("嘲讽") >= 0:
		for target_id in targets:
			var target: Dictionary = units[target_id]
			target["statuses"]["taunt"] = {"duration": int(skill.get("duration", 2))}
			_add_log(battle, "%s 被嘲讽，强制攻击 %s！" % [target["name"], actor["name"]])


static func _apply_skill_status_effects(battle: Dictionary, actor: Dictionary, target: Dictionary, skill: Dictionary) -> void:
	# 灼烧
	if skill.has("burn_chance") and randf() * 100.0 < float(skill.get("burn_chance", 0)):
		_apply_status(battle, target, "burn", 3, {"value": 5})
		_add_log(battle, "%s 被灼烧！" % target["name"])
	# 减速
	if skill.has("slow_chance") and randf() * 100.0 < float(skill.get("slow_chance", 0)):
		_apply_status(battle, target, "speed_down", 3, {"value": 30})
		_add_log(battle, "%s 被减速！" % target["name"])
	# 中毒
	if skill.has("poison_chance") and randf() * 100.0 < float(skill.get("poison_chance", 0)):
		_apply_status(battle, target, "poison", 3, {"value": 3})
		_add_log(battle, "%s 中毒了！" % target["name"])
	# 混乱
	if skill.has("confusion_chance") and randf() * 100.0 < float(skill.get("confusion_chance", 0)):
		_apply_status(battle, target, "confusion", 2, {})
		_add_log(battle, "%s 陷入混乱！" % target["name"])


static func _apply_status(battle: Dictionary, target: Dictionary, status_id: String, duration: int, extra: Dictionary = {}) -> void:
	var statuses: Dictionary = target["statuses"]
	# 词缀：轮回感知（控制效果持续时间-50%）
	var control_statuses := ["freeze", "confusion", "speed_down"]
	if _has_affix(target, "reincarnation_sense") and status_id in control_statuses:
		duration = maxi(1, int(ceil(float(duration) * 0.5)))
	if not statuses.has(status_id):
		statuses[status_id] = {"duration": duration}
	for key in extra:
		statuses[status_id][key] = extra[key]


static func _get_shield_value(unit: Dictionary) -> float:
	if unit.get("statuses", {}).has("shield"):
		return float(unit["statuses"]["shield"].get("value", 0.0))
	return 0.0


static func _set_shield_value(unit: Dictionary, value: float) -> void:
	if value <= 0.0:
		unit["statuses"].erase("shield")
	else:
		unit["statuses"]["shield"] = {"value": value}


static func _is_skill_usable(battle: Dictionary, actor: Dictionary, skill: Dictionary) -> bool:
	var skill_id: String = str(skill.get("id", ""))
	var energy_cost: int = int(skill.get("energy", 0))
	if float(actor["energy"]) < float(energy_cost):
		return false
	if actor.get("cooldowns", {}).has(skill_id) and int(actor["cooldowns"][skill_id]) > 0:
		return false
	if skill.get("limit", "") != "" and actor.get("ultimate_used", false):
		return false
	return true


static func _select_optimal_target(battle: Dictionary, attacker_id: String) -> String:
	var actor: Dictionary = battle["units"][attacker_id]
	var enemy_team := "player" if actor["team"] == "enemy" else "enemy"
	var alive_enemies: Array = get_alive_team_units(battle, enemy_team)
	if alive_enemies.is_empty():
		return ""

	# 词缀：猎杀（无视嘲讽，强制攻击生命最低的敌人）
	if _has_affix(actor, "hunter"):
		return get_team_lowest_hp_unit(battle, enemy_team)

	# 嘲讽检查：强制攻击嘲讽者
	for enemy_id in alive_enemies:
		var enemy: Dictionary = battle["units"][enemy_id]
		if enemy.get("statuses", {}).has("taunt"):
			return str(enemy_id)

	# 默认打 HP 最低的敌人
	return get_team_lowest_hp_unit(battle, enemy_team)


static func _select_heal_target(battle: Dictionary, actor_id: String) -> String:
	return get_team_lowest_hp_unit(battle, "player" if battle["units"][actor_id]["team"] == "player" else "enemy")


# ============================================================
# 回合推进
# ============================================================
static func advance_turn(battle: Dictionary) -> void:
	if battle.get("battle_over", false):
		return

	battle["turn_index"] += 1

	# 回合结束判断
	if battle["turn_index"] >= battle["turn_order"].size():
		_process_round_end(battle)

	# 跳过已死亡单位
	while battle["turn_index"] < battle["turn_order"].size():
		var next_id: String = str(battle["turn_order"][battle["turn_index"]])
		var next_unit: Dictionary = battle["units"].get(next_id, {})
		if next_unit.is_empty() or next_unit.get("defeated", false):
			battle["turn_index"] += 1
			if battle["turn_index"] >= battle["turn_order"].size():
				_process_round_end(battle)
		else:
			break

	# 检查战斗结束
	if check_battle_over(battle):
		return

	# 新回合需要重建行动顺序
	if battle["turn_index"] == 0 and not battle["battle_over"]:
		battle["turn_order"] = _build_turn_order(battle)


static func _process_round_end(battle: Dictionary) -> void:
	# 状态结算（灼烧/中毒）
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("defeated", false):
			continue
		var statuses: Dictionary = unit["statuses"]
		if statuses.has("burn"):
			var burn_damage: int = roundi(float(unit["max_hp"]) * float(statuses["burn"].get("value", 5)) / 100.0)
			unit["hp"] = maxf(0.0, float(unit["hp"]) - float(burn_damage))
			_add_log(battle, "%s 被灼烧，损失 %d 点生命。" % [unit["name"], burn_damage])
			if float(unit["hp"]) <= 0.0:
				unit["defeated"] = true
				_add_log(battle, "%s 被灼烧致死！" % unit["name"])
		if statuses.has("poison"):
			var poison_damage: int = roundi(float(unit["max_hp"]) * float(statuses["poison"].get("value", 3)) / 100.0)
			unit["hp"] = maxf(0.0, float(unit["hp"]) - float(poison_damage))
			_add_log(battle, "%s 中毒，损失 %d 点生命。" % [unit["name"], poison_damage])
			if float(unit["hp"]) <= 0.0:
				unit["defeated"] = true
				_add_log(battle, "%s 中毒身亡！" % unit["name"])

	# 词缀：虚空连接（每回合恢复2% HP）
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("defeated", false):
			continue
		if _has_affix(unit, "void_link"):
			var heal_amount: int = roundi(float(unit["max_hp"]) * 0.02)
			unit["hp"] = minf(float(unit["max_hp"]), float(unit["hp"]) + float(heal_amount))
			_add_log(battle, "%s 通过虚空连接恢复了 %d 点生命。" % [unit["name"], heal_amount])

	# 词缀：暗影屏障（每5回合获得3000护盾）
	if int(battle.get("round", 1)) % 5 == 0:
		for unit_id in battle["units"]:
			var unit: Dictionary = battle["units"][unit_id]
			if unit.get("defeated", false):
				continue
			if _has_affix(unit, "shadow_barrier"):
				unit["statuses"]["shield"] = {"value": 3000.0}
				_add_log(battle, "%s 展开暗影屏障，获得 3000 点护盾！" % unit["name"])

	# 词缀：裂隙召唤（HP<50%召唤裂隙暗影×1，每场战斗一次）
	var summon_owners: Array = []
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("defeated", false) or unit.get("team") != "enemy":
			continue
		if _has_affix(unit, "rift_summon") and not unit.get("summoned", false):
			var hp_ratio := float(unit.get("hp", 0.0)) / maxf(float(unit.get("max_hp", 1.0)), 1.0)
			if hp_ratio < 0.5:
				unit["summoned"] = true
				summon_owners.append(unit["name"])
	if not summon_owners.is_empty():
		for owner_name in summon_owners:
			_spawn_enemy(battle, "rift_shadow")
			_add_log(battle, "%s 撕裂了裂隙，召唤出裂隙暗影！" % owner_name)

	# 能量恢复（每回合20%）
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("defeated", false):
			continue
		var regen: float = float(unit["max_energy"]) * ENERGY_REGEN_PERCENT
		unit["energy"] = minf(float(unit["max_energy"]), float(unit["energy"]) + regen)

	# 冷却-1
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		var cooldowns: Dictionary = unit["cooldowns"]
		for skill_id in cooldowns.keys():
			cooldowns[skill_id] = int(cooldowns[skill_id]) - 1
			if int(cooldowns[skill_id]) <= 0:
				cooldowns.erase(skill_id)

	# 状态持续时间-1，移除过期状态
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		var statuses: Dictionary = unit["statuses"]
		for status_id in statuses.keys():
			if status_id == "shield":
				continue
			statuses[status_id]["duration"] = int(statuses[status_id].get("duration", 1)) - 1
			if int(statuses[status_id]["duration"]) <= 0:
				statuses.erase(status_id)

	# 重置防御
	for unit_id in battle["units"]:
		battle["units"][unit_id]["guard"] = false

	# 蓄力释放（简化：蓄力技能在下一回合自动释放）
	for unit_id in battle["units"]:
		var unit: Dictionary = battle["units"][unit_id]
		if unit.get("charging", "") != "":
			var charge_skill_id: String = str(unit["charging"])
			unit["charging"] = ""
			unit["charge_multiplier"] = CHARGE_MULTIPLIER
			var charge_skill: Dictionary = DataManager.skills.get(charge_skill_id, {})
			if not charge_skill.is_empty():
				_add_log(battle, "%s 蓄力完成！[%s] 威力大幅提升！" % [unit["name"], charge_skill.get("name", charge_skill_id)])
				var targets: Array = [_select_optimal_target(battle, unit_id)]
				_execute_skill(battle, unit_id, charge_skill, targets)
			unit["charge_multiplier"] = 0.0

	# 回合+1
	battle["round"] = int(battle["round"]) + 1
	_add_log(battle, "—— 回合 %d ——" % battle["round"])

	# 重建行动顺序
	battle["turn_order"] = _build_turn_order(battle)
	battle["turn_index"] = 0


static func check_battle_over(battle: Dictionary) -> bool:
	if battle.get("battle_over", false):
		return true

	var player_alive: Array = get_alive_team_units(battle, "player")
	var enemy_alive: Array = get_alive_team_units(battle, "enemy")

	if enemy_alive.is_empty():
		# 词缀：复苏（首次死亡恢复20% HP）
		if _try_revive(battle):
			return false
		battle["battle_over"] = true
		battle["victory"] = true
		battle["rewards"] = calculate_rewards(battle)
		_add_log(battle, "🎉 战斗胜利！")
		return true

	if player_alive.is_empty():
		battle["battle_over"] = true
		battle["victory"] = false
		_add_log(battle, "💀 战斗失败……")
		return true

	return false


static func calculate_rewards(battle: Dictionary) -> Dictionary:
	var rewards := {
		"exp": 0,
		"gold": 0,
		"resources": {},
		"drops": []
	}
	var units: Dictionary = battle.get("units", {})
	for enemy_id in battle.get("enemy_party", []):
		if not units.has(enemy_id):
			continue
		var unit: Dictionary = units[enemy_id]
		var beast: Dictionary = unit.get("base_id_ref", {})
		var level := maxi(1, int(unit.get("level", beast.get("level", 1))))
		var max_hp := maxi(1, int(unit.get("max_hp", beast.get("hp", 1))))
		var type_text := str(unit.get("type", beast.get("type", "普通")))
		var type_mult := 1.0
		if type_text == "精英":
			type_mult = 1.6
		elif type_text == "BOSS":
			type_mult = 3.0

		rewards["exp"] = int(rewards["exp"]) + int(round((level * 8 + max_hp * 0.08) * type_mult))
		rewards["gold"] = int(rewards["gold"]) + int(round((level * 3 + max_hp * 0.03) * type_mult))
		_add_reward_resource(rewards["resources"], "cores", maxi(1, int(ceil(float(level) / 6.0))))
		if type_text == "精英" or type_text == "BOSS":
			_add_reward_resource(rewards["resources"], "rare_material", maxi(1, int(ceil(float(level) / 12.0))))
		if type_text == "BOSS":
			_add_reward_resource(rewards["resources"], "spirit_core", maxi(1, int(ceil(float(level) / 18.0))))

		var fixed_rewards: Dictionary = beast.get("rewards", {})
		for key in fixed_rewards:
			if str(key) == "exp":
				rewards["exp"] = int(rewards["exp"]) + int(fixed_rewards[key])
			elif str(key) == "gold":
				rewards["gold"] = int(rewards["gold"]) + int(fixed_rewards[key])
			elif str(key) in RESOURCE_REWARD_KEYS:
				_add_reward_resource(rewards["resources"], str(key), int(fixed_rewards[key]))

		for drop in beast.get("drops", []):
			if not (drop is Dictionary):
				continue
			var rate := float(drop.get("rate", 1.0))
			if randf() > rate:
				continue
			var min_count := int(drop.get("min", drop.get("qty", 1)))
			var max_count := int(drop.get("max", min_count))
			var count := randi_range(min_count, max_count)
			var item_id := str(drop.get("id", drop.get("item", "")))
			if item_id == "":
				continue
			var item_name := str(drop.get("name", item_id))
			if item_id in RESOURCE_REWARD_KEYS:
				_add_reward_resource(rewards["resources"], item_id, count)
			else:
				rewards["drops"].append({"id": item_id, "name": item_name, "count": count})
	var encounter_rewards: Dictionary = battle.get("encounter_rewards", {})
	if not encounter_rewards.is_empty():
		rewards["exp"] = int(rewards["exp"]) + int(encounter_rewards.get("exp", 0))
		rewards["gold"] = int(rewards["gold"]) + int(encounter_rewards.get("gold", 0))
		var encounter_resources: Dictionary = encounter_rewards.get("resources", {})
		for resource_id in encounter_resources:
			_add_reward_resource(rewards["resources"], str(resource_id), int(encounter_resources[resource_id]))
		for drop in encounter_rewards.get("drops", []):
			if drop is Dictionary:
				rewards["drops"].append(drop.duplicate(true))
	return rewards


static func _add_reward_resource(resources: Dictionary, resource_id: String, amount: int) -> void:
	if amount == 0:
		return
	resources[resource_id] = int(resources.get(resource_id, 0)) + amount


static func format_rewards(rewards: Dictionary) -> String:
	var parts: Array[String] = []
	var exp := int(rewards.get("exp", 0))
	var gold := int(rewards.get("gold", 0))
	if exp > 0:
		parts.append("经验×%d" % exp)
	if gold > 0:
		parts.append("金币×%d" % gold)
	var resources: Dictionary = rewards.get("resources", {})
	for key in resources:
		var amount := int(resources[key])
		if amount > 0:
			parts.append("%s×%d" % [_format_reward_resource_name(str(key)), amount])
	for drop in rewards.get("drops", []):
		if drop is Dictionary:
			parts.append("%s×%d" % [drop.get("name", drop.get("id", "掉落物")), int(drop.get("count", 1))])
	return "、".join(parts)


static func _format_reward_resource_name(resource_id: String) -> String:
	match resource_id:
		"food":
			return "口粮"
		"medicine":
			return "药品"
		"cores":
			return "晶核"
		"memory_shards":
			return "记忆碎片"
		"tickets":
			return "补给券"
		"spirit_battery":
			return "灵能电池"
		"ammo":
			return "弹药"
		"rare_material":
			return "稀有材料"
		"spirit_core":
			return "灵核"
	return resource_id


# ============================================================
# AI 决策
# ============================================================
static func decide_ai_action(battle: Dictionary, actor_id: String) -> Dictionary:
	var units: Dictionary = battle["units"]
	var actor: Dictionary = units[actor_id]
	var actor_team: String = actor["team"]

	# 混乱状态：随机攻击
	if actor.get("statuses", {}).has("confusion"):
		var allies: Array = get_alive_team_units(battle, actor_team)
		var foes: Array = get_alive_team_units(battle, "player" if actor_team == "enemy" else "enemy")
		var pool: Array = allies + foes
		if pool.size() > 0:
			return {"action": "attack", "target_id": str(pool[randi() % pool.size()])}
		return {"action": "guard"}

	# 1. HP < 30% → 优先治疗/防御
	var hp_ratio: float = float(actor["hp"]) / float(actor["max_hp"]) if actor["max_hp"] > 0 else 1.0
	if hp_ratio < 0.3:
		# 寻找治疗技能
		for skill_id in actor.get("skills", []):
			var skill: Dictionary = DataManager.skills.get(str(skill_id), {})
			if skill.is_empty():
				continue
			if skill.has("heal_percent") and _is_skill_usable(battle, actor, skill):
				var heal_target := _select_heal_target(battle, actor_id)
				if actor_team == "enemy":
					heal_target = actor_id
				if heal_target != "":
					return {"action": "skill", "skill_id": str(skill_id), "target_id": heal_target}
		return {"action": "guard"}

	# 2. 有高伤害技能（倍率>=1.5 或 全体）→ 优先释放
	var best_skill_id: String = ""
	var best_score: float = 0.0
	for skill_id in actor.get("skills", []):
		var skill: Dictionary = DataManager.skills.get(str(skill_id), {})
		if skill.is_empty():
			continue
		if not _is_skill_usable(battle, actor, skill):
			continue
		var type_text: String = str(skill.get("type", ""))
		if not (type_text.begins_with("物理") or type_text.begins_with("灵能")):
			continue
		var score: float = float(skill.get("multiplier", 0.0))
		if type_text.find("全体") >= 0:
			score *= 1.3
		if skill.has("hits"):
			score *= float(skill.get("hits", 1))
		# 终极技能不轻易使用
		if skill.get("limit", "") != "":
			score *= 1.2
		if score > best_score:
			best_score = score
			best_skill_id = str(skill_id)

	# 高伤害阈值：best_score >= 1.5 或 有状态附加
	if best_score >= 1.5:
		var target_id: String = _select_optimal_target(battle, actor_id)
		if target_id != "":
			return {"action": "skill", "skill_id": best_skill_id, "target_id": target_id}

	# 3. 防御/增益辅助技能（战斗中使用）
	for skill_id in actor.get("skills", []):
		var skill: Dictionary = DataManager.skills.get(str(skill_id), {})
		if skill.is_empty():
			continue
		if not _is_skill_usable(battle, actor, skill):
			continue
		var type_text: String = str(skill.get("type", ""))
		if type_text.begins_with("辅助"):
			# 治疗已在上方处理；护盾/增益可在 HP > 50% 时使用
			if skill.has("shield_percent") and hp_ratio > 0.5:
				return {"action": "skill", "skill_id": str(skill_id), "target_id": actor_id}
			if skill.has("defense_percent") and hp_ratio > 0.5:
				return {"action": "skill", "skill_id": str(skill_id), "target_id": actor_id}
			if skill.has("attack_percent"):
				return {"action": "skill", "skill_id": str(skill_id), "target_id": actor_id}

	# 4. 默认普攻
	var default_target: String = _select_optimal_target(battle, actor_id)
	if default_target == "":
		return {"action": "guard"}
	return {"action": "attack", "target_id": default_target}


# ============================================================
# 工具函数
# ============================================================
static func _add_log(battle: Dictionary, text: String) -> void:
	battle["log"].append(text)
	if battle["log"].size() > 80:
		battle["log"] = battle["log"].slice(-80)


static func _format_party_names(party_ids: Array, units: Dictionary) -> String:
	var names: Array[String] = []
	for unit_id in party_ids:
		if units.has(unit_id):
			names.append(str(units[unit_id]["name"]))
	return "、".join(names)


static func get_unit_hp_ratio(battle: Dictionary, unit_id: String) -> float:
	var unit: Dictionary = battle["units"].get(unit_id, {})
	if unit.is_empty() or float(unit["max_hp"]) <= 0.0:
		return 0.0
	return float(unit["hp"]) / float(unit["max_hp"])


static func get_unit_energy_ratio(battle: Dictionary, unit_id: String) -> float:
	var unit: Dictionary = battle["units"].get(unit_id, {})
	if unit.is_empty() or float(unit["max_energy"]) <= 0.0:
		return 0.0
	return float(unit["energy"]) / float(unit["max_energy"])


static func get_usable_skills(battle: Dictionary, actor_id: String) -> Array:
	var actor: Dictionary = battle["units"].get(actor_id, {})
	var result: Array = []
	if actor.is_empty():
		return result
	for skill_id in actor.get("skills", []):
		var skill: Dictionary = DataManager.skills.get(str(skill_id), {})
		if skill.is_empty():
			continue
		if not _is_skill_usable(battle, actor, skill):
			continue
		var type_text: String = str(skill.get("type", ""))
		if type_text == "":
			continue
		result.append(str(skill_id))
	return result


static func get_skill_cooldown(unit: Dictionary, skill_id: String) -> int:
	var cooldowns: Dictionary = unit.get("cooldowns", {})
	return int(cooldowns.get(skill_id, 0))


static func get_unit_status_entries(unit: Dictionary) -> Array:
	var result: Array = []
	var statuses: Dictionary = unit.get("statuses", {})
	for status_id in statuses:
		var status: Dictionary = statuses[status_id] if statuses[status_id] is Dictionary else {}
		var label: String = str(STATUS_NAMES.get(status_id, str(status_id)))
		var duration := int(status.get("duration", 0))
		var value_text := ""
		if status_id == "shield":
			value_text = str(int(status.get("value", 0)))
		elif status.has("value"):
			value_text = str(int(status.get("value", 0))) + "%"
		result.append({
			"id": str(status_id),
			"name": label,
			"duration": duration,
			"value": value_text,
			"kind": _get_status_kind(str(status_id))
		})
	if unit.get("guard", false):
		result.append({"id": "guard", "name": "防御", "duration": 1, "value": "", "kind": "buff"})
	return result


static func _get_status_kind(status_id: String) -> String:
	if status_id in ["shield", "speed_up", "attack_up", "defense_up", "guard"]:
		return "buff"
	if status_id in ["burn", "freeze", "poison", "confusion", "speed_down"]:
		return "debuff"
	return "neutral"


static func get_battle_status_text(battle: Dictionary) -> String:
	var parts: Array[String] = []
	var enemy_alive: Array = get_alive_team_units(battle, "enemy")
	var enemy_status_labels: Array[String] = []
	for unit_id in enemy_alive:
		var unit: Dictionary = battle["units"][unit_id]
		var label := _get_unit_status_label(unit)
		var affixes: Array = unit.get("affixes", [])
		if not affixes.is_empty():
			var affix_names: Array[String] = []
			for affix in affixes:
				if affix is Dictionary:
					affix_names.append(str(affix.get("name", "")))
			if not affix_names.is_empty():
				label = (label + " " if label != "" else "") + "词缀:" + "、".join(affix_names)
		if label != "":
			enemy_status_labels.append("%s[%s]" % [unit["name"], label])
	if not enemy_status_labels.is_empty():
		parts.append("敌方：" + "、".join(enemy_status_labels))
	var player_alive: Array = get_alive_team_units(battle, "player")
	var player_status_labels: Array[String] = []
	for unit_id in player_alive:
		var unit: Dictionary = battle["units"][unit_id]
		var label := _get_unit_status_label(unit)
		if label != "":
			player_status_labels.append("%s[%s]" % [unit["name"], label])
	if not player_status_labels.is_empty():
		parts.append("我方：" + "、".join(player_status_labels))
	return "\n".join(parts)


static func get_enemy_display(battle: Dictionary) -> Dictionary:
	var enemy_alive: Array = get_alive_team_units(battle, "enemy")
	if enemy_alive.is_empty():
		return {}
	var first_id: String = str(enemy_alive[0])
	var unit: Dictionary = battle["units"][first_id]
	return {
		"id": first_id,
		"name": str(unit["name"]),
		"hp": int(unit["hp"]),
		"max_hp": int(unit["max_hp"])
	}


static func format_formation_bonus_text(bonus: Dictionary) -> String:
	var parts: Array[String] = []
	for stat in bonus:
		var value: float = float(bonus[stat])
		var label: String = stat
		match stat:
			"attack":
				label = "攻击"
			"spirit":
				label = "灵能"
			"defense":
				label = "防御"
			"resistance":
				label = "灵抗"
			"speed":
				label = "速度"
			"ep_start":
				label = "首回合EP"
		parts.append("%s%+.0f%%" % [label, value * 100.0])
	return "、".join(parts)
