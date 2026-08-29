class_name StoreSystem
extends RefCounted
# ============================================================
# StoreSystem - 商城系统
# 职责：货币增扣、商品购买、限购校验、抽奖
# 数据源：data/configs/store_items.json
# ============================================================


# 获取商城配置
static func get_store_config() -> Dictionary:
	return DataManager.store_items


# 获取货币显示信息
static func get_currency_info(currency_id: String) -> Dictionary:
	var currency: Dictionary = DataManager.store_items.get("currency", {})
	if currency.has(currency_id):
		return currency[currency_id]
	return {"name": currency_id, "icon": ""}


# 查找商品（跨所有 tab）
static func find_item(item_id: String) -> Dictionary:
	var tabs: Array = DataManager.store_items.get("tabs", [])
	for tab in tabs:
		for item in tab.get("items", []):
			if str(item.get("id", "")) == item_id:
				return item
	return {}


# 检查商品是否可购买
static func check_availability(player: PlayerData, item: Dictionary) -> Dictionary:
	var price: Dictionary = item.get("price", {})
	for currency_id in price:
		var need := int(price[currency_id])
		if int(player.materials.get(currency_id, 0)) < need:
			var info := get_currency_info(currency_id)
			return {"available": false, "reason": "%s不足" % str(info.get("name", currency_id))}
	# 限购检查
	if str(item.get("limit", "")) == "once":
		if bool(player.story_flags.get("store_bought_" + str(item.get("id", "")), false)):
			return {"available": false, "reason": "已购买过（限购一次）"}
	return {"available": true, "reason": ""}


# 购买商品
static func purchase_item(player: PlayerData, item_id: String) -> Dictionary:
	var item := find_item(item_id)
	if item.is_empty():
		return {"success": false, "text": "商品不存在"}
	var check := check_availability(player, item)
	if not check.get("available", false):
		return {"success": false, "text": str(check.get("reason", "无法购买"))}
	# 扣除货币
	var price: Dictionary = item.get("price", {})
	for currency_id in price:
		deduct_currency(player, currency_id, int(price[currency_id]))
	# 发放奖励
	var reward: Dictionary = item.get("reward", {})
	for reward_id in reward:
		add_currency(player, reward_id, int(reward[reward_id]))
	# 标记限购
	if str(item.get("limit", "")) == "once":
		player.story_flags["store_bought_" + str(item.get("id", ""))] = true
	return {"success": true, "text": "购买成功", "reward": reward}


# 增加货币/资源（自动区分材料与消耗品）
static func add_currency(player: PlayerData, currency_id: String, amount: int) -> void:
	if currency_id in player.materials:
		player.add_resource(currency_id, amount)
	elif currency_id in player.supplies:
		player.add_resource(currency_id, amount)


# 扣除货币/资源
static func deduct_currency(player: PlayerData, currency_id: String, amount: int) -> bool:
	var current := 0
	if currency_id in player.materials:
		current = int(player.materials[currency_id])
	elif currency_id in player.supplies:
		current = int(player.supplies[currency_id])
	else:
		return false
	if current < amount:
		return false
	if currency_id in player.materials:
		player.add_resource(currency_id, -amount)
	else:
		player.add_resource(currency_id, -amount)
	return true


# 格式化价格文本
static func format_price(price: Dictionary) -> String:
	var parts: Array[String] = []
	for currency_id in price:
		var info := get_currency_info(currency_id)
		parts.append("%s %s×%d" % [str(info.get("icon", "")), str(info.get("name", currency_id)), int(price[currency_id])])
	return " + ".join(parts)


# 构建抽奖池（按稀有度分组，排除主角和隐藏伙伴）
static func get_gacha_pool() -> Dictionary:
	var pool := {"SSR": [], "SR": [], "R": []}
	for partner in DataManager.partners:
		var partner_id := str(partner.get("id", ""))
		var rarity := str(partner.get("rarity", ""))
		if partner_id == "player_chenmo" or rarity == "隐藏":
			continue
		if pool.has(rarity):
			pool[rarity].append(partner)
	return pool


# 单次抽取（SSR 3% / SR 12% / R 85%）
static func _gacha_once(pool: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var roll := rng.randf()
	var rarity := "R"
	if roll < 0.03:
		rarity = "SSR"
	elif roll < 0.15:
		rarity = "SR"
	var candidates: Array = pool.get(rarity, [])
	if candidates.is_empty():
		if not pool.get("SR", []).is_empty():
			rarity = "SR"
			candidates = pool["SR"]
		elif not pool.get("R", []).is_empty():
			rarity = "R"
			candidates = pool["R"]
	if candidates.is_empty():
		return {}
	var idx := rng.randi_range(0, candidates.size() - 1)
	var partner: Dictionary = candidates[idx]
	return partner.duplicate(true)


# 执行抽奖（times 次，10 连保底至少一个 SR 及以上）
static func do_gacha(player: PlayerData, times: int) -> Dictionary:
	if int(player.materials.get("tickets", 0)) < times:
		return {"success": false, "text": "补给券不足"}
	deduct_currency(player, "tickets", times)

	var pool := get_gacha_pool()
	var results: Array = []
	var has_sr_or_above := false
	for i in range(times):
		var result := _gacha_once(pool)
		if result.is_empty():
			continue
		results.append(result)
		var rarity := str(result.get("rarity", ""))
		if rarity == "SSR" or rarity == "SR":
			has_sr_or_above = true

	# 10 连保底：至少一个 SR 或以上
	if times >= 10 and not has_sr_or_above and not pool.get("SR", []).is_empty():
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		var sr_pool: Array = pool["SR"]
		var idx := rng.randi_range(0, sr_pool.size() - 1)
		if not results.is_empty():
			results[results.size() - 1] = sr_pool[idx].duplicate(true)

	# 招募新伙伴（去重）
	var recruited: Array = []
	for result in results:
		var partner_id := str(result.get("id", ""))
		if partner_id == "":
			continue
		var is_new := true
		for survivor in player.survivors:
			if str(survivor.get("id", "")) == partner_id:
				is_new = false
				break
		if is_new:
			player.survivors.append(result)
			if not (partner_id in player.reserve_survivor_ids):
				player.reserve_survivor_ids.append(partner_id)
		recruited.append({"id": partner_id, "name": str(result.get("name", "")), "rarity": str(result.get("rarity", "")), "is_new": is_new})

	return {"success": true, "text": "抽奖完成", "results": recruited}

