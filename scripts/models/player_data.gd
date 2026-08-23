class_name PlayerData
extends RefCounted

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


func _init() -> void:
	# 确保九宫格与初始出战阵容保持一致，避免上阵时人物丢失
	_sync_grid_from_active_ids()


func advance_half_day() -> void:
	time_slot += 1
	if time_slot >= 3:
		time_slot = 0
		day += 1
	chapter_id = _chapter_for_day(day)


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
	if current_day <= 3:
		return 1
	if current_day <= 6:
		return 2
	if current_day <= 10:
		return 3
	if current_day <= 15:
		return 4
	if current_day <= 20:
		return 5
	if current_day <= 27:
		return 6
	if current_day <= 35:
		return 7
	if current_day <= 45:
		return 8
	if current_day <= 55:
		return 9
	if current_day <= 60:
		return 10
	if current_day <= 70:
		return 11
	if current_day <= 80:
		return 12
	if current_day <= 90:
		return 13
	if current_day <= 100:
		return 14
	if current_day <= 110:
		return 15
	if current_day <= 120:
		return 16
	if current_day <= 130:
		return 17
	if current_day <= 140:
		return 18
	if current_day <= 150:
		return 19
	if current_day <= 160:
		return 20
	if current_day <= 170:
		return 21
	if current_day <= 185:
		return 22
	if current_day <= 200:
		return 23
	return 24


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
		"route_progress": route_progress
	}


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
