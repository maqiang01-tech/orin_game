class_name DungeonManager
extends RefCounted

# ============================================================
# 多层随机地牢系统 - 核心管理器
# 包含楼层生成算法、地牢创建、存档管理等
# ============================================================

# ---------- 数据类 ----------

class DungeonConfig:
	var id: String = ""
	var name: String = ""
	var icon: String = ""
	var min_floors: int = 3
	var max_floors: int = 6
	var grid_size_min: int = 5
	var grid_size_max: int = 6
	var obstacle_density: float = 0.25
	var enemy_count_min: int = 2
	var enemy_count_max: int = 4
	var loot_count_min: int = 1
	var loot_count_max: int = 3
	var boss_on_last_floor: bool = true
	var boss_interval: Variant = null
	var reward_interval: Variant = null
	var exit_penalty: String = "none"
	var recommended_level: int = 1
	var difficulty_increment: float = 0.15
	var special_room_chance: float = 0.08
	var loot_quality_base: String = "common"
	var loot_quality_improve_rate: float = 0.15
	var trap_chance: float = 0.0
	var enemy_types: Array = []
	var boss_types: Array = []
	var is_endless: bool = false

	func to_dict() -> Dictionary:
		return {
			"id": id, "name": name, "icon": icon,
			"min_floors": min_floors, "max_floors": max_floors,
			"grid_size_min": grid_size_min, "grid_size_max": grid_size_max,
			"obstacle_density": obstacle_density,
			"enemy_count_min": enemy_count_min, "enemy_count_max": enemy_count_max,
			"loot_count_min": loot_count_min, "loot_count_max": loot_count_max,
			"boss_on_last_floor": boss_on_last_floor,
			"boss_interval": boss_interval, "reward_interval": reward_interval,
			"exit_penalty": exit_penalty, "recommended_level": recommended_level,
			"difficulty_increment": difficulty_increment,
			"special_room_chance": special_room_chance,
			"loot_quality_base": loot_quality_base,
			"loot_quality_improve_rate": loot_quality_improve_rate,
			"trap_chance": trap_chance,
			"enemy_types": enemy_types, "boss_types": boss_types,
			"is_endless": is_endless
		}


class CellData:
	var row: int = 0
	var col: int = 0
	var terrain: String = "floor"  # floor / wall / ruins / rock / tree / grass / trap
	var content: Variant = null    # null / "player" / "enemy" / "loot" / "stair_down" / "stair_up" / "special"
	var walkable: bool = true
	var enemy_id: String = ""
	var loot_item: String = ""
	var loot_qty: int = 1
	var special_type: String = ""
	var is_visible: bool = false
	var has_player: bool = false


class FloorData:
	var floor_number: int = 1
	var status: String = "pending"  # pending / active / cleared
	var grid: Array = []            # 2D Array[row][col] of CellData
	var enemies_remaining: int = 0
	var loot_remaining: int = 0
	var has_stair_up: bool = false
	var has_stair_down: bool = false
	var stair_up_pos: Vector2i = Vector2i.ZERO
	var stair_down_pos: Vector2i = Vector2i.ZERO
	var player_start_pos: Vector2i = Vector2i.ZERO
	var is_boss_floor: bool = false
	var is_reward_floor: bool = false
	var theme: String = ""
	var difficulty_multiplier: float = 1.0
	var enemy_entities: Dictionary = {}  # "enemy_pos_key" -> {"id": String, "is_elite": bool, "is_boss": bool}
	var loot_entities: Dictionary = {}   # "pos_key" -> {"item": String, "qty": int}


class DungeonData:
	var dungeon_id: String = ""
	var dungeon_type: String = ""
	var total_floors: int = 3
	var current_floor: int = 1
	var max_reached_floor: int = 1
	var floors: Dictionary = {}  # floor_number(int) -> FloorData
	var seed: int = 0
	var is_completed: bool = false
	var config: DungeonConfig = null
	var total_enemies_killed: int = 0
	var total_loot_collected: int = 0
	var total_time_spent_hours: float = 0.0

	func to_dict() -> Dictionary:
		return {
			"dungeon_id": dungeon_id,
			"dungeon_type": dungeon_type,
			"total_floors": total_floors,
			"current_floor": current_floor,
			"max_reached_floor": max_reached_floor,
			"seed": seed,
			"is_completed": is_completed,
			"total_enemies_killed": total_enemies_killed,
			"total_loot_collected": total_loot_collected,
			"total_time_spent_hours": total_time_spent_hours
		}


# ---------- 核心变量 ----------

var current_dungeon: DungeonData = null
var current_floor_data: FloorData = null
var all_dungeon_configs: Dictionary = {}  # id -> DungeonConfig
var configs_loaded: bool = false
var active_random_dungeons: Array = []    # 大地图随机地牢列表

const SAVE_DIR := "user://dungeons/"
const MAX_FLOOR_RETRY := 5

# 物资品质与物品表
const LOOT_TABLE := {
	"common": ["food", "medicine", "crystal_small", "ammo"],
	"uncommon": ["food", "medicine", "crystal", "ammo", "cores"],
	"rare": ["crystal", "equipment_blue", "skill_book", "rare_material"],
	"epic": ["crystal_large", "equipment_purple", "relic_fragment", "spirit_core"],
	"legendary": ["crystal_core", "equipment_gold", "relic_complete", "spirit_core"]
}

# 特殊房间类型及权重
const SPECIAL_ROOM_TYPES := ["chest_room", "merchant_room", "rest_room", "shrine_room", "portal_room"]
const SPECIAL_ROOM_WEIGHTS := [0.30, 0.15, 0.20, 0.20, 0.15]


# ============================================================
# 配置加载
# ============================================================

func _init() -> void:
	load_configs()


func load_configs() -> void:
	var raw_data: Variant = DataManager.load_json_file("res://data/configs/dungeon_types.json")
	if raw_data == null or not raw_data.has("dungeon_types"):
		push_error("无法加载地牢配置 dungeon_types.json")
		return

	all_dungeon_configs.clear()
	for config_data in raw_data["dungeon_types"]:
		var config := DungeonConfig.new()
		config.id = config_data.get("id", "")
		config.name = config_data.get("name", "")
		config.icon = config_data.get("icon", "")
		config.min_floors = int(config_data.get("min_floors", 3))
		config.max_floors = int(config_data.get("max_floors", 6))
		config.grid_size_min = int(config_data.get("grid_size_min", 5))
		config.grid_size_max = int(config_data.get("grid_size_max", 6))
		config.obstacle_density = float(config_data.get("obstacle_density", 0.25))
		config.enemy_count_min = int(config_data.get("enemy_count_min", 2))
		config.enemy_count_max = int(config_data.get("enemy_count_max", 4))
		config.loot_count_min = int(config_data.get("loot_count_min", 1))
		config.loot_count_max = int(config_data.get("loot_count_max", 3))
		config.boss_on_last_floor = bool(config_data.get("boss_on_last_floor", true))
		config.boss_interval = config_data.get("boss_interval", null)
		config.reward_interval = config_data.get("reward_interval", null)
		config.exit_penalty = config_data.get("exit_penalty", "none")
		config.recommended_level = int(config_data.get("recommended_level", 1))
		config.difficulty_increment = float(config_data.get("difficulty_increment", 0.15))
		config.special_room_chance = float(config_data.get("special_room_chance", 0.08))
		config.loot_quality_base = config_data.get("loot_quality_base", "common")
		config.loot_quality_improve_rate = float(config_data.get("loot_quality_improve_rate", 0.15))
		config.trap_chance = float(config_data.get("trap_chance", 0.0))
		config.enemy_types = config_data.get("enemy_types", [])
		config.boss_types = config_data.get("boss_types", [])
		config.is_endless = config.id == "endless_tower"
		all_dungeon_configs[config.id] = config

	configs_loaded = true


# ============================================================
# 地牢情报（大地图POI使用）
# ============================================================

func get_all_dungeon_configs() -> Array:
	return all_dungeon_configs.values()


func get_dungeon_config(dungeon_id: String) -> DungeonConfig:
	return all_dungeon_configs.get(dungeon_id, null)


func get_dungeon_info_list() -> Array:
	var result: Array = []
	for config: DungeonConfig in all_dungeon_configs.values():
		result.append({
			"id": config.id,
			"name": config.name,
			"icon": config.icon,
			"min_floors": config.min_floors,
			"max_floors": config.max_floors,
			"grid_size_min": config.grid_size_min,
			"grid_size_max": config.grid_size_max,
			"recommended_level": config.recommended_level,
			"difficulty_increment": config.difficulty_increment,
			"exit_penalty": config.exit_penalty,
			"has_save": has_saved_dungeon(config.id)
		})
	return result


# ============================================================
# 地牢创建与进入
# ============================================================

func create_new_dungeon(dungeon_type_id: String, seed_value: int = -1) -> DungeonData:
	var config: DungeonConfig = all_dungeon_configs.get(dungeon_type_id, null)
	if config == null:
		push_error("未知地牢类型: " + dungeon_type_id)
		return null

	var rng := RandomNumberGenerator.new()
	if seed_value == -1:
		seed_value = randi()
	rng.seed = seed_value

	var data := DungeonData.new()
	data.dungeon_id = generate_unique_id()
	data.dungeon_type = dungeon_type_id
	data.seed = seed_value
	data.config = config

	# 无尽妖塔固定 99 层，其它随机层数
	if config.is_endless:
		data.total_floors = 99
	else:
		data.total_floors = rng.randi_range(config.min_floors, config.max_floors)

	data.current_floor = 1
	data.max_reached_floor = 1
	data.is_completed = false

	# 预创建所有楼层占位数据（网格在进入时才生成）
	for floor_num in range(1, data.total_floors + 1):
		var floor_data := FloorData.new()
		floor_data.floor_number = floor_num
		floor_data.status = "pending"
		floor_data.is_boss_floor = _is_boss_floor(floor_num, data.total_floors, config)
		floor_data.is_reward_floor = _is_reward_floor(floor_num, config)
		floor_data.theme = _get_floor_theme(floor_num)
		floor_data.difficulty_multiplier = _calc_difficulty_multiplier(floor_num, config)
		data.floors[floor_num] = floor_data

	return data


func enter_dungeon(dungeon_id: String) -> bool:
	# 有存档则续关，否则新开
	if has_saved_dungeon(dungeon_id):
		current_dungeon = load_dungeon_from_save(dungeon_id)
	else:
		current_dungeon = create_new_dungeon(dungeon_id)

	if current_dungeon == null:
		return false

	current_floor_data = enter_floor(current_dungeon, current_dungeon.current_floor)
	return current_floor_data != null


func exit_dungeon(force: bool = false) -> void:
	if current_dungeon == null:
		return

	var config: DungeonConfig = current_dungeon.config
	if force and current_dungeon.current_floor > 1:
		_apply_exit_penalty(config)

	# 无尽塔记录最高层并重置到第 1 层
	if config.is_endless:
		current_dungeon.max_reached_floor = max(current_dungeon.max_reached_floor, current_dungeon.current_floor)
		if current_dungeon.current_floor >= 1:
			current_dungeon.current_floor = 1
		current_dungeon.is_completed = false
		for floor_num in current_dungeon.floors.keys():
			if int(floor_num) > 1:
				current_dungeon.floors[int(floor_num)].status = "pending"

	# 保存进度
	save_current_dungeon()


# ============================================================
# 楼层生成
# ============================================================

func enter_floor(data: DungeonData, floor_num: int) -> FloorData:
	if not data.floors.has(floor_num):
		return null

	var floor_data: FloorData = data.floors[floor_num]
	if floor_data.status == "pending" or floor_data.grid.is_empty():
		floor_data = generate_floor(floor_num, data.config, data.total_floors, data.seed + floor_num)
		data.floors[floor_num] = floor_data

	floor_data.status = "active"
	data.current_floor = floor_num
	data.max_reached_floor = max(data.max_reached_floor, floor_num)
	current_floor_data = floor_data
	return floor_data


func generate_floor(
	floor_num: int,
	config: DungeonConfig,
	total_floors: int,
	seed_value: int,
	retry_count: int = 0
) -> FloorData:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var floor_data := FloorData.new()
	floor_data.floor_number = floor_num
	floor_data.status = "active"
	floor_data.is_boss_floor = _is_boss_floor(floor_num, total_floors, config)
	floor_data.is_reward_floor = _is_reward_floor(floor_num, config)
	floor_data.theme = _get_floor_theme(floor_num)
	floor_data.difficulty_multiplier = _calc_difficulty_multiplier(floor_num, config)

	# --- 1. 网格尺寸（随层数递增） ---
	var grid_size: int = config.grid_size_min
	if floor_num > 5:
		grid_size = mini(config.grid_size_max, config.grid_size_min + int(floor_num / 5))
	var rows := grid_size
	var cols := grid_size

	# --- 2. 初始化网格（全部地板） ---
	var grid: Array = []
	for r in range(rows):
		var row: Array = []
		for c in range(cols):
			var cell := CellData.new()
			cell.row = r
			cell.col = c
			cell.terrain = "floor"
			cell.content = null
			cell.walkable = true
			cell.is_visible = false
			row.append(cell)
		grid.append(row)

	# --- 3. 边界墙壁 ---
	for r in range(rows):
		_make_wall(grid[r][0])
		_make_wall(grid[r][cols - 1])
	for c in range(cols):
		_make_wall(grid[0][c])
		_make_wall(grid[rows - 1][c])

	# --- 4. 随机障碍物（避让边界，密度随层数增加） ---
	var obstacle_density := minf(config.obstacle_density + (floor_num - 1) * 0.01, 0.50)
	var obstacle_count: int = int((rows - 2) * (cols - 2) * obstacle_density)
	var terrain_choices := ["ruins", "rock", "tree", "grass"]
	for i in range(obstacle_count):
		var r: int = rng.randi_range(1, rows - 2)
		var c: int = rng.randi_range(1, cols - 2)
		var cell: CellData = grid[r][c]
		if cell.walkable and cell.content == null:
			cell.terrain = terrain_choices[rng.randi_range(0, terrain_choices.size() - 1)]
			cell.walkable = false

	# --- 5. 放置下楼点 ---
	var stair_down_pos: Vector2i = _find_valid_position(grid, rows, cols, rng)
	_set_cell_content(grid, stair_down_pos, "stair_down")
	floor_data.stair_down_pos = stair_down_pos
	floor_data.has_stair_down = true

	# --- 6. 放置玩家起点（与楼梯相对角落） ---
	var player_start_pos: Vector2i = _find_position_opposite_to(grid, rows, cols, stair_down_pos, rng)
	_set_cell_content(grid, player_start_pos, "player")
	floor_data.player_start_pos = player_start_pos

	# --- 7. 奖励层（无尽妖塔：无敌人，只有宝箱） ---
	if floor_data.is_reward_floor:
		for i in range(3):
			var pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos])
			_set_special_cell(grid, pos, "reward_chest")
			floor_data.loot_remaining += 1
			floor_data.loot_entities[str(pos)] = {"item": "reward_chest", "qty": 1}
		floor_data.enemies_remaining = 0
		floor_data.grid = grid
		return floor_data

	# --- 8. 放置敌人 ---
	if floor_data.is_boss_floor:
		# BOSS层: 1 BOSS + 2 精英护卫
		var boss_pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos])
		_set_enemy(grid, boss_pos, _get_boss_id(config), true, true)
		floor_data.enemy_entities[str(boss_pos)] = {"id": _get_boss_id(config), "is_elite": false, "is_boss": true}
		floor_data.enemies_remaining += 1

		for i in range(2):
			var elite_pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos, boss_pos])
			var elite_id: String = _select_enemy_by_difficulty(config.enemy_types, floor_data.difficulty_multiplier, rng)
			_set_enemy(grid, elite_pos, elite_id, true, false)
			floor_data.enemy_entities[str(elite_pos)] = {"id": elite_id, "is_elite": true, "is_boss": false}
			floor_data.enemies_remaining += 1
	else:
		var enemy_count: int = _calc_enemy_count(floor_num, config, rng)
		for i in range(enemy_count):
			var pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos])
			var enemy_id: String = _select_enemy_by_difficulty(config.enemy_types, floor_data.difficulty_multiplier, rng)
			_set_enemy(grid, pos, enemy_id, false, false)
			floor_data.enemy_entities[str(pos)] = {"id": enemy_id, "is_elite": false, "is_boss": false}
			floor_data.enemies_remaining += 1

	# --- 9. 放置物资 ---
	var loot_count: int = _calc_loot_count(floor_num, config, rng)
	if floor_data.is_boss_floor:
		loot_count += 2

	for i in range(loot_count):
		var pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos])
		var quality: String = _get_loot_quality(floor_num, config)
		var item: String = _select_loot_by_quality(quality, rng)
		var qty: int = rng.randi_range(1, 3)
		_set_loot(grid, pos, item, qty)
		floor_data.loot_entities[str(pos)] = {"item": item, "qty": qty}
		floor_data.loot_remaining += 1

	# --- 10. 特殊房间（概率触发） ---
	if not floor_data.is_boss_floor and rng.randf() < config.special_room_chance:
		var special_pos: Vector2i = _find_valid_position(grid, rows, cols, rng, [player_start_pos, stair_down_pos])
		var room_type: String = _select_special_room_type(rng)
		_set_special_cell(grid, special_pos, room_type)

	# --- 11. 陷阱（地窟/遗迹特有） ---
	if config.trap_chance > 0.0:
		for r in range(1, rows - 1):
			for c in range(1, cols - 1):
				var cell: CellData = grid[r][c]
				if cell.walkable and cell.content == null and rng.randf() < config.trap_chance:
					cell.terrain = "trap"

	# --- 12. 连通性校验（BFS） ---
	if not _is_path_connected(grid, player_start_pos, stair_down_pos):
		if retry_count < MAX_FLOOR_RETRY:
			return generate_floor(floor_num, config, total_floors, seed_value + 1000, retry_count + 1)
		push_warning("楼层 %d 连通性校验失败，使用当前结果" % floor_num)

	floor_data.grid = grid
	return floor_data


# ============================================================
# 辅助函数 - 网格操作
# ============================================================

func _make_wall(cell: CellData) -> void:
	cell.terrain = "wall"
	cell.walkable = false


func _set_cell_content(grid: Array, pos: Vector2i, content: String) -> void:
	var cell: CellData = grid[pos.x][pos.y]
	cell.content = content
	cell.terrain = "floor"
	cell.walkable = true


func _set_enemy(grid: Array, pos: Vector2i, enemy_id: String, is_elite: bool, is_boss: bool) -> void:
	var cell: CellData = grid[pos.x][pos.y]
	cell.content = "enemy"
	cell.enemy_id = enemy_id
	cell.walkable = true  # 可进入触发战斗


func _set_loot(grid: Array, pos: Vector2i, item: String, qty: int) -> void:
	var cell: CellData = grid[pos.x][pos.y]
	cell.content = "loot"
	cell.loot_item = item
	cell.loot_qty = qty


func _set_special_cell(grid: Array, pos: Vector2i, special_type: String) -> void:
	var cell: CellData = grid[pos.x][pos.y]
	cell.content = "special"
	cell.special_type = special_type


func _find_valid_position(
	grid: Array,
	rows: int,
	cols: int,
	rng: RandomNumberGenerator,
	exclude_positions: Array = []
) -> Vector2i:
	for attempts in range(100):
		var r: int = rng.randi_range(1, rows - 2)
		var c: int = rng.randi_range(1, cols - 2)
		var pos := Vector2i(r, c)
		var excluded := false
		for ex in exclude_positions:
			if pos == ex:
				excluded = true
				break
		if not excluded:
			var cell: CellData = grid[r][c]
			if cell.walkable and cell.content == null:
				return pos
	return Vector2i(1, 1)


func _find_position_opposite_to(
	grid: Array,
	rows: int,
	cols: int,
	target: Vector2i,
	rng: RandomNumberGenerator
) -> Vector2i:
	# 在目标对角方向的象限中找起点
	var half_rows: int = int(rows / 2)
	var half_cols: int = int(cols / 2)
	var quadrants := [
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	var possible_positions: Array = []
	for q in quadrants:
		var r: int = clampi(target.x + q.x * half_rows, 1, rows - 2)
		var c: int = clampi(target.y + q.y * half_cols, 1, cols - 2)
		var cell: CellData = grid[r][c]
		if cell.walkable and cell.content == null:
			possible_positions.append(Vector2i(r, c))

	if possible_positions.is_empty():
		return _find_valid_position(grid, rows, cols, rng, [target])
	return possible_positions[rng.randi_range(0, possible_positions.size() - 1)]


func _is_path_connected(grid: Array, start: Vector2i, end: Vector2i) -> bool:
	var rows: int = grid.size()
	var cols: int = grid[0].size()
	var visited: Array = []
	for r in range(rows):
		var row: Array = []
		for c in range(cols):
			row.append(false)
		visited.append(row)

	var queue: Array = [start]
	visited[start.x][start.y] = true
	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		if current == end:
			return true

		for d in directions:
			var nr: int = current.x + d.x
			var nc: int = current.y + d.y
			if nr >= 0 and nr < rows and nc >= 0 and nc < cols:
				if not visited[nr][nc]:
					var cell: CellData = grid[nr][nc]
					if cell.walkable:
						visited[nr][nc] = true
						queue.append(Vector2i(nr, nc))

	return false


# ============================================================
# 辅助函数 - 数值计算
# ============================================================

func _calc_difficulty_multiplier(floor_num: int, config: DungeonConfig) -> float:
	return 1.0 + (floor_num - 1) * config.difficulty_increment


func _calc_enemy_count(floor_num: int, config: DungeonConfig, rng: RandomNumberGenerator) -> int:
	var base: int = rng.randi_range(config.enemy_count_min, config.enemy_count_max)
	var extra: int = int(floor_num / 3)
	return mini(base + extra, config.enemy_count_max + 3)


func _calc_loot_count(floor_num: int, config: DungeonConfig, rng: RandomNumberGenerator) -> int:
	var base: int = rng.randi_range(config.loot_count_min, config.loot_count_max)
	var extra: int = int(floor_num / 4)
	return mini(base + extra, config.loot_count_max + 3)


func _is_boss_floor(floor_num: int, total_floors: int, config: DungeonConfig) -> bool:
	if config.boss_on_last_floor:
		return floor_num == total_floors
	if config.boss_interval != null:
		return floor_num % int(config.boss_interval) == 0 and floor_num > 0
	return false


func _is_reward_floor(floor_num: int, config: DungeonConfig) -> bool:
	if config.reward_interval != null:
		return floor_num % int(config.reward_interval) == 0 and floor_num > 0
	return false


func _get_loot_quality(floor_num: int, config: DungeonConfig) -> String:
	var qualities := ["common", "uncommon", "rare", "epic", "legendary"]
	var index: int = int((floor_num - 1) * config.loot_quality_improve_rate)
	return qualities[clampi(index, 0, qualities.size() - 1)]


func _select_enemy_by_difficulty(
	enemy_types: Array,
	multiplier: float,
	rng: RandomNumberGenerator
) -> String:
	if enemy_types.is_empty():
		return ""
	var threshold: float = clampf(multiplier / 2.0, 0.0, 1.0)
	if rng.randf() < threshold and enemy_types.size() > 1:
		return str(enemy_types[enemy_types.size() - 1])
	return str(enemy_types[rng.randi_range(0, enemy_types.size() - 1)])


func _select_loot_by_quality(quality: String, rng: RandomNumberGenerator) -> String:
	var pool: Array = LOOT_TABLE.get(quality, LOOT_TABLE["common"])
	return str(pool[rng.randi_range(0, pool.size() - 1)])


func _select_special_room_type(rng: RandomNumberGenerator) -> String:
	var total: float = 0.0
	for w in SPECIAL_ROOM_WEIGHTS:
		total += w
	var roll: float = rng.randf()
	var acc: float = 0.0
	for i in range(SPECIAL_ROOM_TYPES.size()):
		acc += SPECIAL_ROOM_WEIGHTS[i] / total
		if roll <= acc:
			return SPECIAL_ROOM_TYPES[i]
	return SPECIAL_ROOM_TYPES[0]


func _get_boss_id(config: DungeonConfig) -> String:
	if config.boss_types.is_empty():
		return "generic_boss"
	return str(config.boss_types[0])


func _get_floor_theme(floor_num: int) -> String:
	if floor_num <= 3:
		return "surface_ruins"
	elif floor_num <= 6:
		return "underground_cavern"
	elif floor_num <= 9:
		return "deep_fissure"
	elif floor_num <= 15:
		return "abyss_core"
	return "void_abyss"


func generate_unique_id() -> String:
	return "dg_%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]


# ============================================================
# 退出惩罚
# ============================================================

func _apply_exit_penalty(config: DungeonConfig) -> void:
	match config.exit_penalty:
		"lose_uncollected":
			# 未拾取的物资丢失（自然丢失，无需额外处理）
			pass
		"reset_to_floor_1":
			current_dungeon.current_floor = 1
		"lose_20_percent_loot":
			# 由外部系统调用 GameState.player 随机损失 20% 物资
			if GameState.player != null:
				var player := GameState.player
				# 消耗品损失 20%
				for res_key in ["food", "medicine"]:
					var current: int = player.supplies.get(res_key, 0)
					if current > 0:
						var loss: int = maxi(1, int(floor(current * 0.2)))
						player.add_resource(res_key, -loss)
				# 材料损失 20%
				for res_key in ["cores", "memory_shards", "tickets", "spirit_battery", "ammo", "rare_material", "spirit_core"]:
					var current: int = player.materials.get(res_key, 0)
					if current > 0:
						var loss: int = maxi(1, int(floor(current * 0.2)))
						player.add_resource(res_key, -loss)
				print("地牢退出惩罚：损失 20%% 物资")


# ============================================================
# 存档系统
# ============================================================

func get_save_path(dungeon_id: String) -> String:
	return SAVE_DIR + "dungeon_" + dungeon_id + ".json"


func has_saved_dungeon(dungeon_id: String) -> bool:
	return FileAccess.file_exists(get_save_path(dungeon_id))


func save_current_dungeon() -> void:
	if current_dungeon == null:
		return

	var data := current_dungeon.to_dict()
	data["floors"] = {}
	for floor_num in current_dungeon.floors.keys():
		var floor: FloorData = current_dungeon.floors[floor_num]
		data["floors"][str(floor_num)] = {
			"status": floor.status,
			"enemies_remaining": floor.enemies_remaining,
			"loot_remaining": floor.loot_remaining,
			"is_boss_floor": floor.is_boss_floor,
			"is_reward_floor": floor.is_reward_floor,
			"difficulty_multiplier": floor.difficulty_multiplier,
			"theme": floor.theme
		}

	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var save_path := get_save_path(current_dungeon.dungeon_type)
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("无法保存地牢进度: " + save_path)
		return
	file.store_string(JSON.stringify(data, "  "))


func load_dungeon_from_save(dungeon_id: String) -> DungeonData:
	var file := FileAccess.open(get_save_path(dungeon_id), FileAccess.READ)
	if file == null:
		return null

	var json: String = file.get_as_text()
	var data: Dictionary = JSON.parse_string(json)
	if data.is_empty():
		return null

	var config: DungeonConfig = all_dungeon_configs.get(data.get("dungeon_type", ""), null)
	if config == null:
		return null

	var dungeon := DungeonData.new()
	dungeon.dungeon_id = data.get("dungeon_id", dungeon_id)
	dungeon.dungeon_type = data.get("dungeon_type", "")
	dungeon.total_floors = int(data.get("total_floors", 3))
	dungeon.current_floor = int(data.get("current_floor", 1))
	dungeon.max_reached_floor = int(data.get("max_reached_floor", 1))
	dungeon.seed = int(data.get("seed", 0))
	dungeon.is_completed = bool(data.get("is_completed", false))
	dungeon.total_enemies_killed = int(data.get("total_enemies_killed", 0))
	dungeon.total_loot_collected = int(data.get("total_loot_collected", 0))
	dungeon.total_time_spent_hours = float(data.get("total_time_spent_hours", 0.0))
	dungeon.config = config

	var saved_floors: Dictionary = data.get("floors", {})
	for floor_key in saved_floors.keys():
		var floor_num := int(floor_key)
		var floor_info: Dictionary = saved_floors[floor_key]
		var floor: FloorData = null

		var status: String = floor_info.get("status", "pending")
		if status == "pending":
			floor = FloorData.new()
			floor.floor_number = floor_num
			floor.status = "pending"
			floor.is_boss_floor = _is_boss_floor(floor_num, dungeon.total_floors, config)
			floor.is_reward_floor = _is_reward_floor(floor_num, config)
			floor.theme = _get_floor_theme(floor_num)
			floor.difficulty_multiplier = _calc_difficulty_multiplier(floor_num, config)
		else:
			floor = generate_floor(floor_num, config, dungeon.total_floors, dungeon.seed + floor_num)
			floor.status = status
			floor.enemies_remaining = int(floor_info.get("enemies_remaining", floor.enemies_remaining))
			floor.loot_remaining = int(floor_info.get("loot_remaining", floor.loot_remaining))

		dungeon.floors[floor_num] = floor

	return dungeon


func clear_saved_dungeon(dungeon_id: String) -> void:
	var path := get_save_path(dungeon_id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


# ============================================================
# 大地图随机地牢 POI
# ============================================================

func refresh_random_dungeons(count: int = 3) -> Array:
	active_random_dungeons.clear()
	var configs: Array = all_dungeon_configs.values()
	if configs.is_empty():
		return active_random_dungeons

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(count):
		var config: DungeonConfig = configs[rng.randi_range(0, configs.size() - 1)]
		active_random_dungeons.append({
			"poi_id": "random_dungeon_" + str(i),
			"dungeon_type": config.id,
			"name": config.name,
			"icon": config.icon,
			"floors": "%d~%d层" % [config.min_floors, config.max_floors],
			"recommended_level": config.recommended_level
		})
	return active_random_dungeons
