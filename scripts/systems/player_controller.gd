class_name PlayerController
extends RefCounted

# ============================================================
# 玩家控制器 - 地牢内小地图移动与交互
# 处理：网格移动、战斗/拾取/楼梯/特殊房间触发、楼层切换
# ============================================================

signal floor_changed(new_floor_data)
signal battle_started(enemy_id)
signal loot_collected(item, qty)
signal floor_completed()
signal dungeon_completed(reward)
signal message(text)

var current_position: Vector2i = Vector2i.ZERO
var dungeon_manager: DungeonManager
var current_floor_data: DungeonManager.FloorData = null
var grid: Array = []  # 当前层网格引用（Array of Array of CellData）
var rows: int = 0
var cols: int = 0
var moves: int = 0

# 玩家数据引用
var player: PlayerData


func _init(dm: DungeonManager, player_data: PlayerData = null) -> void:
	dungeon_manager = dm
	player = player_data


# ============================================================
# 初始化 - 进入当前层
# ============================================================
func initialize(floor_data: DungeonManager.FloorData) -> void:
	current_floor_data = floor_data
	grid = floor_data.grid
	rows = grid.size()
	if rows > 0:
		cols = (grid[0] as Array).size()
	else:
		cols = 0
	current_position = floor_data.player_start_pos
	moves = 0


# ============================================================
# 移动
# ============================================================
func move_player(direction: Vector2) -> Dictionary:
	"""
	方向：(1,0)下 / (-1,0)上 / (0,1)右 / (0,-1)左
	返回结果字典：{"moved": bool, "event": String, "data": {...}}
	"""
	var new_row: int = current_position.x + int(direction.x)
	var new_col: int = current_position.y + int(direction.y)

	# 边界检查
	if new_row < 0 or new_row >= rows or new_col < 0 or new_col >= cols:
		return {"moved": false, "event": "blocked", "data": {"reason": "boundary"}}

	# 目标格检查
	var target_cell: DungeonManager.CellData = _get_cell(new_row, new_col)
	if target_cell == null:
		return {"moved": false, "event": "blocked", "data": {"reason": "out_of_grid"}}
	if not target_cell.walkable:
		return {"moved": false, "event": "blocked", "data": {"reason": "obstacle"}}

	# 移动
	var old_cell: DungeonManager.CellData = _get_cell(current_position.x, current_position.y)
	if old_cell != null:
		old_cell.has_player = false
		# 只清除玩家标记，不覆盖原有内容
		if old_cell.content == "player":
			old_cell.content = null

	current_position = Vector2i(new_row, new_col)
	target_cell.has_player = true
	moves += 1

	# 检查目标格内容
	match target_cell.content:
		"enemy":
			return {"moved": true, "event": "enemy", "data": {"enemy_id": target_cell.enemy_id}}
		"loot":
			var item: String = target_cell.loot_item
			var qty: int = target_cell.loot_qty
			_clear_cell_content(target_cell)
			target_cell.content = null
			current_floor_data.loot_remaining = maxi(0, current_floor_data.loot_remaining - 1)
			return {"moved": true, "event": "loot", "data": {"item": item, "qty": qty}}
		"stair_down":
			return {"moved": true, "event": "stair_down", "data": {}}
		"stair_up":
			return {"moved": true, "event": "stair_up", "data": {}}
		"special":
			return {"moved": true, "event": "special", "data": {"special_type": target_cell.special_type}}
		_:
			# 检查陷阱
			if target_cell.terrain == "trap":
				return {"moved": true, "event": "trap", "data": {}}
			return {"moved": true, "event": "empty", "data": {}}


# ============================================================
# 战斗结果处理
# ============================================================
func on_battle_won(enemy_id: String) -> void:
	# 移除指定敌人（当前脚下一格）
	var cell: DungeonManager.CellData = _get_cell(current_position.x, current_position.y)
	if cell != null and cell.content == "enemy" and cell.enemy_id == enemy_id:
		_clear_cell_content(cell)
		cell.content = null
		cell.walkable = true
		current_floor_data.enemies_remaining = maxi(0, current_floor_data.enemies_remaining - 1)

	_check_floor_completion()


func on_battle_lost() -> void:
	# 战败处理：由上层游戏逻辑处理（如损失物资/复活）
	pass


# ============================================================
# 拾取物资（战斗胜利后清理脚下物资格时使用）
# ============================================================
func collect_current_loot() -> Dictionary:
	var cell: DungeonManager.CellData = _get_cell(current_position.x, current_position.y)
	if cell != null and cell.content == "loot":
		var item: String = cell.loot_item
		var qty: int = cell.loot_qty
		_clear_cell_content(cell)
		cell.content = null
		current_floor_data.loot_remaining = maxi(0, current_floor_data.loot_remaining - 1)
		return {"item": item, "qty": qty}
	return {}


# ============================================================
# 楼层切换
# ============================================================
func go_to_next_floor() -> Dictionary:
	"""
	返回：{"success": bool, "is_complete": bool, "message": String}
	"""
	var dungeon: DungeonManager.DungeonData = dungeon_manager.current_dungeon
	if dungeon == null:
		return {"success": false, "is_complete": false, "message": "未在地牢中。"}

	var total_floors: int = dungeon.total_floors
	var next_floor: int = current_floor_data.floor_number + 1

	if next_floor > total_floors:
		# 已到最底层，通关
		return complete_dungeon()

	# 标记当前层已清除
	current_floor_data.status = "cleared"

	# 通过地牢管理器进入下一层（返回 FloorData 对象）
	var new_floor: DungeonManager.FloorData = dungeon_manager.enter_floor(dungeon, next_floor)
	if new_floor == null:
		return {"success": false, "is_complete": false, "message": "进入下一层失败。"}

	current_floor_data = new_floor
	_after_floor_change()
	return {"success": true, "is_complete": false, "message": "进入第 %d 层" % next_floor}


func go_to_previous_floor() -> Dictionary:
	var prev_floor: int = current_floor_data.floor_number - 1
	if prev_floor < 1:
		return {"success": false, "is_complete": false, "message": "已在第一层，无法继续上楼。"}

	var dungeon: DungeonManager.DungeonData = dungeon_manager.current_dungeon
	if dungeon == null:
		return {"success": false, "is_complete": false, "message": "未在地牢中。"}

	var new_floor: DungeonManager.FloorData = dungeon_manager.enter_floor(dungeon, prev_floor)
	if new_floor == null:
		return {"success": false, "is_complete": false, "message": "返回上一层失败。"}

	current_floor_data = new_floor
	_after_floor_change()
	return {"success": true, "is_complete": false, "message": "回到第 %d 层" % prev_floor}


func _after_floor_change() -> void:
	grid = current_floor_data.grid
	rows = grid.size()
	if rows > 0:
		cols = (grid[0] as Array).size()
	else:
		cols = 0
	current_position = current_floor_data.player_start_pos
	moves = 0
	floor_changed.emit(current_floor_data)


# ============================================================
# 地牢通关
# ============================================================
func complete_dungeon() -> Dictionary:
	var dungeon: DungeonManager.DungeonData = dungeon_manager.current_dungeon
	if dungeon == null:
		return {"success": false, "is_complete": false, "message": "未在地牢中。"}

	dungeon.is_completed = true

	# 计算通关奖励
	var reward: Dictionary = _calc_completion_reward()
	dungeon_completed.emit(reward)
	return {"success": true, "is_complete": true, "message": "地牢通关！", "reward": reward}


func _calc_completion_reward() -> Dictionary:
	var dungeon: DungeonManager.DungeonData = dungeon_manager.current_dungeon
	if dungeon == null or dungeon.config == null:
		return {"food": 5, "tickets": 3, "crystals": 2}

	var config: DungeonManager.DungeonConfig = dungeon.config
	var base_reward: Dictionary = {
		"food": 5,
		"tickets": 3,
		"crystals": 2
	}
	# 按地牢难度系数缩放
	var difficulty: float = config.difficulty_increment
	base_reward["crystals"] = int(base_reward["crystals"] * (1.0 + difficulty * 4.0))
	return base_reward


# ============================================================
# 退出地牢
# ============================================================
func exit_dungeon() -> Dictionary:
	"""
	主动退出地牢。返回：{"success": bool, "penalty": String}
	"""
	var dungeon: DungeonManager.DungeonData = dungeon_manager.current_dungeon
	if dungeon == null:
		return {"success": false, "penalty": "none", "message": "未在地牢中。"}

	var config: DungeonManager.DungeonConfig = dungeon.config
	var penalty: String = config.exit_penalty if config != null else "none"

	var penalty_desc := ""
	match penalty:
		"reset_to_floor_1":
			dungeon.current_floor = 1
			penalty_desc = "无尽妖塔进度已重置至第1层。"
		"lose_20_percent_loot":
			if player != null:
				_lose_random_percent_loot(0.2)
			penalty_desc = "退出惩罚：损失20%物资。"
		_:
			penalty_desc = "退出地牢，进度已保存。"

	# 保存进度（DungeonManager 内部会保存 current_dungeon）
	dungeon_manager.save_current_dungeon()
	return {"success": true, "penalty": penalty, "message": penalty_desc}


func _lose_random_percent_loot(percent: float) -> void:
	if player == null:
		return
	for key in player.supplies:
		var current: int = player.supplies[key]
		if current > 0:
			var lose: int = int(current * percent)
			if lose > 0:
				player.supplies[key] = current - lose
	for key in player.materials:
		var current: int = player.materials[key]
		if current > 0:
			var lose: int = int(current * percent)
			if lose > 0:
				player.materials[key] = current - lose


# ============================================================
# 楼层完成检查
# ============================================================
func _check_floor_completion() -> void:
	if current_floor_data.enemies_remaining <= 0 and current_floor_data.loot_remaining <= 0:
		floor_completed.emit()


# ============================================================
# 特殊房间处理
# ============================================================
func process_special_room(special_type: String, player_data: PlayerData) -> Dictionary:
	"""
	处理特殊房间，返回：{"success": bool, "text": String, "rewards": {...}}
	"""
	match special_type:
		"chest_room":
			var reward: Dictionary = _generate_chest_reward()
			if player_data != null:
				_apply_reward(reward, player_data)
			return {"success": true, "text": "打开宝箱，获得：", "rewards": reward}
		"rest_room":
			if player_data != null:
				for survivor in player_data.survivors:
					survivor["hp"] = survivor.get("max_hp", survivor.get("hp", 0))
			return {"success": true, "text": "在休息点恢复体力，全体伙伴HP回满。", "rewards": {}}
		"merchant_room":
			return {"success": true, "text": "商人房间（交易功能待实现）。", "rewards": {}}
		"shrine_room":
			return {"success": true, "text": "祭坛房间（祝福功能待实现）。", "rewards": {}}
		"portal_room":
			return {"success": true, "text": "传送门房间（跳转功能待实现）。", "rewards": {}}
		_:
			return {"success": false, "text": "未知特殊房间。", "rewards": {}}


func _generate_chest_reward() -> Dictionary:
	var reward_pool: Array = [
		{"food": 3}, {"medicine": 2}, {"tickets": 2},
		{"crystals": 1}, {"ammo": 3}, {"rare_material": 1}
	]
	var roll: int = randi_range(0, reward_pool.size() - 1)
	return reward_pool[roll]


func _apply_reward(reward: Dictionary, player_data: PlayerData) -> void:
	for key in reward:
		player_data.add_resource(key, int(reward[key]))


# ============================================================
# 工具函数
# ============================================================
func _get_cell(row: int, col: int) -> DungeonManager.CellData:
	if row < 0 or row >= rows or col < 0 or col >= cols:
		return null
	if grid.size() == 0:
		return null
	var row_data: Variant = grid[row]
	if row_data is Array and col < (row_data as Array).size():
		var cell: Variant = (row_data as Array)[col]
		if cell is DungeonManager.CellData:
			return cell
	return null


func _clear_cell_content(cell: DungeonManager.CellData) -> void:
	cell.has_player = false


# ============================================================
# 网格工具（供UI渲染使用）
# ============================================================
func get_grid() -> Array:
	return grid


func get_grid_rows() -> int:
	return rows


func get_grid_cols() -> int:
	return cols


func get_current_pos() -> Vector2i:
	return current_position


func get_cell_at(row: int, col: int) -> DungeonManager.CellData:
	return _get_cell(row, col)
