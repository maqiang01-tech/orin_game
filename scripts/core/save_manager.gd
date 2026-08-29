extends Node
# ============================================================
# SaveManager - 存档管理器
# 职责：分离「当前轮进度」与「永久进度」，支撑轮回机制的继承逻辑
# 存档位置：user://（Godot 用户数据目录）
#   - current_save.json  当前轮数据（轮回时重置）
#   - meta_save.json     永久数据（跨轮回保留）
# ============================================================

const CURRENT_SAVE_PATH := "user://current_save.json"
const META_SAVE_PATH := "user://meta_save.json"

# 永久数据字段（跨轮回保留，其余字段视为当前轮临时数据）
const META_KEYS: Array[String] = [
	"reincarnation", "reincarnation_count", "reincarnation_marks",
	"talent_points", "boss_intel", "boss_kill_records",
	"reincarnation_memories", "best_rating", "last_rating",
	"truth_progress", "highest_chapter_all_time", "story_completed",
	"story_flags"
]


# 初始化存档（检查是否存在，无则不做处理，由 GameState 新建默认数据）
func init_saves() -> void:
	pass


# 保存当前轮存档
func save_current_save(player: PlayerData) -> void:
	var data: Dictionary = player.to_dict()
	var current_data: Dictionary = {}
	for key in data:
		if key not in META_KEYS:
			current_data[key] = data[key]
	_write_json(CURRENT_SAVE_PATH, current_data)


# 保存永久存档
func save_meta_save(player: PlayerData) -> void:
	var data: Dictionary = player.to_dict()
	var meta_data: Dictionary = {}
	for key in META_KEYS:
		if data.has(key):
			meta_data[key] = data[key]
	_write_json(META_SAVE_PATH, meta_data)


# 保存全部（当前轮 + 永久）
func save_all(player: PlayerData) -> void:
	save_current_save(player)
	save_meta_save(player)


# 加载当前轮存档
func load_current_save() -> Dictionary:
	return _read_json(CURRENT_SAVE_PATH)


# 加载永久存档
func load_meta_save() -> Dictionary:
	return _read_json(META_SAVE_PATH)


# 加载完整存档（当前轮 + 永久合并，永久覆盖）
func load_all() -> Dictionary:
	var data := load_current_save()
	var meta := load_meta_save()
	for key in meta:
		data[key] = meta[key]
	return data


# 重置当前轮（轮回软死亡时调用）
func reset_current_save() -> void:
	_delete_file(CURRENT_SAVE_PATH)


# 重置全部进度（重新开始）
func reset_meta_save() -> void:
	_delete_file(CURRENT_SAVE_PATH)
	_delete_file(META_SAVE_PATH)


# 检查存档是否存在
func has_current_save() -> bool:
	return FileAccess.file_exists(CURRENT_SAVE_PATH)


func has_meta_save() -> bool:
	return FileAccess.file_exists(META_SAVE_PATH)


# 内部：写 JSON
func _write_json(path: String, data: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: 无法写入存档 " + path)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


# 内部：读 JSON
func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("SaveManager: 存档解析失败 " + path)
		return {}
	var data: Variant = json.data
	return data if data is Dictionary else {}


# 内部：删除文件
func _delete_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
