class_name PlayerData
extends RefCounted

# 伙伴养成系统配置
const AFFINITY_LEVELS := [
	{"level": 1, "threshold": 0, "bonus": {"attack": 2, "defense": 2}, "title": "初识"},
	{"level": 2, "threshold": 30, "bonus": {"attack": 4, "defense": 3, "spirit": 2}, "title": "熟悉"},
	{"level": 3, "threshold": 80, "bonus": {"attack": 6, "defense": 5, "spirit": 4, "speed": 2}, "title": "信任"},
	{"level": 4, "threshold": 160, "bonus": {"attack": 9, "defense": 7, "spirit": 6, "speed": 3, "resistance": 3}, "title": "信赖"},
	{"level": 5, "threshold": 280, "bonus": {"attack": 12, "defense": 9, "spirit": 8, "speed": 5, "resistance": 5}, "title": "羁绊"},
	{"level": 6, "threshold": 450, "bonus": {"attack": 16, "defense": 12, "spirit": 11, "speed": 6, "resistance": 7}, "title": "生死与共"},
	{"level": 7, "threshold": 700, "bonus": {"attack": 20, "defense": 15, "spirit": 14, "speed": 8, "resistance": 9}, "title": "灵魂共鸣"},
	{"level": 8, "threshold": 1000, "bonus": {"attack": 25, "defense": 19, "spirit": 18, "speed": 10, "resistance": 12}, "title": "心意相通"},
	{"level": 9, "threshold": 1400, "bonus": {"attack": 30, "defense": 23, "spirit": 22, "speed": 12, "resistance": 15}, "title": "守望相依"},
	{"level": 10, "threshold": 1900, "bonus": {"attack": 38, "defense": 28, "spirit": 28, "speed": 15, "resistance": 18}, "title": "命运共同体"}
]
const STAR_UP_COSTS := {
	2: {"memory_shards": 30, "cores": 200},
	3: {"memory_shards": 60, "cores": 500, "rare_material": 5},
	4: {"memory_shards": 120, "cores": 1000, "rare_material": 12, "spirit_core": 2},
	5: {"memory_shards": 200, "cores": 2000, "rare_material": 25, "spirit_core": 5}
}
const MAX_PARTNER_STAR := 5
const SKILL_UPGRADE_COSTS := {
	1: {"cores": 30},
	2: {"cores": 60, "rare_material": 1},
	3: {"cores": 120, "rare_material": 2},
	4: {"cores": 200, "rare_material": 4}
}
const MAX_SKILL_LEVEL := 5

var player_name: String = "陈末"
var day: int = 1
var time_slot: int = 0
var chapter_id: int = 1
var mutation: int = 0
var story_flags: Dictionary = {}
var supplies: Dictionary = {"food": 30, "medicine": 10}
var materials: Dictionary = {"cores": 0, "memory_shards": 0, "tickets": 0, "spirit_battery": 0, "ammo": 0, "rare_material": 0, "spirit_core": 0}
var resource_caps: Dictionary = {"food": 99, "medicine": 99, "cores": 999, "memory_shards": 999, "tickets": 999, "spirit_battery": 99, "ammo": 99, "rare_material": 99, "spirit_core": 99}
var survivors: Array[Dictionary] = []
var active_survivor_ids: Array[String] = ["player_chenmo", "lin_mei"]
var reserve_survivor_ids: Array[String] = []

# 九宫格编队系统
# 3x3 网格，每个格子可放置一名伙伴
# 格子索引: 0-2 前排(先锋位) / 3-5 中排(输出位) / 6-8 后排(支援位)
# 阵型: "assault"(强攻阵) / "iron"(铁壁阵) / "wind"(疾风阵)
var formation_grid: Array = [null, null, null, null, null, null, null, null, null]
var current_formation: String = "assault"
var formation_bonuses: Dictionary = {
	"assault": {"attack": 0.10, "defense": -0.10, "speed": 0.0},
	"iron": {"attack": 0.0, "defense": 0.15, "speed": -0.10},
	"wind": {"attack": -0.05, "defense": 0.0, "speed": 0.15}
}
var explored_routes: Dictionary = {}  # route_id -> completed_count
var route_progress: Dictionary = {}  # route_id -> {node_index: int, completed: bool}

# ============================================================
# 轮回系统数据（V2.0 轮回主线）
# ============================================================
var reincarnation: int = 1                    # 当前轮回轮次
var max_chapter_reached: int = 1               # 本轮已到达最高章节
var highest_chapter_all_time: int = 1          # 历史最高章节（跨轮回）
var truth_progress: float = 0.0                # 真相进度 0.0 ~ 1.0
var reincarnation_marks: int = 0               # 轮回印记（永久货币）
var talent_points: int = 0                     # 天赋点（永久）
var boss_intel: Dictionary = {}                # boss_id -> {encountered, defeated, kill_count, intel_unlocked: [], lore_unlocked: bool}
var boss_kill_records: Dictionary = {}         # boss_id -> kill_count（跨轮回）
var reincarnation_memories: Array[String] = [] # 已触发的轮回记忆叙事
var best_rating: String = ""                   # 历史最佳评价 (S/A/B/C)
var last_rating: String = ""                   # 最近一次轮回评价
var reincarnation_count: int = 0               # 主动轮回次数


func _init() -> void:
	# 确保九宫格与初始出战阵容保持一致，避免上阵时人物丢失
	_sync_grid_from_active_ids()
	_setup_default_boss_intel()


func advance_half_day() -> void:
	time_slot += 1
	if time_slot >= 3:
		time_slot = 0
		day += 1
	chapter_id = _chapter_for_day(day)
	update_max_chapter_reached()


func add_resource(resource_id: String, amount: int) -> void:
	var target := supplies if resource_id in supplies else materials
	if not target.has(resource_id):
		return
	target[resource_id] = clampi(target[resource_id] + amount, 0, resource_caps[resource_id])


func get_act_id() -> int:
	if day <= 60:
		return 1
	if day <= 130:
		return 2
	return 3


func _chapter_for_day(current_day: int) -> int:
	# V2.0 48章主线：每章约4天（day 1-192 覆盖 1~48章，day>192 封顶48章）
	return clampi(ceili(float(current_day) / 4.0), 1, 48)


func get_time_label() -> String:
	return ["上午", "下午", "夜晚"][time_slot]


func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"day": day,
		"time_slot": time_slot,
		"chapter_id": chapter_id,
		"mutation": mutation,
		"story_flags": story_flags,
		"supplies": supplies,
		"materials": materials,
		"survivors": survivors,
		"active_survivor_ids": active_survivor_ids,
		"reserve_survivor_ids": reserve_survivor_ids,
		"formation_grid": formation_grid,
		"current_formation": current_formation,
		"explored_routes": explored_routes,
		"route_progress": route_progress,
		"reincarnation": reincarnation,
		"max_chapter_reached": max_chapter_reached,
		"highest_chapter_all_time": highest_chapter_all_time,
		"truth_progress": truth_progress,
		"reincarnation_marks": reincarnation_marks,
		"talent_points": talent_points,
		"boss_intel": boss_intel,
		"boss_kill_records": boss_kill_records,
		"reincarnation_memories": reincarnation_memories,
		"best_rating": best_rating,
		"last_rating": last_rating,
		"reincarnation_count": reincarnation_count
	}


# 从存档字典恢复数据
static func from_dict(data: Dictionary) -> PlayerData:
	var player := PlayerData.new()
	player.player_name = str(data.get("player_name", "陈末"))
	player.day = int(data.get("day", 1))
	player.time_slot = int(data.get("time_slot", 0))
	player.chapter_id = int(data.get("chapter_id", 1))
	player.mutation = int(data.get("mutation", 0))
	player.story_flags = data.get("story_flags", {})
	if player.story_flags is Dictionary:
		player.story_flags = player.story_flags.duplicate()
	player.supplies = data.get("supplies", {"food": 30, "medicine": 10})
	if player.supplies is Dictionary:
		player.supplies = player.supplies.duplicate()
	player.materials = data.get("materials", {})
	if player.materials is Dictionary:
		player.materials = player.materials.duplicate()
	player.survivors = data.get("survivors", [])
	if player.survivors is Array:
		player.survivors = player.survivors.duplicate(true)
	player.active_survivor_ids = data.get("active_survivor_ids", ["player_chenmo", "lin_mei"])
	if player.active_survivor_ids is Array:
		player.active_survivor_ids.assign(player.active_survivor_ids.map(func(id): return str(id)))
	player.reserve_survivor_ids = data.get("reserve_survivor_ids", [])
	if player.reserve_survivor_ids is Array:
		player.reserve_survivor_ids.assign(player.reserve_survivor_ids.map(func(id): return str(id)))
	player.formation_grid = data.get("formation_grid", [null, null, null, null, null, null, null, null, null])
	if player.formation_grid is Array:
		player.formation_grid = player.formation_grid.duplicate()
	player.current_formation = str(data.get("current_formation", "assault"))
	player.explored_routes = data.get("explored_routes", {})
	if player.explored_routes is Dictionary:
		player.explored_routes = player.explored_routes.duplicate()
	player.route_progress = data.get("route_progress", {})
	if player.route_progress is Dictionary:
		player.route_progress = player.route_progress.duplicate()
	# 轮回数据（旧存档兼容默认值）
	player.reincarnation = int(data.get("reincarnation", 1))
	player.max_chapter_reached = int(data.get("max_chapter_reached", player.chapter_id))
	player.highest_chapter_all_time = int(data.get("highest_chapter_all_time", player.max_chapter_reached))
	player.truth_progress = float(data.get("truth_progress", 0.0))
	player.reincarnation_marks = int(data.get("reincarnation_marks", 0))
	player.talent_points = int(data.get("talent_points", 0))
	player.boss_intel = data.get("boss_intel", {})
	if player.boss_intel is Dictionary:
		player.boss_intel = player.boss_intel.duplicate(true)
	player.boss_kill_records = data.get("boss_kill_records", {})
	if player.boss_kill_records is Dictionary:
		player.boss_kill_records = player.boss_kill_records.duplicate(true)
	player.reincarnation_memories = data.get("reincarnation_memories", [])
	if player.reincarnation_memories is Array:
		player.reincarnation_memories.assign(player.reincarnation_memories.map(func(m): return str(m)))
	player.best_rating = str(data.get("best_rating", ""))
	player.last_rating = str(data.get("last_rating", ""))
	player.reincarnation_count = int(data.get("reincarnation_count", 0))
	player._sync_grid_from_active_ids()
	return player


# ============================================================
# 九宫格编队系统方法
# ============================================================

# 获取指定格子的伙伴ID
func get_grid_survivor(grid_index: int) -> String:
	if grid_index >= 0 and grid_index < formation_grid.size():
		var survivor_id: Variant = formation_grid[grid_index]
		if survivor_id != null:
			return str(survivor_id)
	return ""


# 放置伙伴到指定格子
func place_survivor_on_grid(survivor_id: String, grid_index: int) -> bool:
	if grid_index < 0 or grid_index >= formation_grid.size():
		return false
	var replaced_survivor_id := get_grid_survivor(grid_index)
	# 检查该伙伴是否已在其他格子
	for i in range(formation_grid.size()):
		if formation_grid[i] == survivor_id:
			formation_grid[i] = null
	if replaced_survivor_id != "" and replaced_survivor_id != survivor_id and replaced_survivor_id not in reserve_survivor_ids:
		reserve_survivor_ids.append(replaced_survivor_id)
	# 从替补席移除该伙伴（如果存在）
	if survivor_id in reserve_survivor_ids:
		reserve_survivor_ids.erase(survivor_id)
	formation_grid[grid_index] = survivor_id
	_sync_active_ids_from_grid()
	return true


# 从格子移除伙伴
func remove_survivor_from_grid(grid_index: int) -> bool:
	if grid_index < 0 or grid_index >= formation_grid.size():
		return false
	var removed_survivor_id := get_grid_survivor(grid_index)
	if removed_survivor_id != "" and removed_survivor_id not in reserve_survivor_ids:
		reserve_survivor_ids.append(removed_survivor_id)
	formation_grid[grid_index] = null
	_sync_active_ids_from_grid()
	return true


# 清空所有格子
func clear_formation_grid() -> void:
	for i in range(formation_grid.size()):
		formation_grid[i] = null
	_sync_active_ids_from_grid()


# 获取当前出战伙伴ID列表（从九宫格同步）
func get_active_ids_from_grid() -> Array[String]:
	var result: Array[String] = []
	for i in range(formation_grid.size()):
		var survivor_id: Variant = formation_grid[i]
		if survivor_id != null:
			result.append(str(survivor_id))
	return result


# 同步 active_survivor_ids 与九宫格
func _sync_active_ids_from_grid() -> void:
	# 收集当前在九宫格上的伙伴
	var grid_ids: Array[String] = []
	for i in range(formation_grid.size()):
		var survivor_id: Variant = formation_grid[i]
		if survivor_id != null:
			grid_ids.append(str(survivor_id))

	# 原来在出战/替补中、但不在格子上的伙伴 → 放入替补席，避免丢失
	for existing_id in active_survivor_ids:
		if existing_id not in grid_ids and existing_id not in reserve_survivor_ids:
			reserve_survivor_ids.append(existing_id)

	# 替补席中已在格子上的伙伴 → 从替补席移除
	for existing_id in reserve_survivor_ids.duplicate():
		if existing_id in grid_ids:
			reserve_survivor_ids.erase(existing_id)

	# 出战列表 = 格子上的伙伴
	active_survivor_ids.clear()
	active_survivor_ids.append_array(grid_ids)


# 将出战伙伴同步到九宫格（初始化时使用）
func _sync_grid_from_active_ids() -> void:
	# 清空格子
	for i in range(formation_grid.size()):
		formation_grid[i] = null
	# 将出战伙伴依次放入格子（从第0格开始）
	var cell_index := 0
	for survivor_id in active_survivor_ids:
		if cell_index < formation_grid.size():
			formation_grid[cell_index] = survivor_id
			cell_index += 1


# 切换阵型
func switch_formation(formation_id: String) -> bool:
	if not formation_bonuses.has(formation_id):
		return false
	current_formation = formation_id
	return true


# 获取当前阵型加成
func get_formation_bonus() -> Dictionary:
	return formation_bonuses.get(current_formation, {})


# 获取阵型名称
func get_formation_name() -> String:
	match current_formation:
		"assault":
			return "强攻阵"
		"iron":
			return "铁壁阵"
		"wind":
			return "疾风阵"
	return "强攻阵"


# 获取格子位置描述
func get_grid_position_label(grid_index: int) -> String:
	match grid_index:
		0, 1, 2:
			return "前排"
		3, 4, 5:
			return "中排"
		6, 7, 8:
			return "后排"
	return ""


# 记录探索路线完成
func record_route_completed(route_id: String) -> void:
	explored_routes[route_id] = int(explored_routes.get(route_id, 0)) + 1


# 获取路线完成次数
func get_route_completed_count(route_id: String) -> int:
	return int(explored_routes.get(route_id, 0))


# 更新路线进度
func update_route_progress(route_id: String, node_index: int, completed: bool) -> void:
	route_progress[route_id] = {"node_index": node_index, "completed": completed}


# 获取路线进度
func get_route_progress(route_id: String) -> Dictionary:
	return route_progress.get(route_id, {"node_index": 0, "completed": false})


# ============================================================
# 轮回系统方法
# ============================================================

# 初始化所有配置中的Boss情报条目（旧存档兼容）
func _setup_default_boss_intel() -> void:
	if DataManager.main_story.is_empty():
		return
	var story_bosses: Array = DataManager.main_story.get("bosses", [])
	for boss_cfg in story_bosses:
		var boss_id: String = str(boss_cfg.get("id", ""))
		if boss_id == "":
			continue
		if not boss_intel.has(boss_id):
			boss_intel[boss_id] = {
				"encountered": false,
				"defeated": false,
				"kill_count": 0,
				"intel_unlocked": [],
				"lore_unlocked": false
			}


# 记录Boss遭遇
func record_boss_encounter(boss_id: String) -> void:
	_setup_default_boss_intel()
	if not boss_intel.has(boss_id):
		boss_intel[boss_id] = {
			"encountered": false, "defeated": false, "kill_count": 0,
			"intel_unlocked": [], "lore_unlocked": false
		}
	boss_intel[boss_id]["encountered"] = true
	# 首次遭遇解锁基础情报
	var intel_keys: Array = _get_intel_keys_for_stage(boss_id, "first_encounter")
	for key in intel_keys:
		if key not in boss_intel[boss_id]["intel_unlocked"]:
			boss_intel[boss_id]["intel_unlocked"].append(key)


# 记录Boss击败
func record_boss_defeat(boss_id: String) -> void:
	_setup_default_boss_intel()
	if not boss_intel.has(boss_id):
		boss_intel[boss_id] = {
			"encountered": true, "defeated": false, "kill_count": 0,
			"intel_unlocked": [], "lore_unlocked": false
		}
	boss_intel[boss_id]["encountered"] = true
	boss_intel[boss_id]["defeated"] = true
	boss_intel[boss_id]["kill_count"] = int(boss_intel[boss_id].get("kill_count", 0)) + 1
	boss_kill_records[boss_id] = int(boss_kill_records.get(boss_id, 0)) + 1
	# 击败解锁弱点情报与完整策略
	var intel_keys: Array = _get_intel_keys_for_stage(boss_id, "first_defeat")
	for key in intel_keys:
		if key not in boss_intel[boss_id]["intel_unlocked"]:
			boss_intel[boss_id]["intel_unlocked"].append(key)
	# 轮回轮次达到要求时解锁背景故事
	var boss_cfg := get_boss_config(boss_id)
	var lore_round: int = int(boss_cfg.get("intel", {}).get("lore_unlock_reincarnation", 0))
	if lore_round > 0 and reincarnation >= lore_round:
		boss_intel[boss_id]["lore_unlocked"] = true


# 获取指定阶段的Boss情报键
func _get_intel_keys_for_stage(boss_id: String, stage: String) -> Array:
	var boss_cfg := get_boss_config(boss_id)
	if boss_cfg.is_empty():
		return []
	var intel: Dictionary = boss_cfg.get("intel", {})
	var keys: Array = []
	match stage:
		"first_encounter":
			for info in intel.get("known_info", []):
				if info is Dictionary and info.get("confirmed", false):
					keys.append(str(info.get("key", "")))
		"first_defeat":
			for info in intel.get("weakness_info", []):
				if info is Dictionary and info.get("confirmed", true):
					keys.append(str(info.get("key", "")))
	return keys


# 获取Boss配置
func get_boss_config(boss_id: String) -> Dictionary:
	if DataManager.main_story.is_empty():
		return {}
	for boss_cfg in DataManager.main_story.get("bosses", []):
		if str(boss_cfg.get("id", "")) == boss_id:
			return boss_cfg
	return {}


# 获取Boss情报状态
func get_boss_intel_state(boss_id: String) -> Dictionary:
	_setup_default_boss_intel()
	if boss_intel.has(boss_id):
		return boss_intel[boss_id]
	return {"encountered": false, "defeated": false, "kill_count": 0, "intel_unlocked": [], "lore_unlocked": false}


# 获取Boss当前显示名称（未遭遇显示？？？）
func get_boss_display_name(boss_id: String) -> String:
	var boss_cfg := get_boss_config(boss_id)
	if boss_cfg.is_empty():
		return "？？？"
	var state := get_boss_intel_state(boss_id)
	if not bool(state.get("encountered", false)):
		return str(boss_cfg.get("intel", {}).get("initial_name", "？？？"))
	return str(boss_cfg.get("name", "？？？"))


# 检查Boss情报是否已解锁指定键
func has_boss_intel(boss_id: String, intel_key: String) -> bool:
	var state := get_boss_intel_state(boss_id)
	return intel_key in state.get("intel_unlocked", [])


# 获取Boss已解锁情报条目（用于图鉴显示）
func get_boss_unlocked_intel(boss_id: String) -> Array:
	var boss_cfg := get_boss_config(boss_id)
	if boss_cfg.is_empty():
		return []
	var state := get_boss_intel_state(boss_id)
	var unlocked_keys: Array = state.get("intel_unlocked", [])
	var result: Array = []
	var intel: Dictionary = boss_cfg.get("intel", {})
	for info in intel.get("known_info", []):
		if info is Dictionary and str(info.get("key", "")) in unlocked_keys:
			result.append({"label": info.get("key", ""), "value": info.get("value", "")})
	for info in intel.get("weakness_info", []):
		if info is Dictionary and str(info.get("key", "")) in unlocked_keys:
			result.append({"label": info.get("key", ""), "value": info.get("value", "")})
	if bool(state.get("lore_unlocked", false)) and intel.has("lore"):
		result.append({"label": "背景", "value": intel.get("lore", "")})
	return result


# 更新本轮最高章节
func update_max_chapter_reached() -> void:
	var story_chapters: Array = DataManager.main_story.get("chapters", [])
	var max_chapter := 0
	for ch in story_chapters:
		if int(ch.get("id", 0)) > max_chapter:
			max_chapter = int(ch.get("id", 0))
	if chapter_id > max_chapter_reached:
		max_chapter_reached = chapter_id
	# 判断通关主线即可提升真相进度（通关48章）
	if chapter_id >= max_chapter:
		truth_progress = clampf(truth_progress + float(DataManager.main_story.get("truth_progress", {}).get("unlock_per_reincarnation", 0.08)), 0.0, 1.0)
	if max_chapter_reached > highest_chapter_all_time:
		highest_chapter_all_time = max_chapter_reached
	# 根据章节推进同步Boss情报（到达Boss章节→遭遇，越过→击败）
	_sync_boss_intel_from_chapter()


# 根据主线章节推进同步Boss情报
func _sync_boss_intel_from_chapter() -> void:
	var chapters: Array = DataManager.main_story.get("chapters", [])
	for ch in chapters:
		var boss_id: String = str(ch.get("boss_id", ""))
		if boss_id == "":
			continue
		var ch_id: int = int(ch.get("id", 0))
		if chapter_id >= ch_id:
			record_boss_encounter(boss_id)
		if chapter_id > ch_id:
			record_boss_defeat(boss_id)


# 触发轮回记忆叙事事件
func try_trigger_reincarnation_event() -> Dictionary:
	var events: Array = DataManager.main_story.get("narrative_events", [])
	for event in events:
		var event_round: int = int(event.get("reincarnation", 0))
		var event_chapter: int = int(event.get("chapter", 0))
		var event_text: String = str(event.get("text", ""))
		var event_key: String = "round_%d_chapter_%d" % [event_round, event_chapter]
		if reincarnation == event_round and chapter_id == event_chapter:
			if event_key not in reincarnation_memories and event_text != "":
				reincarnation_memories.append(event_key)
				return {"triggered": true, "text": event_text, "chapter": event_chapter, "round": event_round}
	return {"triggered": false}


# ============================================================
# 轮回结算系统
# ============================================================

# 评级排序（S>A>B>C）
func _rating_rank(rating: String) -> int:
	match rating:
		"S":
			return 4
		"A":
			return 3
		"B":
			return 2
		_:
			return 1


# 计算本轮轮回评级
func calculate_rating() -> Dictionary:
	var story: Dictionary = DataManager.main_story
	var total_chapters: int = int(story.get("total_chapters", 48))
	var chapter_ratio: float = float(highest_chapter_all_time) / float(maxi(total_chapters, 1))
	var bosses: Array = story.get("bosses", [])
	var total_bosses: int = bosses.size()
	var killed_bosses: int = 0
	for boss_id in boss_kill_records:
		if int(boss_kill_records[boss_id]) > 0:
			killed_bosses += 1
	var rules: Dictionary = story.get("rating_rules", {})
	var rating: String = "C"
	for grade in ["S", "A", "B", "C"]:
		var rule: Dictionary = rules.get(grade, {})
		if rule.is_empty():
			continue
		var ok: bool = chapter_ratio >= float(rule.get("chapter_ratio", 0.0))
		if ok and bool(rule.get("kill_all_bosses", false)):
			ok = killed_bosses >= total_bosses
		elif ok and bool(rule.get("kill_half_bosses", false)):
			ok = killed_bosses >= int(ceil(float(total_bosses) / 2.0))
		elif ok and bool(rule.get("kill_one_boss", false)):
			ok = killed_bosses >= 1
		if ok:
			rating = grade
			break
	var rule: Dictionary = rules.get(rating, {})
	var marks_range: Array = rule.get("marks", [1, 2])
	var marks_min: int = int(marks_range[0]) if marks_range.size() > 0 else 1
	var marks_max: int = int(marks_range[1]) if marks_range.size() > 1 else marks_min
	var marks: int = randi_range(marks_min, marks_max)
	var talent: int = int(rule.get("talent_points", 0))
	return {
		"rating": rating,
		"chapter_ratio": chapter_ratio,
		"killed_bosses": killed_bosses,
		"total_bosses": total_bosses,
		"marks": marks,
		"talent_points": talent
	}


# 主动轮回：结算本轮成就，发放永久奖励，软死亡重置，进入下一轮
func perform_reincarnation() -> Dictionary:
	var rating_result: Dictionary = calculate_rating()
	var rating: String = str(rating_result.get("rating", "C"))
	var marks: int = int(rating_result.get("marks", 0))
	var talent: int = int(rating_result.get("talent_points", 0))
	# 发放永久奖励
	reincarnation_marks += marks
	talent_points += talent
	# 更新评级记录
	last_rating = rating
	if best_rating == "" or _rating_rank(rating) > _rating_rank(best_rating):
		best_rating = rating
	# 软死亡：保留永久数据，重置本轮临时数据
	_soft_reset_run_data()
	# 进入下一轮
	reincarnation += 1
	reincarnation_count += 1
	day = 1
	time_slot = 0
	chapter_id = 1
	max_chapter_reached = 1
	_sync_grid_from_active_ids()
	return rating_result


# 软死亡重置：清空本轮临时数据，保留永久数据
func _soft_reset_run_data() -> void:
	# 伙伴成长重置（等级/血量/能量/装备/星级/好感度/技能等级）
	for survivor in survivors:
		survivor["level"] = 1
		survivor["hp"] = float(survivor.get("max_hp", survivor.get("hp", 100)))
		survivor["energy"] = float(survivor.get("max_energy", 100))
		survivor["equipment"] = {"weapon": "", "armor": "", "accessory": ""}
		survivor["star"] = 1
		survivor["affinity"] = 0
		survivor["skill_levels"] = {}
		var skills: Array = survivor.get("skills", [])
		for i in range(skills.size()):
			var skill_ref: Variant = skills[i]
			if skill_ref is Dictionary:
				skill_ref["level"] = 1
				skills[i] = skill_ref
		if skills.size() > 0:
			survivor["skills"] = skills
	# 普通资源失去70%
	for key in supplies:
		var cap: int = maxi(int(resource_caps.get(key, 0)), 1)
		supplies[key] = clampi(int(round(float(supplies[key]) * 0.3)), 0, cap)
	for key in materials:
		var cap: int = maxi(int(resource_caps.get(key, 0)), 1)
		materials[key] = clampi(int(round(float(materials[key]) * 0.3)), 0, cap)
	# 编队重置：主角+林美出战，其余伙伴回替补
	active_survivor_ids = ["player_chenmo", "lin_mei"]
	reserve_survivor_ids = []
	for survivor in survivors:
		var sid: String = str(survivor.get("id", ""))
		if sid == "" or sid in active_survivor_ids:
			continue
		reserve_survivor_ids.append(sid)
	formation_grid = [null, null, null, null, null, null, null, null, null]
	_sync_grid_from_active_ids()
	# 地图状态重置
	explored_routes = {}
	route_progress = {}


# 获取轮回进度信息（用于UI展示）
func get_reincarnation_progress() -> Dictionary:
	var story: Dictionary = DataManager.main_story
	var total_chapters: int = int(story.get("total_chapters", 48))
	return {
		"reincarnation": reincarnation,
		"reincarnation_count": reincarnation_count,
		"max_chapter_reached": max_chapter_reached,
		"highest_chapter_all_time": highest_chapter_all_time,
		"total_chapters": total_chapters,
		"truth_progress": truth_progress,
		"reincarnation_marks": reincarnation_marks,
		"talent_points": talent_points,
		"best_rating": best_rating,
		"last_rating": last_rating
	}


# 获取Boss情报攻略进度（0.0~1.0）
func get_boss_intel_progress(boss_id: String) -> float:
	var boss_cfg := get_boss_config(boss_id)
	if boss_cfg.is_empty():
		return 0.0
	var state := get_boss_intel_state(boss_id)
	var intel: Dictionary = boss_cfg.get("intel", {})
	var known: Array = intel.get("known_info", [])
	var weakness: Array = intel.get("weakness_info", [])
	var total_items := known.size() + weakness.size()
	if total_items == 0:
		return 0.0
	var unlocked_keys: Array = state.get("intel_unlocked", [])
	var unlocked_count := 0
	for info in known:
		if info is Dictionary and str(info.get("key", "")) in unlocked_keys:
			unlocked_count += 1
	for info in weakness:
		if info is Dictionary and str(info.get("key", "")) in unlocked_keys:
			unlocked_count += 1
	return clampf(float(unlocked_count) / float(total_items), 0.0, 1.0)


# ============================================================
# Boss 动态属性公式与轮回词缀
# ============================================================

# 章节系数：1 + (章节编号-1) × 0.12
func _get_chapter_multiplier() -> float:
	return 1.0 + float(chapter_id - 1) * 0.12


# 章节区间难度系数
func _get_chapter_difficulty_multiplier() -> float:
	if chapter_id <= 8:
		return 1.0
	if chapter_id <= 16:
		return 2.4
	if chapter_id <= 24:
		return 4.8
	if chapter_id <= 32:
		return 9.6
	if chapter_id <= 40:
		return 19.2
	return 38.4


# 轮回系数：1 + (轮回次数-1) × 0.05
func _get_reincarnation_multiplier() -> float:
	return 1.0 + float(reincarnation - 1) * 0.05


# 计算Boss实际属性（动态公式：Base × 章节系数 × 难度系数 × 轮回系数）
func get_scaled_boss_stats(base_stats: Dictionary) -> Dictionary:
	var total_mult: float = _get_chapter_multiplier() * _get_chapter_difficulty_multiplier() * _get_reincarnation_multiplier()
	var result := {}
	for stat in base_stats:
		result[stat] = int(round(float(base_stats[stat]) * total_mult))
	return result


# 获取本轮Boss轮回词缀（随机分配，数量由 affix_count_by_reincarnation 决定）
func get_reincarnation_affixes() -> Array:
	var affix_pool: Array = DataManager.main_story.get("affix_pool", [])
	var count_by_round: Dictionary = DataManager.main_story.get("affix_count_by_reincarnation", {})
	var affix_count: int = int(count_by_round.get(str(reincarnation), 0))
	if affix_count <= 0:
		return []
	# 收集本轮已解锁的词缀
	var available: Array = []
	for affix in affix_pool:
		if affix is Dictionary and int(affix.get("unlock_reincarnation", 99)) <= reincarnation:
			available.append(affix)
	if available.is_empty():
		return []
	var result: Array = []
	var pool := available.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(mini(affix_count, pool.size())):
		var idx: int = rng.randi_range(0, pool.size() - 1)
		result.append(pool[idx])
		pool.remove_at(idx)
	return result


# ============================================================
# 伙伴养成系统方法
# ============================================================

# 根据ID获取伙伴
func get_partner_by_id(partner_id: String) -> Dictionary:
	for survivor in survivors:
		if survivor.get("id", "") == partner_id:
			return survivor
	return {}


# 确保伙伴拥有养成字段（旧存档兼容）
func _ensure_partner_training_fields(survivor: Dictionary) -> void:
	if not survivor.has("star"):
		survivor["star"] = 1
	if not survivor.has("affinity"):
		survivor["affinity"] = 0
	if not survivor.has("equipment"):
		survivor["equipment"] = {"weapon": "", "armor": "", "accessory": ""}
	if not survivor.has("skill_levels"):
		# 初始技能等级以技能配置中的level为准
		var levels := {}
		var skills: Array = survivor.get("skills", [])
		if skills.is_empty() and survivor.has("initial_skills"):
			skills = survivor["initial_skills"]
		for i in range(skills.size()):
			var skill_ref: Variant = skills[i]
			var skill_level := int(skill_ref.get("level", 1)) if skill_ref is Dictionary else 1
			levels[str(i)] = skill_level
		survivor["skill_levels"] = levels


# 获取伙伴好感度数值
func get_partner_affinity(partner_id: String) -> int:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return 0
	_ensure_partner_training_fields(partner)
	return int(partner.get("affinity", 0))


# 获取好感度等级信息
func get_affinity_level_info(affinity_value: int) -> Dictionary:
	var current := AFFINITY_LEVELS[0]
	for level_info in AFFINITY_LEVELS:
		if affinity_value >= int(level_info.get("threshold", 0)):
			current = level_info
		else:
			break
	return current


# 获取伙伴当前好感度等级
func get_partner_affinity_level(partner_id: String) -> int:
	var affinity_value := get_partner_affinity(partner_id)
	return int(get_affinity_level_info(affinity_value).get("level", 1))


# 获取好感度加成
func get_affinity_bonus(affinity_value: int) -> Dictionary:
	return get_affinity_level_info(affinity_value).get("bonus", {})


# 增加好感度（战斗中胜利等触发）
func add_partner_affinity(partner_id: String, amount: int) -> void:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return
	_ensure_partner_training_fields(partner)
	partner["affinity"] = int(partner.get("affinity", 0)) + amount


# 获取伙伴星级
func get_partner_star(partner_id: String) -> int:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return 1
	_ensure_partner_training_fields(partner)
	return int(partner.get("star", 1))


# 升星
func upgrade_partner_star(partner_id: String) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return {"success": false, "reason": "伙伴不存在"}
	_ensure_partner_training_fields(partner)
	var current_star := int(partner.get("star", 1))
	if current_star >= MAX_PARTNER_STAR:
		return {"success": false, "reason": "已满星"}
	var target_star := current_star + 1
	var cost: Dictionary = STAR_UP_COSTS.get(target_star, {})
	# 检查并扣除材料
	for material_id in cost:
		if int(materials.get(material_id, 0)) < int(cost[material_id]):
			return {"success": false, "reason": "材料不足", "cost": cost}
	for material_id in cost:
		materials[material_id] = int(materials.get(material_id, 0)) - int(cost[material_id])
	partner["star"] = target_star
	# 升星提升基础属性
	var star_bonus := 0.12 * (target_star - 1)  # 每星+12%全属性
	var stats: Dictionary = partner.get("stats", {})
	for stat_key in stats:
		stats[stat_key] = int(stats[stat_key] * (1.0 + star_bonus))
	partner["stats"] = stats
	return {"success": true, "star": target_star, "cost": cost}


# 装备物品
func equip_partner_item(partner_id: String, item_id: String) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return {"success": false, "reason": "伙伴不存在"}
	_ensure_partner_training_fields(partner)
	if item_id == "":
		return {"success": false, "reason": "物品无效"}
	var equipment: Dictionary = DataManager.get_equipment_by_id(item_id)
	if equipment.is_empty():
		return {"success": false, "reason": "装备不存在"}
	var slot: String = equipment.get("slot", "")
	if slot == "":
		return {"success": false, "reason": "装备类型无效"}
	partner["equipment"][slot] = item_id
	return {"success": true, "slot": slot, "item": equipment}


# 卸下装备
func unequip_partner_item(partner_id: String, slot: String) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return {"success": false, "reason": "伙伴不存在"}
	_ensure_partner_training_fields(partner)
	if not partner["equipment"].has(slot):
		return {"success": false, "reason": "装备槽无效"}
	var item_id: String = partner["equipment"][slot]
	if item_id == "":
		return {"success": false, "reason": "该槽位未装备"}
	partner["equipment"][slot] = ""
	return {"success": true, "slot": slot, "item_id": item_id}


# 获取伙伴装备加成
func get_partner_equipment_bonus(partner_id: String) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	var total := {"attack": 0, "defense": 0, "spirit": 0, "resistance": 0, "speed": 0}
	if partner.is_empty():
		return total
	_ensure_partner_training_fields(partner)
	var equipment: Dictionary = partner.get("equipment", {})
	for slot in equipment:
		var item_id: String = equipment[slot]
		if item_id == "":
			continue
		var item := DataManager.get_equipment_by_id(item_id)
		if item.is_empty():
			continue
		var item_stats: Dictionary = item.get("stats", {})
		for stat_key in item_stats:
			total[stat_key] = int(total.get(stat_key, 0)) + int(item_stats[stat_key])
	return total


# 获取伙伴完整属性加成（装备 + 好感度 + 星级）
func get_partner_effective_bonus(partner_id: String) -> Dictionary:
	var total := {"attack": 0, "defense": 0, "spirit": 0, "resistance": 0, "speed": 0}
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return total
	_ensure_partner_training_fields(partner)
	# 装备
	var equipment_bonus := get_partner_equipment_bonus(partner_id)
	for stat_key in equipment_bonus:
		total[stat_key] = int(total.get(stat_key, 0)) + int(equipment_bonus[stat_key])
	# 好感度
	var affinity_bonus := get_affinity_bonus(int(partner.get("affinity", 0)))
	for stat_key in affinity_bonus:
		total[stat_key] = int(total.get(stat_key, 0)) + int(affinity_bonus[stat_key])
	return total


# 获取伙伴有效属性（基础 + 加成）
func get_partner_effective_stats(partner_id: String) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	var result := {"attack": 0, "defense": 0, "spirit": 0, "resistance": 0, "speed": 0}
	if partner.is_empty():
		return result
	_ensure_partner_training_fields(partner)
	var base_stats: Dictionary = partner.get("stats", {})
	for stat_key in result:
		result[stat_key] = int(base_stats.get(stat_key, 0))
	var bonus := get_partner_effective_bonus(partner_id)
	for stat_key in bonus:
		result[stat_key] = int(result.get(stat_key, 0)) + int(bonus[stat_key])
	return result


# 升级技能
func upgrade_partner_skill(partner_id: String, skill_index: int) -> Dictionary:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return {"success": false, "reason": "伙伴不存在"}
	_ensure_partner_training_fields(partner)
	var skills: Array = partner.get("skills", [])
	if skills.is_empty() and partner.has("initial_skills"):
		skills = partner["initial_skills"]
		partner["skills"] = skills
	if skill_index < 0 or skill_index >= skills.size():
		return {"success": false, "reason": "技能索引无效"}
	var skill_ref: Dictionary = skills[skill_index]
	var current_level := int(skill_ref.get("level", 1))
	if current_level >= MAX_SKILL_LEVEL:
		return {"success": false, "reason": "已满级"}
	var cost: Dictionary = SKILL_UPGRADE_COSTS.get(current_level, {})
	for material_id in cost:
		if int(materials.get(material_id, 0)) < int(cost[material_id]):
			return {"success": false, "reason": "材料不足", "cost": cost}
	for material_id in cost:
		materials[material_id] = int(materials.get(material_id, 0)) - int(cost[material_id])
	skill_ref["level"] = current_level + 1
	skills[skill_index] = skill_ref
	partner["skills"] = skills
	partner["skill_levels"][str(skill_index)] = current_level + 1
	return {"success": true, "level": current_level + 1, "cost": cost}


# 获取技能等级
func get_partner_skill_level(partner_id: String, skill_index: int) -> int:
	var partner := get_partner_by_id(partner_id)
	if partner.is_empty():
		return 1
	_ensure_partner_training_fields(partner)
	var skills: Array = partner.get("skills", [])
	if skills.is_empty() and partner.has("initial_skills"):
		skills = partner["initial_skills"]
	if skill_index < 0 or skill_index >= skills.size():
		return 1
	var skill_ref: Dictionary = skills[skill_index]
	return int(skill_ref.get("level", 1))
