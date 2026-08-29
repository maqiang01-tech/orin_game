extends Node
# ============================================================
# SceneManager - 场景管理器
# 职责：场景切换（带淡入淡出）、重载、预加载、当前场景查询
# ============================================================

var current_scene: Node = null
var _preloaded: Dictionary = {}  # path -> PackedScene
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false


func _ready() -> void:
	# 创建全局淡入淡出遮罩层（持久于所有场景之上）
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_layer.add_child(_fade_rect)


# 切换场景（淡出 → 切换 → 淡入）
func goto_scene(scene_path: String, fade_time: float = 0.3) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade_to(1.0, fade_time)
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneManager: 场景切换失败 " + scene_path)
		_is_transitioning = false
		await _fade_to(0.0, fade_time)
		return
	await _fade_to(0.0, fade_time)
	_is_transitioning = false
	current_scene = get_tree().current_scene


# 重载当前场景
func reload_current_scene() -> void:
	var scene: Node = get_tree().current_scene
	if scene != null:
		goto_scene(scene.scene_file_path)


# 预加载场景（提升后续切换速度）
func preload_scene(path: String) -> void:
	if path in _preloaded:
		return
	var packed: Variant = load(path)
	if packed is PackedScene:
		_preloaded[path] = packed


# 获取当前场景实例
func get_current_scene() -> Node:
	return get_tree().current_scene


# 是否正在切换场景
func is_transitioning() -> bool:
	return _is_transitioning


# 内部：渐变到目标透明度
func _fade_to(target_alpha: float, duration: float) -> void:
	if duration <= 0.0:
		_fade_rect.color = Color(0, 0, 0, target_alpha)
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", target_alpha, duration)
	await tween.finished
