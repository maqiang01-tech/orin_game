class_name ExplorationSystem
extends RefCounted

# 探索路线状态机
# 节点类型: search(搜索) / battle(战斗) / branch(分支) / boss(BOSS) / shop(商店) / recruit(招募)
# 节点状态: locked(锁定) / available(可用) / completed(已完成) / failed(失败)

var routes: Array = []
var route_states: Dictionary = {}  # route_id -> {node_id: state}
var current_route: Dictionary = {}
var current_node_index: int = 0
var exploration_log: Array[String] = []

# 兼容 game_manager.gd 的引用
var player: PlayerData
var data_manager: Node


func _init() -> void:
	_load_routes()


func _load_routes() -> void:
	var raw_data: Variant = DataManager.load_json_file("res://data/configs/exploration_routes.json")
	if raw_data is Array:
		routes = raw_data
		_init_route_states()


func _init_route_states() -> void:
	for route in routes:
		var route_id: String = route.get("id", "")
		var node_states: Dictionary = {}
		for node in route.get("nodes", []):
			node_states[node.get("id", "")] = "available"
		route_states[route_id] = node_states


func get_available_routes(current_day: int) -> Array:
	var available: Array = []
	for route in routes:
		var unlock_day: int = route.get("unlock_day", 1)
		if current_day >= unlock_day:
			available.append(route)
	return available


func get_routes_by_region(region_id: int, current_day: int) -> Array:
	var result: Array = []
	for route in routes:
		if route.get("region_id", 0) == region_id and current_day >= route.get("unlock_day", 1):
			result.append(route)
	return result


func get_regions() -> Array:
	var regions: Array = []
	var seen: Dictionary = {}
	for route in routes:
		var region_id: int = route.get("region_id", 0)
		if not seen.has(region_id):
			seen[region_id] = true
			regions.append({
				"id": region_id,
				"name": route.get("region", ""),
				"route_count": _count_routes_in_region(region_id)
			})
	return regions


func _count_routes_in_region(region_id: int) -> int:
	var count: int = 0
	for route in routes:
		if route.get("region_id", 0) == region_id:
			count += 1
	return count


func start_route(route_id: String) -> bool:
	for route in routes:
		if route.get("id", "") == route_id:
			current_route = route
			current_node_index = 0
			exploration_log.clear()
			exploration_log.append("开始探索: " + route.get("name", ""))
			return true
	return false


func get_current_node() -> Dictionary:
	if current_route.is_empty():
		return {}
	var nodes: Array = current_route.get("nodes", [])
	if current_node_index < nodes.size():
		return nodes[current_node_index]
	return {}


func advance_to_next_node() -> bool:
	current_node_index += 1
	var nodes: Array = current_route.get("nodes", [])
	return current_node_index < nodes.size()


func is_route_complete() -> bool:
	var nodes: Array = current_route.get("nodes", [])
	return current_node_index >= nodes.size()


func get_node_state(route_id: String, node_id: String) -> String:
	if route_states.has(route_id):
		var node_states: Dictionary = route_states[route_id]
		if node_states.has(node_id):
			return node_states[node_id]
	return "locked"


func set_node_state(route_id: String, node_id: String, state: String) -> void:
	if route_states.has(route_id):
		var node_states: Dictionary = route_states[route_id]
		node_states[node_id] = state


func process_node(node: Dictionary, player: PlayerData) -> Dictionary:
	"""
	处理当前节点，返回结果字典:
	{
		"type": "search" | "battle" | "branch" | "boss" | "shop" | "recruit" | "complete",
		"text": 描述文本,
		"effects": 已应用的效果,
		"battle_id": 战斗ID(如果是战斗),
		"options": 分支选项(如果是branch),
		"trades": 交易列表(如果是shop),
		"join_partner": 加入的伙伴ID(如果是recruit)
	}
	"""
	var node_type: String = node.get("type", "search")
	var route_id: String = current_route.get("id", "")
	var node_id: String = node.get("id", "")

	match node_type:
		"search":
			var effects: Dictionary = node.get("effects", {})
			_apply_effects(effects, player)
			# 处理概率效果
			if node.has("chance_effects"):
				var chance_effects: Dictionary = node.get("chance_effects", {})
				var chance: float = chance_effects.get("chance", 0.0)
				if randf() < chance:
					var bonus: Dictionary = {}
					for key in chance_effects:
						if key != "chance":
							bonus[key] = chance_effects[key]
					_apply_effects(bonus, player)
					effects.merge(bonus)
			set_node_state(route_id, node_id, "completed")
			exploration_log.append("搜索: " + node.get("text", ""))
			return {"type": "search", "text": node.get("text", ""), "effects": effects}

		"battle":
			set_node_state(route_id, node_id, "completed")
			exploration_log.append("战斗: " + node.get("text", ""))
			return {
				"type": "battle",
				"text": node.get("text", ""),
				"battle_id": node.get("battle_id", ""),
				"effects": node.get("effects", {})
			}

		"boss":
			set_node_state(route_id, node_id, "completed")
			exploration_log.append("BOSS战: " + node.get("text", ""))
			return {
				"type": "boss",
				"text": node.get("text", ""),
				"battle_id": node.get("battle_id", ""),
				"effects": node.get("effects", {}),
				"join_partner": node.get("join_partner", "")
			}

		"branch":
			exploration_log.append("分支: " + node.get("text", ""))
			return {
				"type": "branch",
				"text": node.get("text", ""),
				"options": node.get("options", [])
			}

		"shop":
			exploration_log.append("商店: " + node.get("text", ""))
			return {
				"type": "shop",
				"text": node.get("text", ""),
				"trades": node.get("trades", [])
			}

		"recruit":
			var cost: Dictionary = node.get("cost", {})
			if _can_afford(cost, player):
				_apply_effects(cost, player)
				set_node_state(route_id, node_id, "completed")
				exploration_log.append("招募: " + node.get("text", ""))
				return {
					"type": "recruit",
					"text": node.get("text", ""),
					"join_partner": node.get("join_partner", ""),
					"result": node.get("result", "")
				}
			else:
				return {
					"type": "recruit_failed",
					"text": node.get("text", ""),
					"result": "资源不足，无法招募。"
				}

	return {"type": "complete", "text": "探索完成"}


func process_branch_option(option: Dictionary, player: PlayerData) -> Dictionary:
	"""
	处理分支选项，返回结果:
	{
		"type": "battle" | "effect" | "recruit" | "ending",
		"text": 结果文本,
		"effects": 已应用的效果,
		"battle_id": 战斗ID(如果是战斗),
		"join_partner": 加入的伙伴ID(如果是招募),
		"ending": 结局ID(如果是结局)
	}
	"""
	var effects: Dictionary = option.get("effects", {})
	_apply_effects(effects, player)

	var result: Dictionary = {
		"type": "effect",
		"text": option.get("result", ""),
		"effects": effects
	}

	if option.has("battle_id"):
		result["type"] = "battle"
		result["battle_id"] = option.get("battle_id", "")

	if option.has("join_partner"):
		result["type"] = "recruit"
		result["join_partner"] = option.get("join_partner", "")

	if option.has("ending"):
		result["type"] = "ending"
		result["ending"] = option.get("ending", "")

	exploration_log.append("选择: " + option.get("text", ""))
	return result


func process_shop_trade(trade: Dictionary, player: PlayerData) -> Dictionary:
	"""
	处理商店交易，返回结果:
	{
		"success": bool,
		"text": 结果文本,
		"cost": 消耗的资源,
		"reward": 获得的奖励
	}
	"""
	var cost: Dictionary = trade.get("cost", {})
	if not _can_afford(cost, player):
		return {"success": false, "text": "资源不足，无法交易。"}

	_apply_effects(cost, player)
	var reward: Dictionary = trade.get("reward", {})
	_apply_effects(reward, player)

	exploration_log.append("交易成功")
	return {
		"success": true,
		"text": "交易成功。",
		"cost": cost,
		"reward": reward
	}


func _apply_effects(effects: Dictionary, player: PlayerData) -> void:
	for key in effects:
		var value: Variant = effects[key]
		match key:
			"food", "medicine", "cores", "memory_shards", "tickets", "spirit_battery", "ammo", "rare_material", "spirit_core":
				player.add_resource(key, int(value))
			"hp_cost":
				# 百分比HP消耗，由战斗系统处理
				pass
			"speed_penalty":
				# 速度惩罚，由战斗系统处理
				pass
			"equipment", "item", "relic", "skill_book":
				# 物品获取，由物品系统处理
				player.story_flags["item_" + str(key) + "_" + str(value)] = true
			"unlock_route", "unlock_boss", "unlock_chapter":
				player.story_flags[key] = value
			"camp_reputation":
				player.story_flags["camp_reputation"] = int(player.story_flags.get("camp_reputation", 0)) + int(value)
			"intel":
				player.story_flags["intel_" + str(value)] = true


func _can_afford(cost: Dictionary, player: PlayerData) -> bool:
	for key in cost:
		var amount: int = int(cost[key])
		if amount > 0:
			var current: int = 0
			if key in player.supplies:
				current = player.supplies[key]
			elif key in player.materials:
				current = player.materials[key]
			if current < amount:
				return false
	return true


func get_exploration_log() -> Array[String]:
	return exploration_log


# ============================================================
# 兼容 game_manager.gd 的 API 方法
# ============================================================

# 开始探索（接收路线字典）
func start_exploration(route: Dictionary) -> bool:
	if route.is_empty():
		return false
	current_route = route
	current_node_index = 0
	exploration_log.clear()
	exploration_log.append("开始探索: " + route.get("name", ""))
	return true


# 获取当前路线
func get_current_route() -> Dictionary:
	return current_route


# 获取当前节点索引
func get_current_node_index() -> int:
	return current_node_index


# 推进到下一个节点
func advance_node() -> bool:
	current_node_index += 1
	var nodes: Array = current_route.get("nodes", [])
	return current_node_index < nodes.size()


# 完成探索
func finish_exploration() -> void:
	if player != null and not current_route.is_empty():
		var route_id: String = current_route.get("id", "")
		if route_id != "":
			player.record_route_completed(route_id)
	current_route = {}
	current_node_index = 0


# 放弃探索
func abandon_exploration() -> void:
	current_route = {}
	current_node_index = 0


# 是否正在探索中
func is_exploring() -> bool:
	return not current_route.is_empty()
