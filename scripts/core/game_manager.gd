extends Control

# ============================================================
# 异变纪元：幸存者编队 - 主界面框架
# 包含：顶部状态栏 + 6个Tab页面 + 底部Tab导航
# ============================================================

const UI_FRAME_TEXTURE = preload("res://assets/images/ui/ui_frame_full.png")
const UI_PANEL_CARD_TEXTURE = preload("res://assets/images/ui/ui_panel_card.png")
const UI_ROUTE_CARD_TEXTURE = preload("res://assets/images/ui/ui_route_card.png")
const WORLD_MAP_TEXTURE = preload("res://assets/images/exploration/world_map_wide_city_realm_v5_clean.png")

const COLOR_TEXT = Color(0.88, 0.96, 1.0)
const COLOR_MUTED = Color(0.58, 0.68, 0.72)
const COLOR_CYAN = Color(0.0, 0.83, 1.0)
const COLOR_AMBER = Color(0.96, 0.65, 0.14)

# UI 引用
var background_frame: TextureRect
var status_bar: HBoxContainer
var content_container: VBoxContainer
var tab_pages: Dictionary = {}  # tab_id -> Control
var tab_buttons: Dictionary = {}  # tab_id -> Button

# 当前Tab
var current_tab: String = "home"

# 集结地界面引用
var home_day_label: Label
var home_team_label: Label
var home_event_label: Label
var home_chapter_label: Label
var home_status_panel: PanelContainer
var home_status_label: Label
var home_reincarnation_label: Label

# 编队界面引用
var formation_label: Label
var formation_grid_container: GridContainer
var formation_grid_buttons: Array[Button] = []
var formation_survivor_container: VBoxContainer
var formation_selection_label: Label
var formation_debug_label: Label

# 当前选中的待上阵伙伴（先点队员，再点阵容位置）
var selected_formation_survivor_id: String = ""

# 伙伴界面引用
var partner_list_container: VBoxContainer
var partner_detail_popup: PopupPanel
var partner_detail_name: Label
var partner_detail_affinity: Label
var partner_detail_star: Label
var partner_star_up_button: Button
var partner_detail_stats: Label
var partner_detail_equipment: Label
var partner_equip_buttons: Dictionary = {}  # slot -> Button
var partner_detail_skills: Label
var partner_skill_upgrade_container: VBoxContainer
var partner_equipment_select_popup: PopupPanel
var partner_equipment_select_container: VBoxContainer
var partner_equipment_select_slot: String = ""

# 探索界面引用
var explore_route_container: VBoxContainer
var explore_status_label: Label
var explore_node_container: VBoxContainer
var explore_log_label: Label
var exploration_system: ExplorationSystem
var dungeon_manager: DungeonManager
var explore_view_mode: String = "world"
var current_world_site: Dictionary = {}
var current_site_grid: Array = []
var current_site_position: Vector2i = Vector2i.ZERO
var current_site_floor: int = 1
var current_site_total_floors: int = 1
var world_map_viewport: Control
var world_map_canvas: Control
var world_map_zoom_container: Control
var world_map_base_size := Vector2.ZERO
var world_map_zoom: float = 1.0
var world_map_touches: Dictionary = {}
var world_map_last_pinch_distance: float = 0.0

# 背包界面引用
var inventory_label: Label

# 图鉴界面引用
var codex_label: Label
var codex_content_container: VBoxContainer
var codex_view_mode: String = "categories"
var selected_codex_category: String = ""
var selected_codex_beast_id: String = ""
var selected_codex_boss_id: String = ""

# 当前选中的伙伴
var selected_partner: Dictionary = {}

# 战斗系统UI引用
var battle_popup: PopupPanel
var battle_round_label: Label
var battle_actor_label: Label
var battle_enemy_container: VBoxContainer
var battle_status_label: Label
var battle_log_label: RichTextLabel
var battle_party_container: HBoxContainer
var battle_action_bar: HBoxContainer
var battle_flee_button: Button
var battle_mode_buttons: Dictionary = {}  # mode -> Button
var battle_overlay_panel: PanelContainer
var battle_overlay_box: VBoxContainer
var battle_pending_action: Dictionary = {}  # {"type": "attack"/"skill", "skill_id": "", "team": ""}
var battle_data: Dictionary = {}
var battle_auto_mode: String = "manual"
var battle_waiting_input: bool = false
var battle_finished: bool = false
var battle_callback: Callable = Callable()
var battle_site_context: Dictionary = {}  # 小地图遇敌战斗上下文：记录敌人格/原位置，用于结算后处理

# 轮回结算UI引用
var reincarnation_popup: PopupPanel
var reincarnation_confirm_label: Label
var reincarnation_result_label: Label
var reincarnation_cancel_button: Button
var reincarnation_confirm_button: Button
var reincarnation_close_button: Button


class WorldMapConnections:
	extends Control

	var connection_points: Array = []
	var line_color := Color(0.45, 0.85, 1.0, 0.55)
	var label_color := Color(0.85, 0.95, 1.0, 0.85)

	func _draw() -> void:
		for connection in connection_points:
			var from: Vector2 = connection["from"]
			var to: Vector2 = connection["to"]
			draw_line(from, to, line_color, 2.0, true)
			var label: String = connection.get("label", "")
			if label != "":
				var font := ThemeDB.fallback_font
				var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
				var direction := from.direction_to(to)
				var normal := Vector2(-direction.y, direction.x)
				var mid := (from + to) * 0.5 + normal * 10.0
				var label_position := mid - Vector2(label_size.x * 0.5, -label_size.y * 0.5)
				draw_rect(Rect2(label_position - Vector2(3, label_size.y + 2), label_size + Vector2(6, 4)), Color(0.01, 0.04, 0.06, 0.82), true)
				draw_string(font, label_position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, label_color)


func _ready() -> void:
	GameState.ensure_initial_survivors()
	_build_background_frame()
	_build_status_bar()
	_build_content_area()
	_build_tab_navigation()
	_build_battle_popup()
	_build_reincarnation_popup()
	exploration_system = ExplorationSystem.new()
	exploration_system.player = GameState.player
	exploration_system.data_manager = DataManager
	dungeon_manager = DungeonManager.new()
	_switch_tab("home")
	_refresh_all()


func _build_background_frame() -> void:
	background_frame = TextureRect.new()
	background_frame.name = "BackgroundFrame"
	background_frame.texture = UI_FRAME_TEXTURE
	background_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_frame.stretch_mode = TextureRect.STRETCH_SCALE
	background_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_frame)


func _make_flat_style(
				color: Color,
				border_color: Color = COLOR_CYAN,
		border_width: int = 1,
		radius: int = 4,
		content_margin: int = 8
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = content_margin
	style.content_margin_top = content_margin
	style.content_margin_right = content_margin
	style.content_margin_bottom = content_margin
	return style


func _make_atlas_texture(region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = UI_FRAME_TEXTURE
	atlas.region = region
	return atlas


func _make_texture_style(
	texture: Texture2D,
	margin_left: int = 4,
	margin_top: int = 4,
	margin_right: int = 4,
	margin_bottom: int = 4
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.draw_center = true
	style.content_margin_left = margin_left
	style.content_margin_top = margin_top
	style.content_margin_right = margin_right
	style.content_margin_bottom = margin_bottom
	return style


func _apply_tab_button_texture_style(button: Button, region: Rect2) -> void:
	var slot_texture := _make_atlas_texture(region)
	var normal := _make_texture_style(slot_texture, 4, 30, 4, 8)
	var hover := _make_texture_style(slot_texture, 4, 30, 4, 8)
	var pressed := _make_texture_style(slot_texture, 4, 30, 4, 8)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", COLOR_MUTED)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_CYAN)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.03, 0.9))
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_font_size_override("font_size", 9)


func _apply_route_card_texture_style(button: Button) -> void:
	var normal := _make_texture_style(UI_ROUTE_CARD_TEXTURE, 14, 12, 14, 12)
	var hover := _make_texture_style(UI_ROUTE_CARD_TEXTURE, 14, 12, 14, 12)
	var pressed := _make_texture_style(UI_ROUTE_CARD_TEXTURE, 14, 12, 14, 12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_CYAN)
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.03, 0.9))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 13)


func _apply_map_region_style(button: Button) -> void:
	var normal := _make_flat_style(Color(0.015, 0.045, 0.06, 0.94), Color(0.0, 0.72, 0.84, 0.9), 1, 4, 6)
	var hover := _make_flat_style(Color(0.02, 0.14, 0.17, 0.97), COLOR_CYAN, 2, 4, 6)
	var pressed := _make_flat_style(Color(0.12, 0.13, 0.08, 0.98), COLOR_AMBER, 2, 4, 6)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.03, 0.95))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 11)


func _apply_label_style(label: Label, font_size: int = 16, color: Color = COLOR_TEXT) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)


func _apply_button_style(button: Button, kind: String = "row") -> void:
	var normal := _make_flat_style(Color(0.07, 0.10, 0.12, 0.86), Color(0.0, 0.62, 0.72, 0.85), 1, 4, 8)
	var hover := _make_flat_style(Color(0.08, 0.16, 0.18, 0.92), COLOR_CYAN, 1, 4, 8)
	var pressed := _make_flat_style(Color(0.10, 0.18, 0.18, 0.96), COLOR_AMBER, 1, 4, 8)
	var font_size := 15
	match kind:
		"route":
			normal = _make_flat_style(Color(0.07, 0.10, 0.12, 0.88), Color(0.0, 0.72, 0.84, 0.9), 1, 5, 10)
			hover = _make_flat_style(Color(0.08, 0.16, 0.18, 0.94), COLOR_CYAN, 1, 5, 10)
			pressed = _make_flat_style(Color(0.12, 0.18, 0.16, 0.96), COLOR_AMBER, 1, 5, 10)
		"panel":
			normal = _make_flat_style(Color(0.08, 0.10, 0.11, 0.88), Color(0.0, 0.64, 0.74, 0.8), 1, 4, 10)
			hover = _make_flat_style(Color(0.10, 0.14, 0.15, 0.94), COLOR_CYAN, 1, 4, 10)
			pressed = _make_flat_style(Color(0.12, 0.16, 0.14, 0.96), COLOR_AMBER, 1, 4, 10)
		"tab":
			button.add_theme_stylebox_override("normal", _make_flat_style(Color(0.02, 0.04, 0.05, 0.05), Color(0.0, 0.0, 0.0, 0.0), 0, 3, 4))
			button.add_theme_stylebox_override("hover", _make_flat_style(Color(0.0, 0.45, 0.55, 0.18), Color(0.0, 0.80, 0.95, 0.45), 1, 3, 4))
			button.add_theme_stylebox_override("pressed", _make_flat_style(Color(0.0, 0.70, 0.85, 0.26), COLOR_AMBER, 1, 3, 4))
			button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			button.add_theme_color_override("font_color", COLOR_MUTED)
			button.add_theme_color_override("font_hover_color", COLOR_TEXT)
			button.add_theme_color_override("font_pressed_color", COLOR_CYAN)
			button.add_theme_font_size_override("font_size", 12)
			return

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_CYAN)
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_font_size_override("font_size", font_size)


func _make_panel_container() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_flat_style(Color(0.08, 0.10, 0.11, 0.84), Color(0.0, 0.62, 0.72, 0.86), 1, 4, 0))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel


func _make_panel_margin(parent: PanelContainer, padding: int = 18) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", padding)
	margin.add_theme_constant_override("margin_top", padding)
	margin.add_theme_constant_override("margin_right", padding)
	margin.add_theme_constant_override("margin_bottom", padding)
	parent.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	return box


func _set_home_status(text: String) -> void:
	if home_status_label == null:
		return
	home_status_label.text = text
	if home_status_panel != null:
		home_status_panel.visible = text.strip_edges() != ""


# ============================================================
# 第1步：顶部状态栏
# ============================================================
func _build_status_bar() -> void:
	status_bar = HBoxContainer.new()
	status_bar.add_theme_constant_override("separation", 12)
	status_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	status_bar.offset_top = 8
	status_bar.offset_bottom = 48
	status_bar.offset_left = 16
	status_bar.offset_right = -16
	add_child(status_bar)

	# 左上：天数
	var day_label := Label.new()
	day_label.name = "DayLabel"
	day_label.text = "D1"
	_apply_label_style(day_label, 18, COLOR_CYAN)
	day_label.custom_minimum_size = Vector2(60, 0)
	status_bar.add_child(day_label)

	# 左中：探索者名称
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = "陈末"
	_apply_label_style(name_label, 16)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_bar.add_child(name_label)

	# 右中：补给券
	var ticket_label := Label.new()
	ticket_label.name = "TicketLabel"
	ticket_label.text = "🎫 0"
	_apply_label_style(ticket_label, 14, COLOR_AMBER)
	status_bar.add_child(ticket_label)

	# 右上：灵能水晶
	var crystal_label := Label.new()
	crystal_label.name = "CrystalLabel"
	crystal_label.text = "💎 0"
	_apply_label_style(crystal_label, 14, COLOR_CYAN)
	status_bar.add_child(crystal_label)

	# 右下：设置按钮
	var settings_button := Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "⚙️"
	settings_button.custom_minimum_size = Vector2(36, 36)
	_apply_button_style(settings_button, "tab")
	settings_button.pressed.connect(_on_settings_pressed)
	status_bar.add_child(settings_button)


# ============================================================
# 第2步：中间内容区（6个Tab页面）
# ============================================================
func _build_content_area() -> void:
	content_container = VBoxContainer.new()
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_container.offset_top = 58
	content_container.offset_bottom = -154
	content_container.offset_left = 14
	content_container.offset_right = -14
	content_container.add_theme_constant_override("separation", 4)
	add_child(content_container)

	# 创建6个Tab页面
	tab_pages["home"] = _build_home_page()
	tab_pages["formation"] = _build_formation_page()
	tab_pages["partners"] = _build_partners_page()
	tab_pages["explore"] = _build_explore_page()
	tab_pages["inventory"] = _build_inventory_page()
	tab_pages["codex"] = _build_codex_page()

	# 默认全部隐藏
	for page in tab_pages.values():
		page.visible = false
		content_container.add_child(page)


# ============================================================
# 第3步：集结地主界面
# ============================================================
func _build_home_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "HomePage"
	page.add_theme_constant_override("separation", 6)

	# 天数标题
	var title := Label.new()
	title.text = "第 1 天 · 上午"
	_apply_label_style(title, 22, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	# 小队状态
	home_team_label = Label.new()
	home_team_label.text = "小队状态：0/3 出战 · 0 未上阵"
	_apply_label_style(home_team_label, 13, COLOR_MUTED)
	home_team_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(home_team_label)

	# 事件通知
	var event_panel := _make_panel_container()
	page.add_child(event_panel)
	var event_box := _make_panel_margin(event_panel, 12)

	var event_title := Label.new()
	event_title.text = "【事件通知】"
	_apply_label_style(event_title, 16, COLOR_AMBER)
	event_box.add_child(event_title)

	home_event_label = Label.new()
	home_event_label.text = "暂无新事件。"
	_apply_label_style(home_event_label, 13)
	home_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_box.add_child(home_event_label)

	# 主线进度
	var chapter_panel := _make_panel_container()
	page.add_child(chapter_panel)
	var chapter_box := _make_panel_margin(chapter_panel, 12)

	var chapter_title := Label.new()
	chapter_title.text = "【主线进度】"
	_apply_label_style(chapter_title, 16, COLOR_AMBER)
	chapter_box.add_child(chapter_title)

	home_chapter_label = Label.new()
	home_chapter_label.text = "第 1 章 · 灵潮之日"
	_apply_label_style(home_chapter_label, 13)
	home_chapter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chapter_box.add_child(home_chapter_label)

	# 轮回信息
	var reincarnation_panel := _make_panel_container()
	page.add_child(reincarnation_panel)
	var reincarnation_box := _make_panel_margin(reincarnation_panel, 12)

	var reincarnation_title := Label.new()
	reincarnation_title.text = "【轮回进度】"
	_apply_label_style(reincarnation_title, 16, COLOR_AMBER)
	reincarnation_box.add_child(reincarnation_title)

	home_reincarnation_label = Label.new()
	home_reincarnation_label.text = "第 1 轮 · 真相进度 0%"
	_apply_label_style(home_reincarnation_label, 13)
	home_reincarnation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reincarnation_box.add_child(home_reincarnation_label)

	var reincarnation_button := Button.new()
	reincarnation_button.text = "🔄 主动轮回（结算本轮成就）"
	reincarnation_button.custom_minimum_size = Vector2(0, 38)
	reincarnation_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(reincarnation_button, "panel")
	reincarnation_button.pressed.connect(_on_reincarnation_pressed)
	reincarnation_box.add_child(reincarnation_button)

	# 快速操作
	var quick_panel := _make_panel_container()
	page.add_child(quick_panel)
	var quick_box := _make_panel_margin(quick_panel, 12)

	var quick_title := Label.new()
	quick_title.text = "【快速操作】"
	_apply_label_style(quick_title, 16, COLOR_AMBER)
	quick_box.add_child(quick_title)

	var quick_row := HBoxContainer.new()
	quick_row.add_theme_constant_override("separation", 8)
	quick_box.add_child(quick_row)

	var heal_button := Button.new()
	heal_button.text = "治疗全体"
	heal_button.custom_minimum_size = Vector2(0, 34)
	heal_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(heal_button)
	heal_button.pressed.connect(_on_heal_all_pressed)
	quick_row.add_child(heal_button)

	var rest_button := Button.new()
	rest_button.text = "休息"
	rest_button.custom_minimum_size = Vector2(0, 34)
	rest_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(rest_button)
	rest_button.pressed.connect(_on_rest_pressed)
	quick_row.add_child(rest_button)

	# 状态提示
	home_status_panel = _make_panel_container()
	home_status_panel.visible = false
	page.add_child(home_status_panel)
	var status_box := _make_panel_margin(home_status_panel, 10)

	home_status_label = Label.new()
	home_status_label.text = ""
	_apply_label_style(home_status_label, 13, COLOR_MUTED)
	home_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_box.add_child(home_status_label)

	return page


# ============================================================
# 编队界面
# ============================================================
func _build_formation_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "FormationPage"
	page.add_theme_constant_override("separation", 6)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "编队 · 强攻阵"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var formation_switch := Button.new()
	formation_switch.text = "[切换阵型]"
	formation_switch.custom_minimum_size = Vector2(0, 32)
	_apply_button_style(formation_switch)
	formation_switch.pressed.connect(_on_switch_formation_pressed)
	page.add_child(formation_switch)

	var grid_panel := _make_panel_container()
	page.add_child(grid_panel)
	var grid_box := _make_panel_margin(grid_panel, 10)

	var grid_title := Label.new()
	grid_title.text = "【九宫格编队】"
	_apply_label_style(grid_title, 15, COLOR_AMBER)
	grid_box.add_child(grid_title)

	# 九宫格编队网格
	formation_grid_container = GridContainer.new()
	formation_grid_container.columns = 3
	formation_grid_container.add_theme_constant_override("h_separation", 4)
	formation_grid_container.add_theme_constant_override("v_separation", 4)
	formation_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_box.add_child(formation_grid_container)

	# 创建9个格子按钮
	formation_grid_buttons = []
	for i in range(9):
		var grid_button := Button.new()
		grid_button.custom_minimum_size = Vector2(0, 38)
		grid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(grid_button)
		grid_button.pressed.connect(_on_grid_cell_pressed.bind(i))
		formation_grid_container.add_child(grid_button)
		formation_grid_buttons.append(grid_button)

	# 选择提示
	formation_selection_label = Label.new()
	formation_selection_label.text = "① 点击选择一名伙伴 ② 再点击九宫格位置放置"
	_apply_label_style(formation_selection_label, 13, COLOR_MUTED)
	formation_selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(formation_selection_label)

	var survivor_panel := _make_panel_container()
	survivor_panel.custom_minimum_size = Vector2(0, 170)
	survivor_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(survivor_panel)
	var survivor_box := _make_panel_margin(survivor_panel, 10)

	var survivor_title := Label.new()
	survivor_title.text = "【所有伙伴】"
	_apply_label_style(survivor_title, 15, COLOR_AMBER)
	survivor_box.add_child(survivor_title)

	formation_debug_label = Label.new()
	formation_debug_label.text = ""
	_apply_label_style(formation_debug_label, 12, COLOR_MUTED)
	formation_debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	survivor_box.add_child(formation_debug_label)

	# 伙伴列表滚动区域
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 96)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	survivor_box.add_child(scroll)

	formation_survivor_container = VBoxContainer.new()
	formation_survivor_container.add_theme_constant_override("separation", 4)
	formation_survivor_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formation_survivor_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(formation_survivor_container)

	return page


# ============================================================
# 伙伴界面
# ============================================================
func _build_partners_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "PartnersPage"
	page.add_theme_constant_override("separation", 6)

	var title := Label.new()
	title.text = "伙伴"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	# 滚动容器
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(scroll)

	partner_list_container = VBoxContainer.new()
	partner_list_container.add_theme_constant_override("separation", 3)
	partner_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(partner_list_container)

	# 伙伴详情弹窗
	_build_partner_detail_popup()

	return page


func _build_partner_detail_popup() -> void:
	partner_detail_popup = PopupPanel.new()
	partner_detail_popup.size = Vector2(360, 640)
	partner_detail_popup.add_theme_stylebox_override("panel", _make_flat_style(Color(0.06, 0.08, 0.09, 0.97), COLOR_CYAN, 1, 5, 0))
	add_child(partner_detail_popup)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	partner_detail_popup.add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	partner_detail_name = Label.new()
	_apply_label_style(partner_detail_name, 20, COLOR_CYAN)
	vbox.add_child(partner_detail_name)

	partner_detail_affinity = Label.new()
	_apply_label_style(partner_detail_affinity, 13)
	partner_detail_affinity.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_affinity)

	partner_detail_star = Label.new()
	_apply_label_style(partner_detail_star, 14, COLOR_AMBER)
	partner_detail_star.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_star)

	partner_star_up_button = Button.new()
	partner_star_up_button.text = "⭐ 升星"
	partner_star_up_button.custom_minimum_size = Vector2(0, 30)
	partner_star_up_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(partner_star_up_button)
	partner_star_up_button.pressed.connect(_on_partner_star_up_pressed)
	vbox.add_child(partner_star_up_button)

	partner_detail_stats = Label.new()
	_apply_label_style(partner_detail_stats, 14)
	partner_detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_stats)

	partner_detail_equipment = Label.new()
	_apply_label_style(partner_detail_equipment, 13)
	partner_detail_equipment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_equipment)

	var equip_row := HBoxContainer.new()
	equip_row.add_theme_constant_override("separation", 6)
	vbox.add_child(equip_row)
	var slot_defs := [["weapon", "武器"], ["armor", "防具"], ["accessory", "饰品"]]
	for slot_def in slot_defs:
		var equip_button := Button.new()
		equip_button.text = "装备%s" % slot_def[1]
		equip_button.custom_minimum_size = Vector2(0, 30)
		equip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(equip_button)
		equip_button.pressed.connect(_on_partner_equip_pressed.bind(str(slot_def[0])))
		equip_row.add_child(equip_button)
		partner_equip_buttons[str(slot_def[0])] = equip_button

	var skill_title := Label.new()
	skill_title.text = "【技能】"
	_apply_label_style(skill_title, 15, COLOR_AMBER)
	vbox.add_child(skill_title)

	partner_detail_skills = Label.new()
	_apply_label_style(partner_detail_skills, 14)
	partner_detail_skills.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_skills)

	partner_skill_upgrade_container = VBoxContainer.new()
	partner_skill_upgrade_container.add_theme_constant_override("separation", 4)
	vbox.add_child(partner_skill_upgrade_container)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(0, 32)
	_apply_button_style(close_button)
	close_button.pressed.connect(func() -> void: partner_detail_popup.hide())
	vbox.add_child(close_button)

	# 装备选择弹窗
	partner_equipment_select_popup = PopupPanel.new()
	partner_equipment_select_popup.size = Vector2(300, 420)
	partner_equipment_select_popup.add_theme_stylebox_override("panel", _make_flat_style(Color(0.06, 0.08, 0.09, 0.97), COLOR_AMBER, 1, 5, 0))
	add_child(partner_equipment_select_popup)

	var select_margin := MarginContainer.new()
	select_margin.add_theme_constant_override("margin_left", 12)
	select_margin.add_theme_constant_override("margin_top", 12)
	select_margin.add_theme_constant_override("margin_right", 12)
	select_margin.add_theme_constant_override("margin_bottom", 12)
	partner_equipment_select_popup.add_child(select_margin)

	var select_vbox := VBoxContainer.new()
	select_vbox.add_theme_constant_override("separation", 6)
	select_margin.add_child(select_vbox)

	var select_title := Label.new()
	select_title.text = "选择装备"
	_apply_label_style(select_title, 16, COLOR_AMBER)
	select_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	select_vbox.add_child(select_title)

	var select_scroll := ScrollContainer.new()
	select_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	select_vbox.add_child(select_scroll)

	partner_equipment_select_container = VBoxContainer.new()
	partner_equipment_select_container.add_theme_constant_override("separation", 4)
	partner_equipment_select_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_scroll.add_child(partner_equipment_select_container)

	var select_close := Button.new()
	select_close.text = "关闭"
	select_close.custom_minimum_size = Vector2(0, 30)
	_apply_button_style(select_close)
	select_close.pressed.connect(func() -> void: partner_equipment_select_popup.hide())
	select_vbox.add_child(select_close)


# ============================================================
# 战斗弹窗
# ============================================================
func _build_battle_popup() -> void:
	battle_popup = PopupPanel.new()
	battle_popup.size = Vector2(520, 820)
	battle_popup.exclusive = true
	battle_popup.add_theme_stylebox_override("panel", _make_texture_style(UI_PANEL_CARD_TEXTURE, 14, 14, 14, 14))
	add_child(battle_popup)

	var margin := MarginContainer.new()
	margin.name = "MainMargin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	battle_popup.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.name = "MainVBox"
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	battle_round_label = Label.new()
	battle_round_label.text = "⚔️ 战斗 · 回合 1"
	_apply_label_style(battle_round_label, 20, COLOR_CYAN)
	battle_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(battle_round_label)

	battle_actor_label = Label.new()
	battle_actor_label.text = "当前行动："
	_apply_label_style(battle_actor_label, 13, COLOR_AMBER)
	battle_actor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(battle_actor_label)

	var enemy_panel := _make_panel_container()
	enemy_panel.custom_minimum_size = Vector2(0, 178)
	vbox.add_child(enemy_panel)
	var enemy_box := _make_panel_margin(enemy_panel, 8)

	var enemy_title := Label.new()
	enemy_title.text = "【敌方】"
	_apply_label_style(enemy_title, 15, COLOR_AMBER)
	enemy_box.add_child(enemy_title)

	battle_enemy_container = VBoxContainer.new()
	battle_enemy_container.add_theme_constant_override("separation", 3)
	battle_enemy_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_box.add_child(battle_enemy_container)

	battle_status_label = Label.new()
	battle_status_label.text = "状态：无"
	_apply_label_style(battle_status_label, 12, COLOR_MUTED)
	battle_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(battle_status_label)

	var log_panel := _make_panel_container()
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(log_panel)
	var log_box := _make_panel_margin(log_panel, 6)

	battle_log_label = RichTextLabel.new()
	battle_log_label.bbcode_enabled = true
	battle_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battle_log_label.custom_minimum_size = Vector2(0, 180)
	battle_log_label.add_theme_font_size_override("normal_font_size", 13)
	battle_log_label.scroll_active = true
	log_box.add_child(battle_log_label)

	var party_title := Label.new()
	party_title.text = "【我方队伍】"
	_apply_label_style(party_title, 15, COLOR_AMBER)
	vbox.add_child(party_title)

	battle_party_container = HBoxContainer.new()
	battle_party_container.add_theme_constant_override("separation", 6)
	battle_party_container.custom_minimum_size = Vector2(0, 118)
	vbox.add_child(battle_party_container)

	# 模式切换
	var mode_title := Label.new()
	mode_title.text = "操作模式"
	_apply_label_style(mode_title, 13, COLOR_MUTED)
	vbox.add_child(mode_title)

	var mode_row := HBoxContainer.new()
	mode_row.add_theme_constant_override("separation", 6)
	vbox.add_child(mode_row)
	var mode_defs := [["manual", "手动"], ["semi", "半自动"], ["auto", "全自动"]]
	for md in mode_defs:
		var mode_btn := Button.new()
		mode_btn.text = str(md[1])
		mode_btn.toggle_mode = true
		mode_btn.button_pressed = (str(md[0]) == "manual")
		mode_btn.custom_minimum_size = Vector2(0, 30)
		mode_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(mode_btn)
		mode_btn.pressed.connect(_on_battle_mode_pressed.bind(str(md[0])))
		mode_row.add_child(mode_btn)
		battle_mode_buttons[str(md[0])] = mode_btn

	# 操作按钮
	battle_action_bar = HBoxContainer.new()
	battle_action_bar.add_theme_constant_override("separation", 6)
	vbox.add_child(battle_action_bar)

	var attack_btn := Button.new()
	attack_btn.text = "⚔️ 攻击"
	attack_btn.custom_minimum_size = Vector2(0, 40)
	attack_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(attack_btn)
	attack_btn.pressed.connect(_on_battle_attack_pressed)
	battle_action_bar.add_child(attack_btn)

	var skill_btn := Button.new()
	skill_btn.text = "✨ 技能"
	skill_btn.custom_minimum_size = Vector2(0, 40)
	skill_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(skill_btn)
	skill_btn.pressed.connect(_on_battle_skill_pressed)
	battle_action_bar.add_child(skill_btn)

	var guard_btn := Button.new()
	guard_btn.text = "🛡️ 防御"
	guard_btn.custom_minimum_size = Vector2(0, 40)
	guard_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(guard_btn)
	guard_btn.pressed.connect(_on_battle_guard_pressed)
	battle_action_bar.add_child(guard_btn)

	var item_btn := Button.new()
	item_btn.text = "🎒 道具"
	item_btn.custom_minimum_size = Vector2(0, 40)
	item_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(item_btn)
	item_btn.pressed.connect(_on_battle_item_pressed)
	battle_action_bar.add_child(item_btn)

	# 撤退按钮
	var flee_btn := Button.new()
	flee_btn.text = "🏳️ 撤退"
	flee_btn.custom_minimum_size = Vector2(0, 34)
	flee_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(flee_btn)
	flee_btn.pressed.connect(_on_battle_close_pressed)
	vbox.add_child(flee_btn)
	battle_flee_button = flee_btn

	_update_battle_controls(false)

	# 覆盖层（技能选择/目标选择使用，避免多弹窗冲突）
	battle_overlay_panel = PanelContainer.new()
	battle_overlay_panel.name = "BattleOverlay"
	battle_overlay_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle_overlay_panel.add_theme_stylebox_override("panel", _make_flat_style(Color(0.03, 0.05, 0.06, 0.98), COLOR_AMBER, 2, 5, 0))
	battle_overlay_panel.visible = false
	battle_overlay_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	battle_popup.add_child(battle_overlay_panel)

	var overlay_margin := MarginContainer.new()
	overlay_margin.name = "OverlayMargin"
	overlay_margin.add_theme_constant_override("margin_left", 16)
	overlay_margin.add_theme_constant_override("margin_top", 16)
	overlay_margin.add_theme_constant_override("margin_right", 16)
	overlay_margin.add_theme_constant_override("margin_bottom", 16)
	battle_overlay_panel.add_child(overlay_margin)

	battle_overlay_box = VBoxContainer.new()
	battle_overlay_box.name = "OverlayBox"
	battle_overlay_box.add_theme_constant_override("separation", 8)
	overlay_margin.add_child(battle_overlay_box)


# ============================================================
# 探索界面
# ============================================================
func _build_explore_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "ExplorePage"
	page.add_theme_constant_override("separation", 6)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "探索"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	explore_status_label = Label.new()
	explore_status_label.text = "消耗：半天（上午）"
	_apply_label_style(explore_status_label, 13, COLOR_MUTED)
	explore_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(explore_status_label)

	var route_title := Label.new()
	route_title.text = "请选择路线："
	_apply_label_style(route_title, 15, COLOR_AMBER)
	route_title.text = "大地图地点"
	page.add_child(route_title)

	var map_panel := PanelContainer.new()
	map_panel.add_theme_stylebox_override("panel", _make_texture_style(UI_PANEL_CARD_TEXTURE, 12, 12, 12, 12))
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(map_panel)

	var map_margin := MarginContainer.new()
	map_margin.add_theme_constant_override("margin_left", 4)
	map_margin.add_theme_constant_override("margin_top", 8)
	map_margin.add_theme_constant_override("margin_right", 4)
	map_margin.add_theme_constant_override("margin_bottom", 8)
	map_panel.add_child(map_margin)

	explore_route_container = VBoxContainer.new()
	explore_route_container.add_theme_constant_override("separation", 7)
	explore_route_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explore_route_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_margin.add_child(explore_route_container)

	return page


# ============================================================
# 背包界面
# ============================================================
func _build_inventory_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "InventoryPage"
	page.add_theme_constant_override("separation", 6)

	var title := Label.new()
	title.text = "背包"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var inventory_panel := _make_panel_container()
	inventory_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(inventory_panel)
	var inventory_box := _make_panel_margin(inventory_panel, 12)

	inventory_label = Label.new()
	_apply_label_style(inventory_label, 14)
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_box.add_child(inventory_label)

	return page


# ============================================================
# 图鉴界面
# ============================================================
func _build_codex_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "CodexPage"
	page.add_theme_constant_override("separation", 6)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "图鉴"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var codex_panel := _make_panel_container()
	codex_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(codex_panel)
	var codex_box := _make_panel_margin(codex_panel, 12)
	codex_box.size_flags_vertical = Control.SIZE_EXPAND_FILL

	codex_label = Label.new()
	_apply_label_style(codex_label, 14)
	codex_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_label.visible = false
	codex_box.add_child(codex_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	codex_box.add_child(scroll)

	codex_content_container = VBoxContainer.new()
	codex_content_container.add_theme_constant_override("separation", 8)
	codex_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(codex_content_container)

	return page


# ============================================================
# 第1步：底部Tab导航
# ============================================================
func _build_tab_navigation() -> void:
	var tab_bar := HBoxContainer.new()
	tab_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tab_bar.offset_top = -142
	tab_bar.offset_bottom = -16
	tab_bar.offset_left = 26
	tab_bar.offset_right = -26
	tab_bar.add_theme_constant_override("separation", 0)
	add_child(tab_bar)

	var tabs := [
		{"id": "home", "label": "🏠\n集结地"},
		{"id": "formation", "label": "⚔️\n编队"},
		{"id": "partners", "label": "👥\n伙伴"},
		{"id": "explore", "label": "🗺️\n探索"},
		{"id": "inventory", "label": "🎒\n背包"},
		{"id": "codex", "label": "📖\n图鉴"}
	]

	var tab_regions := [
		Rect2(42, 1450, 136, 184),
		Rect2(187, 1450, 136, 184),
		Rect2(332, 1450, 136, 184),
		Rect2(477, 1450, 136, 184),
		Rect2(622, 1450, 136, 184),
		Rect2(767, 1450, 136, 184)
	]

	for i in range(tabs.size()):
		var tab: Dictionary = tabs[i]
		var button := Button.new()
		button.text = tab["label"]
		button.custom_minimum_size = Vector2(0, 126)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		_apply_tab_button_texture_style(button, tab_regions[i])
		button.pressed.connect(_on_tab_pressed.bind(tab["id"]))
		tab_bar.add_child(button)
		tab_buttons[tab["id"]] = button


# ============================================================
# Tab切换逻辑
# ============================================================
func _on_tab_pressed(tab_id: String) -> void:
	_switch_tab(tab_id)


func _switch_tab(tab_id: String) -> void:
	current_tab = tab_id

	# 更新按钮状态
	for id in tab_buttons:
		tab_buttons[id].button_pressed = (id == tab_id)

	# 更新页面可见性
	for id in tab_pages:
		tab_pages[id].visible = (id == tab_id)

	# 切换时刷新对应页面
	match tab_id:
		"home":
			_refresh_home()
		"formation":
			_refresh_formation()
		"partners":
			_refresh_partners()
		"explore":
			_refresh_explore()
		"inventory":
			_refresh_inventory()
		"codex":
			_refresh_codex()


# ============================================================
# 刷新所有界面
# ============================================================
func _refresh_all() -> void:
	_refresh_status_bar()
	_refresh_home()
	_refresh_formation()
	_refresh_partners()
	_refresh_explore()
	_refresh_inventory()
	_refresh_codex()


func _refresh_status_bar() -> void:
	var player := GameState.player
	var day_label: Label = status_bar.get_node("DayLabel")
	var name_label: Label = status_bar.get_node("NameLabel")
	var ticket_label: Label = status_bar.get_node("TicketLabel")
	var crystal_label: Label = status_bar.get_node("CrystalLabel")

	day_label.text = "D%d" % player.day
	name_label.text = player.player_name
	ticket_label.text = "🎫 %d" % player.materials.get("tickets", 0)
	crystal_label.text = "💎 %d" % player.materials.get("crystals", 0)


func _refresh_home() -> void:
	var player := GameState.player
	var title: Label = tab_pages["home"].get_child(0)
	title.text = "第 %d 天 · %s" % [player.day, player.get_time_label()]

	var active_count := player.active_survivor_ids.size()
	var reserve_count := player.reserve_survivor_ids.size()
	home_team_label.text = "小队状态：%d/3 出战 · %d 未上阵" % [active_count, reserve_count]

	# 主线进度（V2.0 48章配置）
	home_chapter_label.text = _get_chapter_display_name(player.chapter_id)

	# 轮回进度
	var progress: Dictionary = player.get_reincarnation_progress()
	var best_rating: String = str(progress.get("best_rating", ""))
	var best_text := ""
	if best_rating != "":
		best_text = " · 最佳评价 %s" % best_rating
	home_reincarnation_label.text = "第 %d 轮 · 主线 %d/%d 章 · 真相 %d%%\n轮回印记 ×%d · 天赋点 ×%d%s" % [
		int(progress.get("reincarnation", 1)),
		int(progress.get("highest_chapter_all_time", 1)),
		int(progress.get("total_chapters", 48)),
		int(float(progress.get("truth_progress", 0.0)) * 100.0),
		int(progress.get("reincarnation_marks", 0)),
		int(progress.get("talent_points", 0)),
		best_text
	]

	# 事件通知（含轮回记忆）
	var memory_event: Dictionary = player.try_trigger_reincarnation_event()
	if bool(memory_event.get("triggered", false)):
		home_event_label.text = "💭 轮回记忆：" + str(memory_event.get("text", ""))
	elif DataManager.events.size() > 0:
		var first_event: Dictionary = DataManager.events[0]
		home_event_label.text = first_event.get("description", "暂无新事件。")
	else:
		home_event_label.text = "暂无新事件。"


# 获取章节显示名（V2.0 48章配置）
func _get_chapter_display_name(chapter_id: int) -> String:
	var chapters: Array = DataManager.main_story.get("chapters", [])
	for ch in chapters:
		if int(ch.get("id", 0)) == chapter_id:
			return "第 %d 章 · %s" % [chapter_id, str(ch.get("name", ""))]
	return "第 %d 章" % chapter_id


func _refresh_formation() -> void:
	GameState.ensure_initial_survivors()
	var player := GameState.player
	_ensure_formation_survivors_exist()
	_update_formation_debug_label()

	# 更新阵型标题
	var title: Label = tab_pages["formation"].get_child(0)
	title.text = "编队 · %s" % player.get_formation_name()

	# 更新九宫格按钮
	for i in range(9):
		var grid_button: Button = formation_grid_buttons[i]
		var survivor_id: String = player.get_grid_survivor(i)
		if survivor_id != "":
			var survivor_name := survivor_id
			for survivor in player.survivors:
				if survivor["id"] == survivor_id:
					survivor_name = survivor["name"]
					break
			grid_button.text = "%s\n%s" % [survivor_name, player.get_grid_position_label(i)]
		else:
			grid_button.text = "[空]\n%s" % player.get_grid_position_label(i)

	# 更新伙伴列表（所有伙伴统一显示，每个伙伴一个小方格，方格内显示状态）
	for child in formation_survivor_container.get_children():
		formation_survivor_container.remove_child(child)
		child.queue_free()

	if player.survivors.size() == 0:
		var empty_label := Label.new()
		empty_label.text = "暂无伙伴，请先探索招募。"
		_apply_label_style(empty_label, 13, COLOR_MUTED)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		formation_survivor_container.add_child(empty_label)
		_update_formation_selection_label()
		return

	for survivor in player.survivors:
		_add_formation_survivor_button(survivor)

	# 更新选择提示
	_update_formation_selection_label()


func _update_formation_debug_label() -> void:
	if formation_debug_label == null:
		return

	var player := GameState.player
	var grid_ids: Array[String] = []
	for i in range(player.formation_grid.size()):
		var grid_id: String = player.get_grid_survivor(i)
		if grid_id != "":
			grid_ids.append("%d:%s" % [i, grid_id])

	var owned_ids: Array[String] = []
	for survivor in player.survivors:
		owned_ids.append(str(survivor.get("id", "")))

	formation_debug_label.text = "调试：拥有 %d 人 [%s]；配置伙伴 %d 人；出战 [%s]；未上阵 [%s]；九宫格 [%s]" % [
		player.survivors.size(),
		", ".join(owned_ids),
		DataManager.partners.size(),
		", ".join(player.active_survivor_ids),
		", ".join(player.reserve_survivor_ids),
		", ".join(grid_ids)
	]


func _ensure_formation_survivors_exist() -> void:
	var player := GameState.player
	var required_ids: Array[String] = []

	for active_id in player.active_survivor_ids:
		if active_id != "" and active_id not in required_ids:
			required_ids.append(active_id)

	for reserve_id in player.reserve_survivor_ids:
		if reserve_id != "" and reserve_id not in required_ids:
			required_ids.append(reserve_id)

	for i in range(player.formation_grid.size()):
		var grid_id: String = player.get_grid_survivor(i)
		if grid_id != "" and grid_id not in required_ids:
			required_ids.append(grid_id)

	for required_id in required_ids:
		var already_owned := false
		for survivor in player.survivors:
			if survivor.get("id", "") == required_id:
				already_owned = true
				break
		if already_owned:
			continue

		for partner in DataManager.partners:
			if partner.get("id", "") == required_id:
				player.survivors.append(partner.duplicate(true))
				break


# 添加一名伙伴到编队列表方格（方格内显示名字/职业/出阵状态）
func _add_formation_survivor_button(survivor: Dictionary) -> void:
	var survivor_id: String = survivor["id"]
	var player := GameState.player
	var position_index: int = _find_survivor_grid_position(survivor_id)
	var status_text := "未上阵"
	var status_color := COLOR_MUTED
	if position_index >= 0:
		status_text = "已上阵 · %s" % player.get_grid_position_label(position_index)
		status_color = COLOR_CYAN

	var button := Button.new()
	button.text = "%s    %s Lv.%d    %s" % [survivor["name"], survivor["profession"], survivor["level"], status_text]
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 12)
	# 已选中的伙伴高亮显示
	if survivor_id == selected_formation_survivor_id:
		button.add_theme_stylebox_override("normal", _make_flat_style(Color(0.10, 0.20, 0.18, 0.96), COLOR_AMBER, 2, 4, 8))
		button.add_theme_stylebox_override("hover", _make_flat_style(Color(0.12, 0.24, 0.20, 0.98), COLOR_AMBER, 2, 4, 8))
		button.add_theme_stylebox_override("pressed", _make_flat_style(Color(0.14, 0.28, 0.22, 1.0), COLOR_AMBER, 2, 4, 8))
		button.add_theme_color_override("font_color", COLOR_AMBER)
	else:
		_apply_button_style(button)
		# 状态颜色：已上阵=青色，未上阵=灰色
		button.add_theme_color_override("font_color", status_color)
	button.pressed.connect(_on_survivor_selected.bind(survivor_id))
	formation_survivor_container.add_child(button)


func _on_grid_cell_pressed(grid_index: int) -> void:
	var player := GameState.player
	var current_survivor_id: String = player.get_grid_survivor(grid_index)

	# 场景1：没有选中任何伙伴
	if selected_formation_survivor_id == "":
		# 直接点击阵容格：有人则下阵，空格不响应。
		if current_survivor_id != "":
			player.remove_survivor_from_grid(grid_index)
			var survivor_name := _get_survivor_name(current_survivor_id)
			_set_home_status("%s 已下阵，移至未上阵。" % survivor_name)
			_refresh_formation()
		return

	# 场景2：点击的是已选中伙伴所在的格子 → 不改变阵容，只取消选中。
	if current_survivor_id == selected_formation_survivor_id:
		selected_formation_survivor_id = ""
		_set_home_status("%s 已在该位置。" % _get_survivor_name(current_survivor_id))
		_refresh_formation()
		return

	# 场景3：先选伙伴再点九宫格。空格直接上阵，占用格替换原伙伴。
	var survivor_name := _get_survivor_name(selected_formation_survivor_id)
	var replaced_name := _get_survivor_name(current_survivor_id) if current_survivor_id != "" else ""
	player.place_survivor_on_grid(selected_formation_survivor_id, grid_index)
	selected_formation_survivor_id = ""
	if replaced_name != "":
		_set_home_status("%s 已上阵到%s，%s 已下阵。" % [survivor_name, player.get_grid_position_label(grid_index), replaced_name])
	else:
		_set_home_status("%s 已上阵到%s。" % [survivor_name, player.get_grid_position_label(grid_index)])
	_refresh_formation()


# 点击伙伴列表中的伙伴 → 选中待放置状态
func _on_survivor_selected(survivor_id: String) -> void:
	# 再次点击同一伙伴 → 取消选中
	if selected_formation_survivor_id == survivor_id:
		selected_formation_survivor_id = ""
		_set_home_status("已取消选中 %s。" % _get_survivor_name(survivor_id))
	else:
		selected_formation_survivor_id = survivor_id
		_set_home_status("已选中 %s，请点击九宫格中的位置放置。" % _get_survivor_name(survivor_id))
	# 刷新列表以显示选中高亮
	_refresh_formation()


# 查找伙伴当前所在的九宫格位置（返回格子索引，-1表示不在格子上）
func _find_survivor_grid_position(survivor_id: String) -> int:
	var player := GameState.player
	for i in range(player.formation_grid.size()):
		var grid_survivor_id: String = player.get_grid_survivor(i)
		if grid_survivor_id == survivor_id:
			return i
	return -1


# 更新选择提示文字
func _update_formation_selection_label() -> void:
	if selected_formation_survivor_id == "":
		formation_selection_label.text = "① 点击选择一名伙伴 ② 再点击九宫格位置放置"
		formation_selection_label.add_theme_color_override("font_color", COLOR_MUTED)
	else:
		var survivor_name := _get_survivor_name(selected_formation_survivor_id)
		formation_selection_label.text = "▶ 已选中：%s （点击九宫格位置放置，或再次点击该伙伴取消）" % survivor_name
		formation_selection_label.add_theme_color_override("font_color", COLOR_AMBER)


func _get_survivor_name(survivor_id: String) -> String:
	for survivor in GameState.player.survivors:
		if survivor["id"] == survivor_id:
			return survivor["name"]
	return survivor_id


func _refresh_partners() -> void:
	# 清空列表
	for child in partner_list_container.get_children():
		partner_list_container.remove_child(child)
		child.queue_free()

	var player := GameState.player
	for survivor in player.survivors:
		player._ensure_partner_training_fields(survivor)
		var affinity_title: String = str(player.get_affinity_level_info(int(survivor.get("affinity", 0))).get("title", "初识"))
		var button := Button.new()
		button.text = "%s  %s  Lv.%d  %s\n好感：%s" % [
			survivor["name"],
			"★".repeat(survivor.get("star", 1)),
			survivor["level"],
			survivor.get("rarity", ""),
			affinity_title
		]
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(button)
		button.pressed.connect(_on_partner_clicked.bind(survivor))
		partner_list_container.add_child(button)


func _on_partner_clicked(partner: Dictionary) -> void:
	selected_partner = partner
	_refresh_partner_detail()
	partner_detail_popup.popup_centered()


func _format_stat_label(stat_key: String) -> String:
	match stat_key:
		"attack":
			return "攻击"
		"defense":
			return "防御"
		"spirit":
			return "灵能"
		"resistance":
			return "抵抗"
		"speed":
			return "速度"
	return stat_key


func _format_equipment_stats(item: Dictionary) -> String:
	var parts: Array[String] = []
	var item_stats: Dictionary = item.get("stats", {})
	for stat_key in item_stats:
		parts.append("%s%+d" % [_format_stat_label(str(stat_key)), int(item_stats[stat_key])])
	return "、".join(parts)


func _refresh_partner_detail() -> void:
	if selected_partner.is_empty():
		return
	var player := GameState.player
	var fresh_partner := player.get_partner_by_id(str(selected_partner.get("id", "")))
	if fresh_partner.is_empty():
		return
	selected_partner = fresh_partner
	player._ensure_partner_training_fields(selected_partner)
	var partner: Dictionary = selected_partner
	var partner_id: String = str(partner.get("id", ""))

	partner_detail_name.text = "%s · %s" % [partner.get("name", ""), partner.get("title", "")]

	# 好感度
	var affinity_value := int(partner.get("affinity", 0))
	var aff_info: Dictionary = player.get_affinity_level_info(affinity_value)
	var affinity_text := "好感度：%s Lv.%d（%d）" % [aff_info.get("title", ""), aff_info.get("level", 1), affinity_value]
	for level_info in PlayerData.AFFINITY_LEVELS:
		if int(level_info.get("threshold", 0)) > affinity_value:
			affinity_text += "  /  下一阶 %d" % int(level_info.get("threshold", 0))
			affinity_text += "（%s）" % str(level_info.get("bonus", {}).get("attack", 0))
			break
	partner_detail_affinity.text = affinity_text

	# 星级
	var star_count := int(partner.get("star", 1))
	var star_text := "★".repeat(star_count) + "☆".repeat(maxi(0, PlayerData.MAX_PARTNER_STAR - star_count))
	partner_detail_star.text = star_text + "\n星级加成：每星全属性+12%"
	if star_count >= PlayerData.MAX_PARTNER_STAR:
		partner_star_up_button.disabled = true
		partner_star_up_button.text = "已满星"
	else:
		var cost: Dictionary = PlayerData.STAR_UP_COSTS.get(star_count + 1, {})
		partner_star_up_button.disabled = int(player.materials.get("memory_shards", 0)) < int(cost.get("memory_shards", 0))
		partner_star_up_button.text = "⭐ 升星为 %d★（%s）" % [star_count + 1, _format_resources(cost)]

	# 属性
	var stats: Dictionary = partner.get("stats", {})
	var effective_bonus: Dictionary = player.get_partner_effective_bonus(partner_id)
	var bonus_parts: Array[String] = []
	for stat_key in effective_bonus:
		var bonus_value: int = int(effective_bonus[stat_key])
		if bonus_value != 0:
			bonus_parts.append("%s%+d" % [_format_stat_label(str(stat_key)), bonus_value])
	var bonus_text := "、".join(bonus_parts) if not bonus_parts.is_empty() else "无"
	partner_detail_stats.text = "HP %d/%d  |  能量 %d/%d\n攻击 %d  |  防御 %d\n灵能 %d  |  抵抗 %d\n速度 %d\n装备+好感加成：%s" % [
		partner.get("hp", 0), partner.get("max_hp", 0),
		partner.get("energy", 0), partner.get("max_energy", 0),
		stats.get("attack", 0), stats.get("defense", 0),
		stats.get("spirit", 0), stats.get("resistance", 0),
		stats.get("speed", 0),
		bonus_text
	]

	# 装备
	var slot_names := {"weapon": "武器", "armor": "防具", "accessory": "饰品"}
	var equipment: Dictionary = partner.get("equipment", {"weapon": "", "armor": "", "accessory": ""})
	var equip_parts: Array[String] = ["【装备】"]
	for slot in slot_names:
		var item_id: String = equipment.get(slot, "")
		if item_id == "":
			equip_parts.append("%s：未装备" % slot_names[slot])
		else:
			var item := DataManager.get_equipment_by_id(item_id)
			equip_parts.append("%s：%s  %s" % [slot_names[slot], item.get("name", item_id), _format_equipment_stats(item)])
	partner_detail_equipment.text = "\n".join(equip_parts)

	# 技能
	var skills: Array = partner.get("skills", [])
	if skills.is_empty() and partner.has("initial_skills"):
		skills = partner["initial_skills"]
	var skill_parts: Array[String] = []
	for skill_ref in skills:
		var skill_id: String = skill_ref.get("id", "") if skill_ref is Dictionary else str(skill_ref)
		var skill_lv: int = skill_ref.get("level", 1) if skill_ref is Dictionary else 1
		var skill_name: String = skill_id
		if DataManager.skills.has(skill_id):
			skill_name = str(DataManager.skills[skill_id].get("name", skill_id))
		skill_parts.append("%s Lv.%d" % [skill_name, skill_lv])
	partner_detail_skills.text = "\n".join(skill_parts) if not skill_parts.is_empty() else "暂无技能"

	# 技能升级按钮
	for child in partner_skill_upgrade_container.get_children():
		partner_skill_upgrade_container.remove_child(child)
		child.queue_free()
	for i in range(skills.size()):
		var skill_ref: Dictionary = skills[i]
		var skill_id: String = skill_ref.get("id", "") if skill_ref is Dictionary else str(skill_ref)
		var skill_lv: int = skill_ref.get("level", 1) if skill_ref is Dictionary else 1
		var skill_name: String = skill_id
		if DataManager.skills.has(skill_id):
			skill_name = str(DataManager.skills[skill_id].get("name", skill_id))
		if skill_lv >= PlayerData.MAX_SKILL_LEVEL:
			var max_label := Label.new()
			max_label.text = "%s · 已满级" % skill_name
			_apply_label_style(max_label, 12, COLOR_MUTED)
			partner_skill_upgrade_container.add_child(max_label)
			continue
		var skill_cost: Dictionary = PlayerData.SKILL_UPGRADE_COSTS.get(skill_lv, {})
		var upgrade_button := Button.new()
		upgrade_button.text = "↑ %s Lv.%d → %d（%s）" % [skill_name, skill_lv, skill_lv + 1, _format_resources(skill_cost)]
		upgrade_button.custom_minimum_size = Vector2(0, 30)
		upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(upgrade_button)
		upgrade_button.pressed.connect(_on_partner_skill_upgrade_pressed.bind(i))
		partner_skill_upgrade_container.add_child(upgrade_button)


func _on_partner_star_up_pressed() -> void:
	if selected_partner.is_empty():
		return
	var partner_id: String = str(selected_partner.get("id", ""))
	var result: Dictionary = GameState.player.upgrade_partner_star(partner_id)
	if result.get("success", false):
		_set_home_status("%s 升星成功！当前 %d★，全属性提升！" % [_get_survivor_name(partner_id), int(result.get("star", 1))])
	else:
		_set_home_status(str(result.get("reason", "升星失败。")))
	_refresh_partner_detail()
	_refresh_partners()


func _on_partner_equip_pressed(slot: String) -> void:
	if selected_partner.is_empty():
		return
	partner_equipment_select_slot = slot
	_open_equipment_select_popup(slot)


func _open_equipment_select_popup(slot: String) -> void:
	var player := GameState.player
	for child in partner_equipment_select_container.get_children():
		partner_equipment_select_container.remove_child(child)
		child.queue_free()

	var partner := player.get_partner_by_id(str(selected_partner.get("id", "")))
	player._ensure_partner_training_fields(partner)
	var equipment: Dictionary = partner.get("equipment", {})
	var equipped_item: String = equipment.get(slot, "")

	var title := Label.new()
	title.text = "选择【%s】" % _format_stat_label(slot)
	_apply_label_style(title, 14, COLOR_AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	partner_equipment_select_container.add_child(title)

	if equipped_item != "":
		var unequip_button := Button.new()
		var equipped: Dictionary = DataManager.get_equipment_by_id(equipped_item)
		unequip_button.text = "卸下：%s" % equipped.get("name", equipped_item)
		unequip_button.custom_minimum_size = Vector2(0, 32)
		unequip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(unequip_button)
		unequip_button.pressed.connect(_on_partner_unequip_pressed.bind(slot))
		partner_equipment_select_container.add_child(unequip_button)

	var available: Array = []
	for equipment_id in DataManager.equipment:
		var item: Dictionary = DataManager.equipment[equipment_id]
		if item.get("slot", "") != slot:
			continue
		var already_equipped := false
		for survivor in player.survivors:
			player._ensure_partner_training_fields(survivor)
			var survivor_equipment: Dictionary = survivor.get("equipment", {})
			if survivor_equipment.get(slot, "") == equipment_id:
				already_equipped = true
				break
		if not already_equipped:
			available.append(item)

	if available.is_empty():
		var empty_label := Label.new()
		empty_label.text = "没有可用的%s装备。" % _format_stat_label(slot)
		_apply_label_style(empty_label, 13, COLOR_MUTED)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		partner_equipment_select_container.add_child(empty_label)
	else:
		for item in available:
			var item_button := Button.new()
			item_button.text = "%s  [%s]\n%s" % [
				item.get("name", item.get("id", "")),
				item.get("rarity", ""),
				_format_equipment_stats(item)
			]
			item_button.custom_minimum_size = Vector2(0, 46)
			item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_apply_button_style(item_button)
			item_button.pressed.connect(_on_equipment_selected.bind(str(item.get("id", "")), slot))
			partner_equipment_select_container.add_child(item_button)

	partner_equipment_select_popup.popup_centered()


func _on_equipment_selected(item_id: String, slot: String) -> void:
	if selected_partner.is_empty():
		return
	var result: Dictionary = GameState.player.equip_partner_item(str(selected_partner.get("id", "")), item_id)
	if result.get("success", false):
		var item: Dictionary = result.get("item", {})
		_set_home_status("已装备 %s。" % item.get("name", item_id))
	else:
		_set_home_status(str(result.get("reason", "装备失败。")))
	partner_equipment_select_popup.hide()
	_refresh_partner_detail()


func _on_partner_unequip_pressed(slot: String) -> void:
	if selected_partner.is_empty():
		return
	var result: Dictionary = GameState.player.unequip_partner_item(str(selected_partner.get("id", "")), slot)
	if result.get("success", false):
		_set_home_status("已卸下 %s。" % str(result.get("item_id", "")))
	else:
		_set_home_status(str(result.get("reason", "卸下失败。")))
	partner_equipment_select_popup.hide()
	_refresh_partner_detail()


func _on_partner_skill_upgrade_pressed(skill_index: int) -> void:
	if selected_partner.is_empty():
		return
	var partner_id: String = str(selected_partner.get("id", ""))
	var result: Dictionary = GameState.player.upgrade_partner_skill(partner_id, skill_index)
	if result.get("success", false):
		_set_home_status("技能升级成功！当前 Lv.%d。" % int(result.get("level", 1)))
	else:
		_set_home_status(str(result.get("reason", "技能升级失败。")))
	_refresh_partner_detail()


func _refresh_explore() -> void:
	if explore_view_mode == "site":
		_show_site_map()
		return
	_show_world_map()


func _clear_explore_container() -> void:
	for child in explore_route_container.get_children():
		explore_route_container.remove_child(child)
		child.queue_free()


func _show_world_map() -> void:
	var player := GameState.player
	explore_status_label.text = "大地图 · %s · 口粮 %d" % [player.get_time_label(), player.supplies.get("food", 0)]
	_clear_explore_container()

	var map_data: Dictionary = DataManager.region_data.get("map", {})
	var map_header := HBoxContainer.new()
	map_header.add_theme_constant_override("separation", 8)
	map_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explore_route_container.add_child(map_header)

	var map_title := Label.new()
	map_title.text = "【%s】" % map_data.get("name", "荒原大地图")
	_apply_label_style(map_title, 16, COLOR_AMBER)
	map_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_header.add_child(map_title)

	var fit_mode_button := Button.new()
	fit_mode_button.text = "沉浸查看"
	fit_mode_button.custom_minimum_size = Vector2(96, 30)
	_apply_button_style(fit_mode_button)
	fit_mode_button.pressed.connect(_on_world_map_immersive_pressed)
	map_header.add_child(fit_mode_button)

	_add_world_map_canvas()


func _add_world_map_canvas() -> void:
	var sites := _get_region_world_sites()
	var texture_size := WORLD_MAP_TEXTURE.get_size()
	var map_width := texture_size.x
	var map_height := map_width * texture_size.y / maxf(1.0, texture_size.x)
	var map_size := Vector2(map_width, map_height)
	world_map_zoom = 1.0
	world_map_touches.clear()
	world_map_last_pinch_distance = 0.0
	world_map_base_size = map_size

	var map_viewport := Control.new()
	map_viewport.name = "WorldMapViewport"
	world_map_viewport = map_viewport
	map_viewport.custom_minimum_size = Vector2(0, 640)
	map_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_viewport.clip_contents = true
	map_viewport.resized.connect(_fit_world_map)
	explore_route_container.add_child(map_viewport)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 12
	map_viewport.add_child(scroll)

	var zoom_container := Control.new()
	world_map_zoom_container = zoom_container
	zoom_container.custom_minimum_size = map_size
	zoom_container.size = map_size
	scroll.add_child(zoom_container)

	var canvas := Control.new()
	world_map_canvas = canvas
	canvas.custom_minimum_size = map_size
	canvas.size = map_size
	canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.gui_input.connect(_on_world_map_input)
	zoom_container.add_child(canvas)

	_rebuild_world_map_content(map_size)

	call_deferred("_fit_world_map")


func _fit_world_map() -> void:
	if world_map_viewport == null or world_map_base_size == Vector2.ZERO:
		return
	var viewport_size := world_map_viewport.size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_zoom := maxf(
		viewport_size.x / world_map_base_size.x,
		viewport_size.y / world_map_base_size.y
	)
	_set_world_map_zoom(fit_zoom)


func _on_world_map_immersive_pressed() -> void:
	_fit_world_map()


func _on_world_map_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_world_map_zoom(world_map_zoom + 0.1)
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_world_map_zoom(world_map_zoom - 0.1)
		return

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event
		if touch_event.pressed:
			world_map_touches[touch_event.index] = touch_event.position
		else:
			world_map_touches.erase(touch_event.index)
		world_map_last_pinch_distance = _get_world_map_pinch_distance()
		return

	if event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event
		if world_map_touches.has(drag_event.index):
			world_map_touches[drag_event.index] = drag_event.position
		var pinch_distance := _get_world_map_pinch_distance()
		if world_map_touches.size() >= 2 and world_map_last_pinch_distance > 0.0 and pinch_distance > 0.0:
			_set_world_map_zoom(world_map_zoom * pinch_distance / world_map_last_pinch_distance)
		world_map_last_pinch_distance = pinch_distance


func _get_world_map_pinch_distance() -> float:
	if world_map_touches.size() < 2:
		return 0.0
	var touch_positions: Array = world_map_touches.values()
	return touch_positions[0].distance_to(touch_positions[1])


func _set_world_map_zoom(value: float) -> void:
	if world_map_canvas == null or world_map_zoom_container == null or world_map_base_size == Vector2.ZERO:
		return
	var minimum_zoom := 0.18
	if world_map_viewport != null and world_map_viewport.size.x > 0.0 and world_map_viewport.size.y > 0.0:
		minimum_zoom = minf(
			world_map_viewport.size.x / world_map_base_size.x,
			world_map_viewport.size.y / world_map_base_size.y
		)
		minimum_zoom = maxf(0.18, minimum_zoom)
	world_map_zoom = clampf(value, minimum_zoom, 2.0)
	var scaled_size := world_map_base_size * world_map_zoom
	world_map_zoom_container.scale = Vector2.ONE
	world_map_zoom_container.custom_minimum_size = scaled_size
	world_map_zoom_container.size = scaled_size
	world_map_canvas.custom_minimum_size = scaled_size
	world_map_canvas.size = scaled_size
	_rebuild_world_map_content(scaled_size)


func _rebuild_world_map_content(map_size: Vector2) -> void:
	if world_map_canvas == null:
		return

	for child in world_map_canvas.get_children():
		world_map_canvas.remove_child(child)
		child.queue_free()

	var map_texture := TextureRect.new()
	map_texture.texture = WORLD_MAP_TEXTURE
	map_texture.position = Vector2.ZERO
	map_texture.size = map_size
	map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_texture.stretch_mode = TextureRect.STRETCH_SCALE
	map_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world_map_canvas.add_child(map_texture)

	var sites := _get_region_world_sites()
	_add_world_map_connections(world_map_canvas, sites, map_size)

	for site in sites:
		_add_world_map_region_button(world_map_canvas, site, map_size)


func _add_world_map_connections(canvas: Control, sites: Array, map_size: Vector2) -> void:
	var region_data: Dictionary = DataManager.region_data
	var connections: Array = region_data.get("connections", [])
	if connections.is_empty():
		return

	var site_by_id: Dictionary = {}
	for site in sites:
		site_by_id[site.get("id", "")] = site

	var map_data: Dictionary = region_data.get("map", {})
	var coordinate_size: Dictionary = map_data.get("coordinate_size", {"x": 200, "y": 150})
	var max_x: float = maxf(1.0, float(coordinate_size.get("x", 200)))
	var max_y: float = maxf(1.0, float(coordinate_size.get("y", 150)))

	var connections_layer := WorldMapConnections.new()
	connections_layer.name = "RegionConnections"
	connections_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connections_layer.position = Vector2.ZERO
	connections_layer.size = map_size

	for connection in connections:
		var from_id: String = connection.get("from", "")
		var to_id: String = connection.get("to", "")
		if not site_by_id.has(from_id) or not site_by_id.has(to_id):
			continue

		var from_site: Dictionary = site_by_id[from_id]
		var to_site: Dictionary = site_by_id[to_id]
		var from_pos: Dictionary = from_site.get("position", {})
		var to_pos: Dictionary = to_site.get("position", {})

		var from_normalized := Vector2(
			float(from_pos.get("x", 0)) / max_x,
			1.0 - float(from_pos.get("y", 0)) / max_y
		)
		var to_normalized := Vector2(
			float(to_pos.get("x", 0)) / max_x,
			1.0 - float(to_pos.get("y", 0)) / max_y
		)

		connections_layer.connection_points.append({
			"from": Vector2(from_normalized.x * map_size.x, from_normalized.y * map_size.y),
			"to": Vector2(to_normalized.x * map_size.x, to_normalized.y * map_size.y),
			"label": connection.get("route", "")
		})

	canvas.add_child(connections_layer)
	connections_layer.queue_redraw()


func _add_world_map_region_button(canvas: Control, site: Dictionary, map_size: Vector2) -> void:
	var position_data: Dictionary = site.get("position", {})
	var map_data: Dictionary = DataManager.region_data.get("map", {})
	var coordinate_size: Dictionary = map_data.get("coordinate_size", {"x": 200, "y": 150})
	var max_x: float = maxf(1.0, float(coordinate_size.get("x", 200)))
	var max_y: float = maxf(1.0, float(coordinate_size.get("y", 150)))
	var normalized_x := float(position_data.get("x", 0)) / max_x
	var normalized_y := 1.0 - float(position_data.get("y", 0)) / max_y

	var button := Button.new()
	button.text = "%s %s\nLV %d" % [
		site.get("icon", "*"),
		site.get("name", "未知地点"),
		int(site.get("danger", 1))
	]
	var button_width := clampf(map_size.x * 0.11, 110.0, 150.0)
	var button_height := 38.0
	var horizontal_padding := button_width * 0.5 + 18.0
	var vertical_padding := button_height * 0.5 + 18.0
	button.custom_minimum_size = Vector2(button_width, button_height)
	button.size = Vector2(button_width, button_height)
	button.position = Vector2(
		clampf(normalized_x * map_size.x - button_width * 0.5, horizontal_padding - button_width * 0.5, map_size.x - horizontal_padding - button_width * 0.5),
		clampf(normalized_y * map_size.y - button_height * 0.5, vertical_padding - button_height * 0.5, map_size.y - vertical_padding - button_height * 0.5)
	)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_map_region_style(button)
	button.pressed.connect(_on_world_site_pressed.bind(site))
	canvas.add_child(button)


func _get_region_world_sites() -> Array:
	DataManager.ensure_loaded()
	var region_data: Dictionary = DataManager.region_data
	var regions: Array = region_data.get("regions", [])
	if regions.is_empty():
		return _get_world_sites()

	var sites: Array = []
	for region in regions:
		if region is Dictionary:
			sites.append(_region_to_world_site(region))
	return sites


func _region_to_world_site(region: Dictionary) -> Dictionary:
	var recommended_level: int = int(region.get("recommended_level", 1))
	var total_floors: int = 1
	if recommended_level >= 28:
		total_floors = 5
	elif recommended_level >= 20:
		total_floors = 4
	elif recommended_level >= 12:
		total_floors = 3

	return {
		"id": region.get("id", ""),
		"name": region.get("name", "未知地点"),
		"icon": region.get("icon", "*"),
		"site_type": "realm",
		"desc": "固定秘境 · 推荐 LV%d · 危险半径 %d" % [
			recommended_level,
			int(region.get("danger_radius", 20))
		],
		"danger": recommended_level,
		"grid_size": clampi(5 + int(recommended_level / 12), 5, 8),
		"total_floors": total_floors,
		"dungeon_type": region.get("dungeon_type", ""),
		"boss_id": region.get("boss_id", ""),
		"theme": region.get("theme", ""),
		"position": region.get("position", {})
	}


func _get_world_sites() -> Array:
	var sites: Array = [
		{
			"id": "supply_ruins",
			"name": "废墟补给点",
			"icon": "□",
			"site_type": "resource",
			"desc": "散落着口粮、药品和少量弹药，危险较低。",
			"danger": 1,
			"grid_size": 6,
			"total_floors": 1
		},
		{
			"id": "abandoned_clinic",
			"name": "废弃诊所",
			"icon": "+",
			"site_type": "resource",
			"desc": "药品概率更高，可能潜伏着低阶异兽。",
			"danger": 2,
			"grid_size": 6,
			"total_floors": 1
		},
		{
			"id": "ammo_cache",
			"name": "旧军械库",
			"icon": "!",
			"site_type": "resource",
			"desc": "弹药和材料较多，敌人密度更高。",
			"danger": 3,
			"grid_size": 7,
			"total_floors": 1
		}
	]

	if dungeon_manager != null:
		var realm_count := 0
		for info in dungeon_manager.get_dungeon_info_list():
			if realm_count >= 2:
				break
			sites.append({
				"id": "realm_" + str(info.get("id", "")),
				"name": str(info.get("name", "未知秘境")),
				"icon": str(info.get("icon", "*")),
				"site_type": "realm",
				"desc": "多层秘境，奖励更高，内部也使用小地图探索。",
				"danger": int(info.get("recommended_level", 1)),
				"grid_size": int(info.get("grid_size_min", 6)),
				"total_floors": int(info.get("min_floors", 3))
			})
			realm_count += 1

	return sites


func _add_world_site_button(site: Dictionary) -> void:
	var button := Button.new()
	button.text = "%s  %s\n%s  危险 %s" % [
		site.get("icon", "*"),
		site.get("name", "未知地点"),
		site.get("desc", ""),
		str(site.get("danger", 1))
	]
	button.custom_minimum_size = Vector2(0, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_route_card_texture_style(button)
	button.pressed.connect(_on_world_site_pressed.bind(site))
	explore_route_container.add_child(button)


func _on_world_site_pressed(site: Dictionary) -> void:
	if GameState.player.supplies.get("food", 0) <= 0:
		_set_home_status("口粮不足，无法外出探索。")
		return

	# 进入小地图扣 1 口粮，防止反复进出免费刷图
	GameState.player.supplies["food"] = maxi(0, int(GameState.player.supplies.get("food", 0)) - 1)
	current_world_site = site.duplicate(true)
	current_site_floor = 1
	current_site_total_floors = maxi(1, int(site.get("total_floors", 1)))
	explore_view_mode = "site"
	_generate_current_site_grid()
	_set_home_status("进入%s的小地图，消耗口粮×1。" % current_world_site.get("name", "未知地点"))
	_refresh_explore()


func _generate_current_site_grid() -> void:
	current_site_grid = _generate_site_grid(current_world_site, current_site_floor)


func _generate_site_grid(site: Dictionary, floor_num: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(Time.get_unix_time_from_system()) + randi() + floor_num * 997

	var site_type: String = site.get("site_type", "resource")
	var size: int = clampi(int(site.get("grid_size", 6)) + int(floor_num / 3), 5, 8)
	var grid: Array = []
	for r in range(size):
		var row: Array = []
		for c in range(size):
			row.append({
				"terrain": "floor",
				"content": "empty",
				"item": "",
				"qty": 0,
				"enemy_id": "",
				"special_type": ""
			})
		grid.append(row)

	for i in range(size):
		grid[0][i]["terrain"] = "wall"
		grid[0][i]["content"] = "wall"
		grid[size - 1][i]["terrain"] = "wall"
		grid[size - 1][i]["content"] = "wall"
		grid[i][0]["terrain"] = "wall"
		grid[i][0]["content"] = "wall"
		grid[i][size - 1]["terrain"] = "wall"
		grid[i][size - 1]["content"] = "wall"

	var start_pos := Vector2i(1, 1)
	var exit_pos := Vector2i(size - 2, size - 2)
	current_site_position = start_pos
	grid[start_pos.x][start_pos.y]["content"] = "player"
	grid[exit_pos.x][exit_pos.y]["content"] = "exit"

	var obstacle_rate := 0.12
	var loot_count := 4
	var enemy_count := 1
	var special_count := 1
	if site_type == "realm":
		obstacle_rate = 0.22
		loot_count = 2 + floor_num
		enemy_count = 2 + floor_num
		special_count = 1
		match site.get("theme", ""):
			"urban":
				obstacle_rate = 0.30
				loot_count += 2
			"historical":
				obstacle_rate = 0.28
				special_count = 2
			"religious":
				obstacle_rate = 0.18
				special_count = 2
			"legendary":
				obstacle_rate = 0.26
				enemy_count += 1
	elif site.get("id", "") == "ammo_cache":
		obstacle_rate = 0.18
		loot_count = 4
		enemy_count = 3

	var obstacle_count: int = int((size - 2) * (size - 2) * obstacle_rate)
	for i in range(obstacle_count):
		var pos := _find_site_position(grid, rng, [start_pos, exit_pos])
		grid[pos.x][pos.y]["terrain"] = "wall"
		grid[pos.x][pos.y]["content"] = "wall"

	for i in range(loot_count):
		var pos := _find_site_position(grid, rng, [start_pos, exit_pos])
		grid[pos.x][pos.y]["content"] = "loot"
		grid[pos.x][pos.y]["item"] = _select_site_loot(site, rng)
		grid[pos.x][pos.y]["qty"] = rng.randi_range(1, 3)

	for i in range(enemy_count):
		var pos := _find_site_position(grid, rng, [start_pos, exit_pos])
		grid[pos.x][pos.y]["content"] = "enemy"
		grid[pos.x][pos.y]["enemy_id"] = _select_site_enemy(site, rng)

	for i in range(special_count):
		var pos := _find_site_position(grid, rng, [start_pos, exit_pos])
		grid[pos.x][pos.y]["content"] = "special"
		grid[pos.x][pos.y]["special_type"] = _select_site_special(site, rng)

	return grid


func _find_site_position(grid: Array, rng: RandomNumberGenerator, excludes: Array = []) -> Vector2i:
	var size: int = grid.size()
	for attempt in range(80):
		var pos := Vector2i(rng.randi_range(1, size - 2), rng.randi_range(1, size - 2))
		if pos in excludes:
			continue
		if grid[pos.x][pos.y].get("content", "empty") == "empty":
			return pos
	return Vector2i(1, 1)


func _select_site_loot(site: Dictionary, rng: RandomNumberGenerator) -> String:
	var site_id: String = site.get("id", "")
	var pool := ["food", "medicine", "cores"]
	if site_id == "abandoned_clinic":
		pool = ["medicine", "medicine", "food", "spirit_battery"]
	elif site_id == "ammo_cache":
		pool = ["ammo", "ammo", "rare_material", "cores"]
	elif site.get("site_type", "") == "realm":
		pool = ["cores", "memory_shards", "tickets", "rare_material", "spirit_core"]
	return pool[rng.randi_range(0, pool.size() - 1)]


func _select_site_enemy(site: Dictionary, rng: RandomNumberGenerator) -> String:
	var pool := ["feral_rat", "mutated_cockroach", "crawler"]
	if site.get("site_type", "") == "realm":
		pool = ["flame_hound", "corrupted_nurse", "mechanical_beast", "rift_shadow"]
	elif site.get("id", "") == "ammo_cache":
		pool = ["crawler", "beast_group", "mechanical_beast"]
	return pool[rng.randi_range(0, pool.size() - 1)]


func _select_site_special(site: Dictionary, rng: RandomNumberGenerator) -> String:
	var pool := ["cache", "rest", "trace"]
	if site.get("site_type", "") == "realm":
		pool = ["cache", "shrine", "trace"]
	return pool[rng.randi_range(0, pool.size() - 1)]


func _show_site_map() -> void:
	_clear_explore_container()
	var site_name: String = current_world_site.get("name", "未知地点")
	explore_status_label.text = "%s · 第 %d/%d 层" % [site_name, current_site_floor, current_site_total_floors]

	var title := Label.new()
	title.text = "【%s 小地图】" % site_name
	_apply_label_style(title, 16, COLOR_AMBER)
	explore_route_container.add_child(title)

	var grid_panel := _make_panel_container()
	explore_route_container.add_child(grid_panel)
	var grid_box := _make_panel_margin(grid_panel, 8)

	var grid_container := GridContainer.new()
	grid_container.columns = current_site_grid.size()
	grid_container.add_theme_constant_override("h_separation", 3)
	grid_container.add_theme_constant_override("v_separation", 3)
	grid_box.add_child(grid_container)

	for r in range(current_site_grid.size()):
		var row: Array = current_site_grid[r]
		for c in range(row.size()):
			var cell: Dictionary = row[c]
			var cell_button := Button.new()
			cell_button.text = _get_site_cell_text(cell, Vector2i(r, c))
			cell_button.custom_minimum_size = Vector2(44, 44)
			cell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(cell_button)
			if cell.get("content", "empty") == "wall":
				cell_button.disabled = true
			else:
				cell_button.pressed.connect(_on_site_cell_pressed.bind(Vector2i(r, c)))
			grid_container.add_child(cell_button)

	var move_row := HBoxContainer.new()
	move_row.add_theme_constant_override("separation", 6)
	explore_route_container.add_child(move_row)
	_add_site_move_button(move_row, "←", Vector2i(0, -1))
	_add_site_move_button(move_row, "↑", Vector2i(-1, 0))
	_add_site_move_button(move_row, "↓", Vector2i(1, 0))
	_add_site_move_button(move_row, "→", Vector2i(0, 1))

	var leave_button := Button.new()
	leave_button.text = "撤离，返回大地图"
	leave_button.custom_minimum_size = Vector2(0, 34)
	leave_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(leave_button)
	leave_button.pressed.connect(_leave_current_site)
	explore_route_container.add_child(leave_button)


func _add_site_move_button(parent: HBoxContainer, label: String, direction: Vector2i) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(button)
	button.pressed.connect(_on_site_direction_pressed.bind(direction))
	parent.add_child(button)


func _get_site_cell_text(cell: Dictionary, pos: Vector2i) -> String:
	if pos == current_site_position:
		return "◎"
	match cell.get("content", "empty"):
		"wall":
			return "■"
		"loot":
			return "资"
		"enemy":
			return "敌"
		"special":
			return "?"
		"exit":
			return "出"
	return "·"


func _on_site_direction_pressed(direction: Vector2i) -> void:
	_try_move_site_player(current_site_position + direction)


func _on_site_cell_pressed(pos: Vector2i) -> void:
	var distance: int = absi(pos.x - current_site_position.x) + absi(pos.y - current_site_position.y)
	if distance != 1:
		_set_home_status("只能移动到相邻格子。")
		return
	_try_move_site_player(pos)


func _try_move_site_player(target_pos: Vector2i) -> void:
	if target_pos.x < 0 or target_pos.y < 0 or target_pos.x >= current_site_grid.size():
		return

	var target_row: Array = current_site_grid[target_pos.x]
	if target_pos.y >= target_row.size():
		return

	var target_cell: Dictionary = target_row[target_pos.y]
	if target_cell.get("content", "empty") == "wall":
		_set_home_status("前方无法通行。")
		return

	var content: String = target_cell.get("content", "empty")
	if content == "exit":
		_on_site_exit_reached()
		return

	var old_row: Array = current_site_grid[current_site_position.x]
	var old_cell: Dictionary = old_row[current_site_position.y]
	var previous_pos: Vector2i = current_site_position

	# 遇敌：先原地等待战斗结算，胜利后再移动到敌人格
	if content == "enemy":
		battle_site_context = {
			"enemy_pos": target_pos,
			"previous_pos": previous_pos
		}
		var battle_started: bool = _process_site_cell(target_cell)
		if not battle_started:
			# 战斗未能开始（无出战伙伴/异兽无效等），保持原位
			battle_data = {}
			battle_site_context = {}
			_refresh_explore()
		return

	old_cell["content"] = "empty"
	current_site_position = target_pos
	_process_site_cell(target_cell)
	target_cell["content"] = "player"
	_refresh_explore()


func _process_site_cell(cell: Dictionary) -> bool:
	match cell.get("content", "empty"):
		"loot":
			var item: String = cell.get("item", "food")
			var qty: int = int(cell.get("qty", 1))
			GameState.player.add_resource(item, qty)
			_set_home_status("拾取：%s×%d。" % [_format_resource_label(item), qty])
			return true
		"enemy":
			var enemy_id: String = cell.get("enemy_id", "")
			if enemy_id != "" and DataManager.beasts.has(enemy_id):
				return _run_battle(enemy_id)
			else:
				_set_home_status("遭遇未知异兽，已将其驱散。")
				return true
		"special":
			_process_site_special(cell.get("special_type", "cache"))
			return true
		_:
			_set_home_status("继续探索。")
			return true


func _process_site_special(special_type: String) -> void:
	match special_type:
		"rest":
			for survivor in GameState.player.survivors:
				survivor["hp"] = survivor.get("max_hp", survivor.get("hp", 0))
			_set_home_status("发现临时休息点，全员恢复。")
		"shrine":
			GameState.player.add_resource("memory_shards", 1)
			_set_home_status("触碰灵能祭坛，获得记忆碎片×1。")
		"trace":
			GameState.player.add_resource("cores", 1)
			_set_home_status("解析异变痕迹，获得晶核×1。")
		_:
			GameState.player.add_resource("food", 2)
			_set_home_status("打开隐藏补给箱，获得口粮×2。")


func _on_site_exit_reached() -> void:
	if current_site_floor < current_site_total_floors:
		current_site_floor += 1
		_generate_current_site_grid()
		_set_home_status("进入%s第 %d 层。" % [current_world_site.get("name", "地点"), current_site_floor])
		_refresh_explore()
		return

	GameState.explore()
	explore_view_mode = "world"
	current_world_site = {}
	current_site_grid = []
	_set_home_status("地点探索完成，时间推进半天。")
	_refresh_all()


func _leave_current_site() -> void:
	explore_view_mode = "world"
	current_world_site = {}
	current_site_grid = []
	_set_home_status("已撤离当前地点，返回大地图。")
	_refresh_explore()


func _format_resource_label(resource_id: String) -> String:
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


func _show_explore_nodes() -> void:
	var current_route: Dictionary = exploration_system.get_current_route()
	var node_index: int = exploration_system.get_current_node_index()
	var nodes: Array = current_route.get("nodes", [])

	if node_index >= nodes.size():
		exploration_system.finish_exploration()
		_set_home_status("探索完成！")
		_refresh_explore()
		return

	var node: Dictionary = nodes[node_index]
	var node_type: String = node.get("type", "search")
	var node_title := Label.new()
	node_title.text = "【%s】%s" % [current_route.get("name", ""), node.get("text", "")]
	_apply_label_style(node_title, 15, COLOR_AMBER)
	node_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explore_route_container.add_child(node_title)

	match node_type:
		"battle":
			var battle_button := Button.new()
			battle_button.text = "⚔️ 进入战斗"
			battle_button.custom_minimum_size = Vector2(0, 34)
			battle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(battle_button)
			battle_button.pressed.connect(_on_battle_node_clicked.bind(node))
			explore_route_container.add_child(battle_button)
		"search":
			var search_button := Button.new()
			search_button.text = "🔍 搜索物资"
			search_button.custom_minimum_size = Vector2(0, 34)
			search_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(search_button)
			search_button.pressed.connect(_on_search_node_clicked.bind(node))
			explore_route_container.add_child(search_button)
		"recruit":
			var recruit_button := Button.new()
			recruit_button.text = "🤝 尝试招募"
			recruit_button.custom_minimum_size = Vector2(0, 34)
			recruit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(recruit_button)
			recruit_button.pressed.connect(_on_recruit_node_clicked.bind(node))
			explore_route_container.add_child(recruit_button)
		"branch":
			_show_branch_options(node)
		"shop":
			_show_shop_options(node)
		"boss":
			var boss_button := Button.new()
			boss_button.text = "💀 挑战BOSS"
			boss_button.custom_minimum_size = Vector2(0, 34)
			boss_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(boss_button)
			boss_button.pressed.connect(_on_boss_node_clicked.bind(node))
			explore_route_container.add_child(boss_button)

	var back_button := Button.new()
	back_button.text = "← 返回集结地"
	back_button.custom_minimum_size = Vector2(0, 32)
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(back_button)
	back_button.pressed.connect(_on_abandon_exploration)
	explore_route_container.add_child(back_button)


func _show_branch_options(node: Dictionary) -> void:
	var options: Array = node.get("options", [])
	for option in options:
		var option_button := Button.new()
		option_button.text = "➡️ %s" % option.get("text", "未知选项")
		option_button.custom_minimum_size = Vector2(0, 34)
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(option_button)
		option_button.pressed.connect(_on_branch_option_clicked.bind(option))
		explore_route_container.add_child(option_button)


func _show_shop_options(node: Dictionary) -> void:
	var trades: Array = node.get("trades", [])
	for trade in trades:
		var cost_text := _format_resources(trade.get("cost", {}))
		var reward_text := _format_resources(trade.get("reward", {}))
		var trade_button := Button.new()
		trade_button.text = "💰 %s → %s" % [cost_text, reward_text]
		trade_button.custom_minimum_size = Vector2(0, 34)
		trade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(trade_button)
		trade_button.pressed.connect(_on_shop_trade_clicked.bind(trade))
		explore_route_container.add_child(trade_button)


func _format_resources(resources: Dictionary) -> String:
	var parts: Array[String] = []
	for key in resources:
		var value: Variant = resources[key]
		var label: String = str(key)
		match key:
			"food":
				label = "口粮"
			"medicine":
				label = "药品"
			"cores":
				label = "晶核"
			"memory_shards":
				label = "记忆碎片"
			"tickets":
				label = "补给券"
			"spirit_battery":
				label = "灵能电池"
			"ammo":
				label = "弹药"
			"rare_material":
				label = "稀有材料"
			"spirit_core":
				label = "灵核"
			"equipment":
				label = "装备"
			"item":
				label = "物品"
			"relic":
				label = "遗物"
			"skill_book":
				label = "技能书"
		parts.append("%s×%s" % [label, str(value)])
	return "、".join(parts)


func _on_route_clicked(route: Dictionary) -> void:
	if GameState.player.supplies.get("food", 0) <= 0:
		_set_home_status("口粮不足，无法探索！请先获取口粮。")
		return

	exploration_system.start_exploration(route)
	_refresh_explore()


func _on_battle_node_clicked(node: Dictionary) -> void:
	var battle_id: String = node.get("battle_id", "")
	if battle_id == "":
		_set_home_status("该节点没有配置异兽。")
		return
	battle_callback = func() -> void:
		_apply_node_effects(node.get("effects", {}))
		exploration_system.advance_node()
		_refresh_explore()
	_run_battle(battle_id)


func _on_search_node_clicked(node: Dictionary) -> void:
	var result: Dictionary = exploration_system.process_node(node, GameState.player)
	var reward_text := "搜索完成！"
	var effects: Dictionary = result.get("effects", {})
	if effects.size() > 0:
		reward_text += "\n" + _format_resources(effects)
	_set_home_status(reward_text)
	exploration_system.advance_node()
	_refresh_explore()


func _on_recruit_node_clicked(node: Dictionary) -> void:
	var result: Dictionary = exploration_system.process_node(node, GameState.player)
	if result.get("type", "") == "recruit_failed":
		_set_home_status(result.get("result", "资源不足，无法招募。"))
		return

	var partner_id: String = result.get("join_partner", "")
	if partner_id == "":
		_set_home_status("该节点没有配置伙伴。")
		exploration_system.advance_node()
		_refresh_explore()
		return

	_recruit_partner(partner_id)
	exploration_system.advance_node()
	_refresh_explore()


func _on_branch_option_clicked(option: Dictionary) -> void:
	var result: Dictionary = exploration_system.process_branch_option(option, GameState.player)
	var result_type: String = result.get("type", "effect")

	match result_type:
		"battle":
			var battle_id: String = result.get("battle_id", "")
			if battle_id != "":
				battle_callback = func() -> void:
					_set_home_status(result.get("text", ""))
					exploration_system.advance_node()
					_refresh_explore()
				_run_battle(battle_id)
				return
			_set_home_status(result.get("text", ""))
		"recruit":
			_recruit_partner(result.get("join_partner", ""))
		"ending":
			_set_home_status("触发结局：" + result.get("ending", ""))
		_:
			var text: String = result.get("text", "")
			var effects: Dictionary = result.get("effects", {})
			if effects.size() > 0:
				text += "\n" + _format_resources(effects)
			_set_home_status(text)

	exploration_system.advance_node()
	_refresh_explore()


func _on_shop_trade_clicked(trade: Dictionary) -> void:
	var result: Dictionary = exploration_system.process_shop_trade(trade, GameState.player)
	if result.get("success", false):
		var reward: Dictionary = result.get("reward", {})
		var reward_text := "交易成功！"
		if reward.size() > 0:
			reward_text += "\n获得：" + _format_resources(reward)
		_set_home_status(reward_text)
	else:
		_set_home_status(result.get("text", "交易失败。"))
	_refresh_explore()


func _on_boss_node_clicked(node: Dictionary) -> void:
	var battle_id: String = node.get("battle_id", "")
	if battle_id == "":
		_set_home_status("该节点没有配置BOSS。")
		return
	battle_callback = func() -> void:
		_apply_node_effects(node.get("effects", {}))
		_recruit_partner(node.get("join_partner", ""), "击败BOSS！%s 加入了队伍（替补席）。")
		exploration_system.advance_node()
		_refresh_explore()
	_run_battle(battle_id)


func _apply_node_effects(effects: Dictionary) -> void:
	for key in effects:
		var value: Variant = effects[key]
		if value is int or value is float:
			GameState.player.add_resource(key, int(value))


func _recruit_partner(partner_id: String, success_text: String = "招募成功！%s 加入了队伍（替补席）。") -> void:
	if partner_id == "":
		return

	for survivor in GameState.player.survivors:
		if survivor["id"] == partner_id:
			_set_home_status("该伙伴已在队伍中。")
			return

	for partner in DataManager.partners:
		if partner.get("id") == partner_id:
			GameState.player.survivors.append(partner.duplicate(true))
			if not (partner_id in GameState.player.reserve_survivor_ids):
				GameState.player.reserve_survivor_ids.append(partner_id)
			_set_home_status(success_text % partner.get("name", partner_id))
			return


func _on_abandon_exploration() -> void:
	exploration_system.abandon_exploration()
	_set_home_status("已放弃探索，返回集结地。")
	_refresh_explore()


func _run_battle(beast_id: String) -> bool:
	if not DataManager.beasts.has(beast_id):
		battle_data = {}
		battle_site_context = {}
		return false
	var beast: Dictionary = DataManager.beasts[beast_id].duplicate(true)
	# Boss动态公式 + 轮回词缀（仅对 BOSS 类型生效）
	if str(beast.get("type", "")) == "BOSS":
		_apply_boss_scaling(beast)
	var player := GameState.player
	var party: Array = []
	var grid_indices: Array = []
	for i in range(9):
		var sid: String = player.get_grid_survivor(i)
		if sid != "":
			for s in player.survivors:
				if s.get("id", "") == sid:
					party.append(s)
					grid_indices.append(i)
					break
		if party.size() >= BattleSystem.MAX_PARTY_SIZE:
			break
	if party.is_empty():
		battle_data = {}
		battle_site_context = {}
		_set_home_status("没有可出战的伙伴，请先在编队中上阵。")
		return false

	battle_data = BattleSystem.create_battle(party, [beast], player.get_formation_bonus(), grid_indices)
	battle_auto_mode = "manual"
	battle_finished = false
	battle_waiting_input = false
	battle_data["mode"] = battle_auto_mode
	for mode in battle_mode_buttons:
		battle_mode_buttons[mode].button_pressed = (mode == "manual")

	battle_popup.popup_centered()
	_refresh_battle_ui()
	_process_battle_turn()
	return true


# 应用Boss动态公式与轮回词缀
func _apply_boss_scaling(beast: Dictionary) -> void:
	var player := GameState.player
	var base_stats := {
		"hp": beast.get("hp", 0),
		"attack": beast.get("attack", 0),
		"defense": beast.get("defense", 0),
		"spirit": beast.get("spirit", 0),
		"resistance": beast.get("resistance", 0)
	}
	var scaled: Dictionary = player.get_scaled_boss_stats(base_stats)
	beast["hp"] = scaled.get("hp", beast.get("hp", 0))
	beast["attack"] = scaled.get("attack", beast.get("attack", 0))
	beast["defense"] = scaled.get("defense", beast.get("defense", 0))
	beast["spirit"] = scaled.get("spirit", beast.get("spirit", 0))
	beast["resistance"] = scaled.get("resistance", beast.get("resistance", 0))
	# 轮回词缀
	var affixes: Array = player.get_reincarnation_affixes()
	if not affixes.is_empty():
		beast["affixes"] = affixes
		# 复杂词缀数值简化：极光记忆、轮回共鸣
		for affix in affixes:
			var affix_id := str(affix.get("id", ""))
			if affix_id == "aurora_memory":
				beast["attack"] = int(round(float(beast["attack"]) * 1.25))
			elif affix_id == "reincarnation_resonance":
				var bonus := 1.0 + 0.1 * float(player.reincarnation)
				beast["hp"] = int(round(float(beast["hp"]) * bonus))
				beast["attack"] = int(round(float(beast["attack"]) * bonus))
				beast["defense"] = int(round(float(beast["defense"]) * bonus))
				beast["spirit"] = int(round(float(beast["spirit"]) * bonus))
				beast["resistance"] = int(round(float(beast["resistance"]) * bonus))


# ============================================================
# 战斗流程控制
# ============================================================
func _process_battle_turn() -> void:
	if battle_data.is_empty() or battle_finished:
		return
	if battle_data.get("battle_over", false):
		_finish_battle()
		return
	_refresh_battle_ui()

	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id == "":
		_finish_battle()
		return

	if not BattleSystem.is_actor_player(battle_data, actor_id):
		_update_battle_controls(false)
		_auto_execute_ai(actor_id)
	elif battle_auto_mode == "auto":
		_update_battle_controls(false)
		_auto_execute_ai(actor_id)
	elif battle_auto_mode == "semi":
		_update_battle_controls(false)
		_auto_basic_decision(actor_id)
	else:
		battle_waiting_input = true
		_update_battle_controls(true)
		var actor: Dictionary = battle_data["units"][actor_id]
		battle_actor_label.text = "当前行动：%s（请操作）" % actor["name"]


func _auto_execute_ai(actor_id: String) -> void:
	var action: Dictionary = BattleSystem.decide_ai_action(battle_data, actor_id)
	await get_tree().create_timer(0.45).timeout
	if battle_finished or battle_data.is_empty():
		return
	_apply_battle_action(action)
	_process_battle_turn()


func _auto_basic_decision(actor_id: String) -> void:
	await get_tree().create_timer(0.35).timeout
	if battle_finished or battle_data.is_empty():
		return
	var hp_ratio: float = BattleSystem.get_unit_hp_ratio(battle_data, actor_id)
	if hp_ratio < 0.3:
		BattleSystem.perform_action(battle_data, actor_id, "guard")
	else:
		var alive_enemies: Array = BattleSystem.get_alive_team_units(battle_data, "enemy")
		var target_id: String = BattleSystem.get_team_lowest_hp_unit(battle_data, "enemy")
		if target_id == "" and not alive_enemies.is_empty():
			target_id = str(alive_enemies[0])
		BattleSystem.perform_action(battle_data, actor_id, "attack", [target_id] if target_id != "" else [])
	_process_battle_turn()


func _apply_battle_action(action: Dictionary) -> void:
	if battle_data.is_empty() or battle_finished:
		return
	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id == "":
		return
	var action_type: String = str(action.get("action", "attack"))
	var target_id: String = str(action.get("target_id", ""))
	var target_ids: Array = [target_id] if target_id != "" else []
	if action_type == "skill":
		BattleSystem.perform_action(battle_data, actor_id, "skill", target_ids, str(action.get("skill_id", "")))
	else:
		BattleSystem.perform_action(battle_data, actor_id, action_type, target_ids)


# ============================================================
# 战斗UI刷新
# ============================================================
func _refresh_battle_ui() -> void:
	if battle_data.is_empty():
		return
	battle_round_label.text = "⚔️ 战斗 · 回合 %d" % int(battle_data.get("round", 1))

	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id != "":
		var actor: Dictionary = battle_data["units"][actor_id]
		var team_text := "我方" if actor.get("team", "") == "player" else "敌方"
		battle_actor_label.text = "当前行动：%s[%s]%s" % [
			actor.get("name", ""),
			team_text,
			"（防御中）" if actor.get("guard", false) else ""
		]

	# 敌方信息
	for child in battle_enemy_container.get_children():
		battle_enemy_container.remove_child(child)
		child.queue_free()
	var enemy_alive: Array = BattleSystem.get_alive_team_units(battle_data, "enemy")
	for enemy_id in enemy_alive:
		var unit: Dictionary = battle_data["units"][enemy_id]
		var status_parts: Array[String] = []
		for sid in unit.get("statuses", {}):
			status_parts.append(BattleSystem.STATUS_NAMES.get(sid, sid))
		var status_text := ("  [%s]" % "、".join(status_parts)) if not status_parts.is_empty() else ""
		var enemy_label := Label.new()
		enemy_label.text = "%s  HP %d/%d%s" % [unit.get("name", ""), int(unit.get("hp", 0)), int(unit.get("max_hp", 0)), status_text]
		_apply_label_style(enemy_label, 14, Color(0.95, 0.4, 0.45))
		battle_enemy_container.add_child(enemy_label)

	# 状态摘要
	var status_text_all: String = BattleSystem.get_battle_status_text(battle_data)
	battle_status_label.text = ("状态：\n" + status_text_all) if status_text_all != "" else "状态：无"

	# 战斗日志
	battle_log_label.text = ""
	for line in battle_data.get("log", []):
		battle_log_label.append_text(_battle_log_line_to_bbcode(str(line)))

	# 我方队伍卡片
	for child in battle_party_container.get_children():
		battle_party_container.remove_child(child)
		child.queue_free()
	for unit_id in battle_data.get("player_party", []):
		var unit: Dictionary = battle_data["units"][unit_id]
		var card := Label.new()
		card.text = "%s\nHP %d/%d\nEP %d/%d" % [
			unit.get("name", ""),
			int(unit.get("hp", 0)), int(unit.get("max_hp", 0)),
			int(unit.get("energy", 0)), int(unit.get("max_energy", 0))
		]
		card.custom_minimum_size = Vector2(84, 0)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_apply_label_style(card, 12, COLOR_TEXT)
		card.add_theme_stylebox_override("normal", _make_flat_style(Color(0.08, 0.12, 0.14, 0.9), Color(0.3, 0.6, 0.65, 0.8), 1, 4, 4))
		if actor_id == unit_id and BattleSystem.is_actor_player(battle_data, actor_id):
			card.add_theme_stylebox_override("normal", _make_flat_style(Color(0.10, 0.20, 0.22, 0.96), COLOR_AMBER, 2, 4, 4))
		battle_party_container.add_child(card)


func _battle_log_line_to_bbcode(line: String) -> String:
	if line.begins_with("——"):
		return "[color=#00D4FF]%s[/color]\n" % line
	if line.begins_with("🎉"):
		return "[color=#FFC107]%s[/color]\n" % line
	if line.begins_with("💀"):
		return "[color=#FF5252]%s[/color]\n" % line
	if line.find("被击败") >= 0 or line.find("失败") >= 0:
		return "[color=#FF6E6E]%s[/color]\n" % line
	if line.find("暴击") >= 0:
		return "[color=#FFC107]%s[/color]\n" % line
	return "[color=#E0F5FF]%s[/color]\n" % line


func _update_battle_controls(enabled: bool) -> void:
	for child in battle_action_bar.get_children():
		child.disabled = not enabled
	if battle_flee_button != null:
		battle_flee_button.disabled = false
	for mode in battle_mode_buttons:
		battle_mode_buttons[mode].disabled = battle_data.is_empty()


# ============================================================
# 战斗按钮操作
# ============================================================
func _on_battle_attack_pressed() -> void:
	if not battle_waiting_input:
		return
	battle_pending_action = {"type": "attack", "skill_id": ""}
	_open_target_popup("enemy")


func _on_battle_skill_pressed() -> void:
	if not battle_waiting_input:
		return
	_open_skill_popup()


func _on_battle_guard_pressed() -> void:
	if not battle_waiting_input:
		return
	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id == "":
		return
	battle_waiting_input = false
	_update_battle_controls(false)
	BattleSystem.perform_action(battle_data, actor_id, "guard")
	_process_battle_turn()


func _on_battle_item_pressed() -> void:
	_set_home_status("道具功能开发中，请使用攻击/技能/防御。")


func _on_battle_mode_pressed(mode: String) -> void:
	battle_auto_mode = mode
	for m in battle_mode_buttons:
		battle_mode_buttons[m].button_pressed = (m == mode)
	if battle_data.is_empty() or battle_finished or not battle_waiting_input:
		return
	if mode != "manual":
		battle_waiting_input = false
		_update_battle_controls(false)
		_process_battle_turn()


func _on_battle_close_pressed() -> void:
	# 撤退也同步当前 HP，避免关闭战斗弹窗无损撤离
	_finish_battle(true, true)


func _show_battle_overlay(kind: String) -> void:
	if battle_overlay_panel == null:
		return
	var border_color := COLOR_AMBER if kind == "skill" else COLOR_CYAN
	battle_overlay_panel.add_theme_stylebox_override("panel", _make_flat_style(Color(0.03, 0.05, 0.06, 0.98), border_color, 2, 5, 0))
	battle_overlay_panel.visible = true
	battle_overlay_panel.move_to_front()


func _hide_battle_overlay() -> void:
	if battle_overlay_panel != null:
		battle_overlay_panel.visible = false


func _open_skill_popup() -> void:
	if battle_data.is_empty():
		return
	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id == "":
		return
	_show_battle_overlay("skill")
	var vbox: VBoxContainer = battle_overlay_box
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	var title := Label.new()
	title.text = "✨ 选择技能"
	_apply_label_style(title, 18, COLOR_AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var usable: Array = BattleSystem.get_usable_skills(battle_data, actor_id)
	if usable.is_empty():
		var empty := Label.new()
		empty.text = "没有可用技能（能量不足或冷却中）\n可以使用攻击或防御。"
		_apply_label_style(empty, 13, COLOR_MUTED)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(empty)
	else:
		for skill_id in usable:
			var skill: Dictionary = DataManager.skills.get(skill_id, {})
			var skill_btn := Button.new()
			skill_btn.text = "%s  (EP %d)" % [skill.get("name", skill_id), int(skill.get("energy", 0))]
			skill_btn.custom_minimum_size = Vector2(0, 40)
			skill_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_apply_button_style(skill_btn)
			skill_btn.pressed.connect(_on_skill_selected.bind(skill_id))
			vbox.add_child(skill_btn)

	var cancel := Button.new()
	cancel.text = "取消"
	cancel.custom_minimum_size = Vector2(0, 32)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(cancel)
	cancel.pressed.connect(func() -> void: _hide_battle_overlay())
	vbox.add_child(cancel)


func _on_skill_selected(skill_id: String) -> void:
	_hide_battle_overlay()
	var skill: Dictionary = DataManager.skills.get(skill_id, {})
	var type_text: String = str(skill.get("type", ""))
	if type_text.find("全体") >= 0 or type_text.begins_with("辅助"):
		_confirm_battle_action("skill", skill_id, [])
		return
	battle_pending_action = {"type": "skill", "skill_id": skill_id}
	_open_target_popup("enemy")


func _open_target_popup(team: String) -> void:
	if battle_data.is_empty():
		return
	_show_battle_overlay("target")
	var vbox: VBoxContainer = battle_overlay_box
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	var title := Label.new()
	title.text = "🎯 选择目标"
	_apply_label_style(title, 18, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var targets: Array = BattleSystem.get_alive_team_units(battle_data, team)
	for target_id in targets:
		var unit: Dictionary = battle_data["units"][target_id]
		var target_btn := Button.new()
		target_btn.text = "%s  HP %d/%d" % [unit.get("name", ""), int(unit.get("hp", 0)), int(unit.get("max_hp", 0))]
		target_btn.custom_minimum_size = Vector2(0, 40)
		target_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(target_btn)
		target_btn.pressed.connect(_on_target_selected.bind(target_id))
		vbox.add_child(target_btn)

	var cancel := Button.new()
	cancel.text = "取消"
	cancel.custom_minimum_size = Vector2(0, 32)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(cancel)
	cancel.pressed.connect(func() -> void: _hide_battle_overlay())
	vbox.add_child(cancel)


func _on_target_selected(target_id: String) -> void:
	_hide_battle_overlay()
	if battle_pending_action.is_empty():
		return
	var action_type: String = str(battle_pending_action.get("type", "attack"))
	var skill_id: String = str(battle_pending_action.get("skill_id", ""))
	battle_pending_action = {}
	_confirm_battle_action(action_type, skill_id, [target_id])


func _confirm_battle_action(action_type: String, skill_id: String, target_ids: Array) -> void:
	if not battle_waiting_input:
		return
	var actor_id: String = BattleSystem.get_current_actor(battle_data)
	if actor_id == "":
		return
	battle_waiting_input = false
	_update_battle_controls(false)
	if action_type == "skill":
		BattleSystem.perform_action(battle_data, actor_id, "skill", target_ids, skill_id)
	else:
		BattleSystem.perform_action(battle_data, actor_id, action_type, target_ids)
	_process_battle_turn()


# ============================================================
# 战斗结算
# ============================================================
func _finish_battle(sync_hp: bool = true, is_retreat: bool = false) -> void:
	if battle_finished:
		return
	battle_finished = true
	battle_waiting_input = false
	_update_battle_controls(false)

	var victory: bool = battle_data.get("victory", false)
	var enemy_name := ""
	var enemy_base_id := ""
	if not battle_data.is_empty() and not battle_data["enemy_party"].is_empty():
		var first_enemy_id: String = str(battle_data["enemy_party"][0])
		if battle_data["units"].has(first_enemy_id):
			enemy_name = str(battle_data["units"][first_enemy_id].get("name", ""))
			enemy_base_id = str(battle_data["units"][first_enemy_id].get("base_id", first_enemy_id))

	if sync_hp and not battle_data.is_empty():
		_sync_battle_results()

	battle_popup.hide()
	_hide_battle_overlay()
	if sync_hp and victory and enemy_base_id != "":
		var defeated_beasts: Array = GameState.player.story_flags.get("defeated_beasts", [])
		if not (enemy_base_id in defeated_beasts):
			defeated_beasts.append(enemy_base_id)
			GameState.player.story_flags["defeated_beasts"] = defeated_beasts
	battle_data = {}

	# 小地图遇敌结算：胜利则占领先前敌人格，失败/撤退则退回大地图
	var site_context: Dictionary = battle_site_context
	battle_site_context = {}
	if not site_context.is_empty():
		if sync_hp and victory:
			_occupy_site_enemy_cell(site_context)
		else:
			explore_view_mode = "world"
			current_world_site = {}
			current_site_grid = []
			current_site_position = Vector2i.ZERO
			current_site_floor = 1
			current_site_total_floors = 1

	if sync_hp:
		if victory:
			_set_home_status("战斗胜利！%s 已被击败。" % enemy_name)
		elif is_retreat:
			if not site_context.is_empty():
				_set_home_status("已撤离战斗，队员伤势已同步，返回大地图。")
			else:
				_set_home_status("已撤离战斗，队员伤势已同步。")
		else:
			if not site_context.is_empty():
				_set_home_status("战斗失败……已退回大地图，请先治疗伙伴再战。")
			else:
				_set_home_status("战斗失败……伙伴们倒下了，请治疗后再战。")
	else:
		_set_home_status("已撤离战斗。")
	_refresh_all()

	var callback := battle_callback
	battle_callback = Callable()
	if sync_hp and victory and callback.is_valid():
		callback.call()


func _occupy_site_enemy_cell(context: Dictionary) -> void:
	if current_site_grid.is_empty():
		return
	# 清理战斗前所在格（玩家在战斗期间没有真正移动）
	var previous_pos: Vector2i = context.get("previous_pos", Vector2i.ZERO)
	if previous_pos.x >= 0 and previous_pos.y >= 0 and previous_pos.x < current_site_grid.size():
		var prev_row: Array = current_site_grid[previous_pos.x]
		if previous_pos.y < prev_row.size():
			prev_row[previous_pos.y]["content"] = "empty"
	# 占领敌人所在格
	var enemy_pos: Vector2i = context.get("enemy_pos", Vector2i.ZERO)
	if enemy_pos.x >= 0 and enemy_pos.y >= 0 and enemy_pos.x < current_site_grid.size():
		var enemy_row: Array = current_site_grid[enemy_pos.x]
		if enemy_pos.y < enemy_row.size():
			enemy_row[enemy_pos.y]["content"] = "player"
			current_site_position = enemy_pos


func _sync_battle_results() -> void:
	if battle_data.is_empty():
		return
	for unit_id in battle_data["units"]:
		var unit: Dictionary = battle_data["units"][unit_id]
		if unit.get("team", "") != "player":
			continue
		var base_id: String = str(unit.get("base_id", ""))
		for survivor in GameState.player.survivors:
			if survivor.get("id", "") == base_id:
				survivor["hp"] = maxf(0.0, float(unit.get("hp", 0.0)))
				survivor["energy"] = float(unit.get("energy", 0.0))
				break


func _refresh_inventory() -> void:
	var player := GameState.player
	inventory_label.text = "【消耗品】\n口粮 ×%d/%d\n药品 ×%d/%d\n\n【材料】\n晶核 ×%d\n记忆碎片 ×%d\n补给券 ×%d\n灵能电池 ×%d\n弹药 ×%d\n稀有材料 ×%d\n灵核 ×%d" % [
		player.supplies.get("food", 0), player.resource_caps.get("food", 99),
		player.supplies.get("medicine", 0), player.resource_caps.get("medicine", 99),
		player.materials.get("cores", 0),
		player.materials.get("memory_shards", 0),
		player.materials.get("tickets", 0),
		player.materials.get("spirit_battery", 0),
		player.materials.get("ammo", 0),
		player.materials.get("rare_material", 0),
		player.materials.get("spirit_core", 0)
	]


func _refresh_codex() -> void:
		if codex_content_container == null:
			return

		_clear_container(codex_content_container)

		match codex_view_mode:
			"categories":
				_show_codex_categories()
			"beasts":
				_show_beast_codex_list()
			"bosses":
				_show_boss_codex_list()
			"boss_detail":
				_show_boss_codex_detail(selected_codex_boss_id)
			"partners":
				_show_partner_codex_list()
			"equipment":
				_show_placeholder_codex("装备图鉴", "装备配置表尚未接入。后续可从装备、配方、掉落材料生成装备条目。")
			"relics":
				_show_placeholder_codex("遗物图鉴", "遗物配置表尚未接入。后续可按秘境、BOSS、主线章节补充遗物条目。")
			"detail":
				_show_beast_codex_detail(selected_codex_beast_id)
			"info":
				_show_beast_codex_full_info(selected_codex_beast_id)
			_:
				_show_codex_categories()


func _show_codex_categories() -> void:
		selected_codex_category = ""
		selected_codex_beast_id = ""
		selected_codex_boss_id = ""

		var player := GameState.player
		var defeated_beasts: Array = player.story_flags.get("defeated_beasts", [])

		var title := Label.new()
		title.text = "请选择图鉴分类"
		_apply_label_style(title, 16, COLOR_AMBER)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		codex_content_container.add_child(title)

		_add_codex_category_button(
			"beasts",
			"怪物图鉴",
			"%d/%d 已记录 · 查看异兽、BOSS、掉落和应对" % [defeated_beasts.size(), DataManager.beasts.size()]
		)
		_add_codex_category_button(
			"partners",
			"人物图鉴",
			"%d/%d 已加入 · 查看伙伴、职业和基础信息" % [player.survivors.size(), DataManager.partners.size()]
		)
		_add_codex_category_button(
			"equipment",
			"装备图鉴",
			"待接入 · 武器、防具、消耗品和合成装备"
		)
		_add_codex_category_button(
			"relics",
			"遗物图鉴",
			"待接入 · 秘境遗物、BOSS 掉落和主线收藏"
		)
		_add_codex_category_button(
			"bosses",
			"Boss 情报图鉴",
			"主线Boss · 已解析情报、弱点与背景故事"
		)


func _add_codex_category_button(category_id: String, title: String, description: String) -> void:
		var button := Button.new()
		button.text = "%s\n%s" % [title, description]
		button.custom_minimum_size = Vector2(0, 66)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_apply_button_style(button)
		button.pressed.connect(_on_codex_category_pressed.bind(category_id))
		codex_content_container.add_child(button)


# ============================================================
# Boss 情报图鉴
# ============================================================
func _show_boss_codex_list() -> void:
	_add_codex_category_back_button()

	var player := GameState.player
	var bosses: Array = DataManager.main_story.get("bosses", [])
	var summary := Label.new()
	summary.text = "【Boss 情报图鉴】共 %d 个主线 Boss\n情报随遭遇 / 击败 / 轮回逐步解锁。" % bosses.size()
	_apply_label_style(summary, 14, COLOR_MUTED)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_content_container.add_child(summary)

	for boss_cfg in bosses:
		if not boss_cfg is Dictionary:
			continue
		var boss: Dictionary = boss_cfg
		var boss_id: String = str(boss.get("id", ""))
		if boss_id == "":
			continue
		var display_name: String = player.get_boss_display_name(boss_id)
		var state: Dictionary = player.get_boss_intel_state(boss_id)
		var defeated: bool = bool(state.get("defeated", false))
		var progress: float = player.get_boss_intel_progress(boss_id)
		var button := Button.new()
		button.text = "%s  %s\n解析进度 %d%% · 第%s章" % [
			display_name,
			"已击败" if defeated else "未击败",
			int(progress * 100.0),
			str(boss.get("chapter", "?"))
		]
		button.custom_minimum_size = Vector2(0, 58)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_apply_button_style(button)
		button.pressed.connect(_on_codex_boss_pressed.bind(boss_id))
		codex_content_container.add_child(button)


func _show_boss_codex_detail(boss_id: String) -> void:
	var player := GameState.player
	var boss_cfg := player.get_boss_config(boss_id)
	if boss_cfg.is_empty():
		_show_boss_codex_list()
		return
	_add_codex_category_back_button()

	var boss: Dictionary = boss_cfg
	var display_name: String = player.get_boss_display_name(boss_id)
	var state: Dictionary = player.get_boss_intel_state(boss_id)
	var progress: float = player.get_boss_intel_progress(boss_id)

	var title := Label.new()
	title.text = "📖 Boss图鉴 · %s" % display_name
	_apply_label_style(title, 16, COLOR_AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	codex_content_container.add_child(title)

	var stats: Dictionary = boss.get("base_stats", {})
	var encounter_count := 1 if bool(state.get("encountered", false)) else 0
	var info_label := Label.new()
	info_label.text = "HP %d · 攻击 %d · 防御 %d · 推荐等级 LV %d\n遭遇 %d 次 · 击败 %d 次 · 解析进度 %d%%" % [
		int(stats.get("hp", 0)),
		int(stats.get("attack", 0)),
		int(stats.get("defense", 0)),
		int(boss.get("recommended_level", 0)),
		encounter_count,
		int(state.get("kill_count", 0)),
		int(progress * 100.0)
	]
	_apply_label_style(info_label, 13, COLOR_MUTED)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_content_container.add_child(info_label)

	var unlocked: Array = player.get_boss_unlocked_intel(boss_id)
	var intel_text := "【已解锁情报】\n"
	if unlocked.is_empty():
		intel_text += "尚未解锁任何情报。\n"
	else:
		for item in unlocked:
			intel_text += "✅ %s：%s\n" % [str(item.get("label", "")), str(item.get("value", ""))]
	var intel: Dictionary = boss.get("intel", {})
	for info in intel.get("weakness_info", []):
		if info is Dictionary and not bool(info.get("confirmed", false)):
			intel_text += "⏳ 弱点：???（待发现）\n"
	var intel_label := Label.new()
	intel_label.text = intel_text
	_apply_label_style(intel_label, 13)
	intel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_content_container.add_child(intel_label)

	var lore_unlocked: bool = bool(state.get("lore_unlocked", false))
	if lore_unlocked and intel.has("lore"):
		var lore_label := Label.new()
		lore_label.text = "【背景故事】\n%s" % str(intel.get("lore", ""))
		_apply_label_style(lore_label, 13, COLOR_MUTED)
		lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(lore_label)


func _on_codex_boss_pressed(boss_id: String) -> void:
	selected_codex_boss_id = boss_id
	codex_view_mode = "boss_detail"
	_refresh_codex()


func _show_partner_codex_list() -> void:
		_add_codex_category_back_button()

		var player := GameState.player
		var summary := Label.new()
		summary.text = "【人物图鉴】%d/%d\n当前显示已加入队伍的伙伴；未加入人物后续可做锁定条目。" % [
			player.survivors.size(),
			DataManager.partners.size()
		]
		_apply_label_style(summary, 14, COLOR_MUTED)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(summary)

		var list: Array = player.survivors
		if list.is_empty():
			list = DataManager.partners

		for partner in list:
			if not partner is Dictionary:
				continue
			var partner_data: Dictionary = partner
			var raw_stats: Variant = partner_data.get("stats", {})
			var stats: Dictionary = {}
			if raw_stats is Dictionary:
				stats = raw_stats
			var button := Button.new()
			button.text = "%s  Lv.%d  %s\n%s  HP %d  攻击 %d  防御 %d" % [
				partner_data.get("name", partner_data.get("id", "未知人物")),
				int(partner_data.get("level", 1)),
				partner_data.get("profession", "未知职业"),
				partner_data.get("rarity", partner_data.get("title", "")),
				int(partner_data.get("max_hp", partner_data.get("hp", 0))),
				int(stats.get("attack", 0)),
				int(stats.get("defense", 0))
			]
			button.custom_minimum_size = Vector2(0, 58)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_apply_button_style(button)
			codex_content_container.add_child(button)


func _show_placeholder_codex(title_text: String, description: String) -> void:
		_add_codex_category_back_button()

		var title := Label.new()
		title.text = "【%s】" % title_text
		_apply_label_style(title, 16, COLOR_AMBER)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		codex_content_container.add_child(title)

		var label := Label.new()
		label.text = description
		_apply_label_style(label, 14, COLOR_MUTED)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(label)


func _add_codex_category_back_button() -> void:
		var back_button := Button.new()
		back_button.text = "返回图鉴分类"
		back_button.custom_minimum_size = Vector2(0, 34)
		back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(back_button)
		back_button.pressed.connect(_on_codex_back_to_categories_pressed)
		codex_content_container.add_child(back_button)


func _show_beast_codex_list() -> void:
		_add_codex_category_back_button()

		var player := GameState.player
		var defeated_beasts: Array = player.story_flags.get("defeated_beasts", [])

		var summary := Label.new()
		summary.text = "【异兽图鉴】%d/%d\n点击怪物条目查看详情。" % [
				defeated_beasts.size(),
				DataManager.beasts.size()
		]
		_apply_label_style(summary, 14, COLOR_MUTED)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(summary)

		var beast_ids: Array = DataManager.beasts.keys()
		beast_ids.sort()
		for beast_id_variant in beast_ids:
				var beast_id := str(beast_id_variant)
				if not DataManager.beasts.has(beast_id):
						continue
				var beast: Dictionary = DataManager.beasts[beast_id]
				var codex: Dictionary = _get_beast_codex_entry(beast_id)
				var threat := str(codex.get("threat_level", _threat_from_beast_type(str(beast.get("type", "")))))
				var button := Button.new()
				button.text = "%s  Lv.%d  [%s]\n%s" % [
						beast.get("name", beast_id),
						int(beast.get("level", 1)),
						threat,
						codex.get("battle_role", "暂无详细记录")
				]
				button.custom_minimum_size = Vector2(0, 58)
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				button.alignment = HORIZONTAL_ALIGNMENT_LEFT
				_apply_button_style(button)
				button.pressed.connect(_on_codex_beast_pressed.bind(beast_id))
				codex_content_container.add_child(button)


func _show_beast_codex_detail(beast_id: String) -> void:
		if not DataManager.beasts.has(beast_id):
			codex_view_mode = "beasts"
			_show_beast_codex_list()
			return

		var beast: Dictionary = DataManager.beasts[beast_id]
		var codex: Dictionary = _get_beast_codex_entry(beast_id)
		var asset: Dictionary = _get_beast_asset_entry(beast_id)

		var back_button := Button.new()
		back_button.text = "返回图鉴"
		back_button.custom_minimum_size = Vector2(0, 34)
		back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(back_button)
		back_button.pressed.connect(_on_codex_back_to_list_pressed)
		codex_content_container.add_child(back_button)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		codex_content_container.add_child(row)

		var image_button := Button.new()
		var display_texture := _get_beast_display_texture(beast_id)
		image_button.text = "" if display_texture != null else "暂无图像"
		image_button.icon = display_texture
		image_button.expand_icon = true
		image_button.custom_minimum_size = Vector2(120, 120)
		image_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		image_button.tooltip_text = "点击查看完整资料"
		_apply_button_style(image_button)
		image_button.pressed.connect(_on_codex_image_pressed.bind(beast_id))
		row.add_child(image_button)

		var info_box := VBoxContainer.new()
		info_box.add_theme_constant_override("separation", 5)
		info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_box)

		var name_label := Label.new()
		name_label.text = "%s · %s" % [
				beast.get("name", beast_id),
				codex.get("title", beast.get("type", "异兽"))
		]
		_apply_label_style(name_label, 18, COLOR_CYAN)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_box.add_child(name_label)

		var status_label := Label.new()
		status_label.text = "等级 %d  |  类型 %s  |  威胁 %s" % [
				int(beast.get("level", 1)),
				beast.get("type", "未知"),
				codex.get("threat_level", _threat_from_beast_type(str(beast.get("type", ""))))
		]
		_apply_label_style(status_label, 13, COLOR_AMBER)
		status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_box.add_child(status_label)

		var role_label := Label.new()
		role_label.text = str(codex.get("battle_role", asset.get("role", "暂无定位记录")))
		_apply_label_style(role_label, 13)
		role_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_box.add_child(role_label)

		var hint := Label.new()
		hint.text = "点击左侧图像进入完整信息。"
		_apply_label_style(hint, 12, COLOR_MUTED)
		info_box.add_child(hint)

		var brief := Label.new()
		brief.text = "【栖息地】%s\n【掉落预览】%s" % [
				codex.get("habitat", "未知区域"),
				_format_codex_values(codex.get("drops", asset.get("material_drops", [])))
		]
		_apply_label_style(brief, 13)
		brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(brief)


func _show_beast_codex_full_info(beast_id: String) -> void:
		if not DataManager.beasts.has(beast_id):
			codex_view_mode = "beasts"
			_show_beast_codex_list()
			return

		var beast: Dictionary = DataManager.beasts[beast_id]
		var codex: Dictionary = _get_beast_codex_entry(beast_id)
		var asset: Dictionary = _get_beast_asset_entry(beast_id)

		var back_button := Button.new()
		back_button.text = "返回详情"
		back_button.custom_minimum_size = Vector2(0, 34)
		back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(back_button)
		back_button.pressed.connect(_on_codex_back_to_detail_pressed.bind(beast_id))
		codex_content_container.add_child(back_button)

		var title := Label.new()
		title.text = "%s · 完整信息" % beast.get("name", beast_id)
		_apply_label_style(title, 18, COLOR_CYAN)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		codex_content_container.add_child(title)

		var stats := Label.new()
		stats.text = "【战斗数值】\nHP %d  |  攻击 %d  |  防御 %d\n灵能 %d  |  抵抗 %d  |  速度 %d\n弱点：%s" % [
				int(beast.get("hp", 0)),
				int(beast.get("attack", 0)),
				int(beast.get("defense", 0)),
				int(beast.get("spirit", 0)),
				int(beast.get("resistance", 0)),
				int(beast.get("speed", 0)),
				_format_codex_values(beast.get("weakness", []))
		]
		_apply_label_style(stats, 13)
		stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(stats)

		var detail := Label.new()
		detail.text = "【定位】%s\n\n【习性】%s\n\n【技能】%s\n\n【应对】%s\n\n【材料】%s\n\n【物语】%s\n\n【标签】%s" % [
				codex.get("battle_role", asset.get("role", "暂无定位记录")),
				codex.get("behavior", "暂无习性记录"),
				_format_codex_values(codex.get("skills", beast.get("skills", []))),
				codex.get("counter", "暂无应对记录"),
				_format_codex_values(codex.get("drops", asset.get("material_drops", []))),
				asset.get("lore", "暂无物语记录"),
				_format_codex_values(codex.get("tags", []))
		]
		_apply_label_style(detail, 13)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		codex_content_container.add_child(detail)


func _on_codex_category_pressed(category_id: String) -> void:
		selected_codex_category = category_id
		selected_codex_beast_id = ""
		selected_codex_boss_id = ""
		codex_view_mode = category_id
		_refresh_codex()


func _on_codex_back_to_categories_pressed() -> void:
		codex_view_mode = "categories"
		selected_codex_category = ""
		selected_codex_beast_id = ""
		selected_codex_boss_id = ""
		_refresh_codex()


func _on_codex_beast_pressed(beast_id: String) -> void:
		selected_codex_beast_id = beast_id
		codex_view_mode = "detail"
		_refresh_codex()


func _on_codex_image_pressed(beast_id: String) -> void:
		selected_codex_beast_id = beast_id
		codex_view_mode = "info"
		_refresh_codex()


func _on_codex_back_to_list_pressed() -> void:
		codex_view_mode = "beasts"
		selected_codex_beast_id = ""
		_refresh_codex()


func _on_codex_back_to_detail_pressed(beast_id: String) -> void:
		selected_codex_beast_id = beast_id
		codex_view_mode = "detail"
		_refresh_codex()


func _get_beast_asset_entry(beast_id: String) -> Dictionary:
		var raw_assets: Variant = DataManager.beast_assets.get("beasts", {})
		if not raw_assets is Dictionary:
				return {}
		var assets: Dictionary = raw_assets
		if assets.has(beast_id) and assets[beast_id] is Dictionary:
				return assets[beast_id]
		return {}


func _get_beast_codex_entry(beast_id: String) -> Dictionary:
		var raw_entries: Variant = DataManager.beast_codex.get("entries", {})
		if not raw_entries is Dictionary:
				return {}
		var entries: Dictionary = raw_entries
		if entries.has(beast_id) and entries[beast_id] is Dictionary:
				return entries[beast_id]
		return {}


func _get_beast_display_texture(beast_id: String) -> Texture2D:
		var asset := _get_beast_asset_entry(beast_id)
		var portrait_path := str(asset.get("portrait", ""))
		var portrait := _load_texture_or_null(portrait_path)
		if portrait != null:
				return portrait
		return _get_beast_avatar_texture(beast_id)


func _get_beast_avatar_texture(beast_id: String) -> Texture2D:
		var asset := _get_beast_asset_entry(beast_id)
		var raw_rect_data: Variant = asset.get("avatar_rect", [])
		var raw_sheet_data: Variant = DataManager.beast_assets.get("avatar_sheet", {})
		if not raw_rect_data is Array or not raw_sheet_data is Dictionary:
				return null
		var rect_data: Array = raw_rect_data
		var sheet_data: Dictionary = raw_sheet_data
		var sheet_path := str(sheet_data.get("path", ""))
		if rect_data.size() < 4 or sheet_path == "":
				return null

		var sheet := _load_texture_or_null(sheet_path)
		if sheet == null:
				return null

		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(
				float(rect_data[0]),
				float(rect_data[1]),
				float(rect_data[2]),
				float(rect_data[3])
		)
		return atlas


func _load_texture_or_null(path: String) -> Texture2D:
		if path == "":
				return null
		var resource: Resource = load(path)
		if resource is Texture2D:
				return resource
		return null


func _format_codex_values(values: Variant) -> String:
		if values is Array:
				if values.is_empty():
						return "无"
				var parts: Array[String] = []
				for value in values:
						parts.append(str(value))
				return "、".join(parts)
		var text := str(values)
		return text if text != "" else "无"


func _threat_from_beast_type(beast_type: String) -> String:
		match beast_type:
				"BOSS":
						return "极高"
				"精英":
						return "高"
				"普通":
						return "低"
		return "未知"


func _clear_container(container: Node) -> void:
		for child in container.get_children():
				container.remove_child(child)
				child.queue_free()


func _refresh_codex_legacy_unused() -> void:
	var player := GameState.player
	var partner_count: int = player.survivors.size()
	var total_partners: int = DataManager.partners.size()
	var total_beasts: int = DataManager.beasts.size()
	var defeated_beasts: Array = player.story_flags.get("defeated_beasts", [])

	codex_label.text = "【伙伴图鉴】%d/%d\n\n【异兽图鉴】%d/%d\n\n【遗物图鉴】0/12" % [
		partner_count, total_partners,
		defeated_beasts.size(), total_beasts
	]


func _on_heal_all_pressed() -> void:
	var player := GameState.player
	var healed := false
	for survivor in player.survivors:
		if survivor.get("hp", 0) < survivor.get("max_hp", 0):
			survivor["hp"] = survivor.get("max_hp", 0)
			healed = true
	if healed:
		_set_home_status("全体伙伴已恢复至满血。")
	else:
		_set_home_status("所有伙伴状态良好，无需治疗。")
	_refresh_all()


func _on_rest_pressed() -> void:
	if GameState.player.supplies.get("food", 0) <= 0:
		_set_home_status("口粮不足，无法休息！请先获取口粮。")
		return
	GameState.explore()
	_set_home_status("休息结束，时间推进。")
	_refresh_all()


func _on_switch_formation_pressed() -> void:
	var player := GameState.player
	var formations := ["assault", "iron", "wind"]
	var current_index := formations.find(player.current_formation)
	if current_index < 0:
		current_index = 0
	var next_index := (current_index + 1) % formations.size()
	player.switch_formation(formations[next_index])
	_set_home_status("已切换为 %s（%s）" % [
		player.get_formation_name(),
		_format_formation_bonus(player.get_formation_bonus())
	])
	_refresh_formation()


func _format_formation_bonus(bonus: Dictionary) -> String:
	var parts: Array[String] = []
	for stat in bonus:
		var value: float = bonus[stat]
		var label: String = stat
		match stat:
			"attack":
				label = "攻击"
			"defense":
				label = "防御"
			"speed":
				label = "速度"
		parts.append("%s%+.0f%%" % [label, value * 100.0])
	return "、".join(parts)


func _on_settings_pressed() -> void:
	_set_home_status("设置功能开发中……")


# ============================================================
# 轮回结算弹窗
# ============================================================
func _build_reincarnation_popup() -> void:
	reincarnation_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	reincarnation_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.custom_minimum_size = Vector2(300, 0)
	margin.add_child(box)

	var title := Label.new()
	title.text = "🔄 主动轮回"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	reincarnation_confirm_label = Label.new()
	reincarnation_confirm_label.text = ""
	_apply_label_style(reincarnation_confirm_label, 14)
	reincarnation_confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(reincarnation_confirm_label)

	reincarnation_result_label = Label.new()
	reincarnation_result_label.text = ""
	_apply_label_style(reincarnation_result_label, 13, COLOR_MUTED)
	reincarnation_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reincarnation_result_label.visible = false
	box.add_child(reincarnation_result_label)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	box.add_child(button_row)

	reincarnation_cancel_button = Button.new()
	reincarnation_cancel_button.text = "取消"
	reincarnation_cancel_button.custom_minimum_size = Vector2(0, 38)
	reincarnation_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(reincarnation_cancel_button)
	reincarnation_cancel_button.pressed.connect(func() -> void: reincarnation_popup.hide())
	button_row.add_child(reincarnation_cancel_button)

	reincarnation_confirm_button = Button.new()
	reincarnation_confirm_button.text = "确认轮回"
	reincarnation_confirm_button.custom_minimum_size = Vector2(0, 38)
	reincarnation_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(reincarnation_confirm_button, "panel")
	reincarnation_confirm_button.pressed.connect(_do_reincarnation)
	button_row.add_child(reincarnation_confirm_button)

	reincarnation_close_button = Button.new()
	reincarnation_close_button.text = "完成"
	reincarnation_close_button.custom_minimum_size = Vector2(0, 38)
	reincarnation_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reincarnation_close_button.visible = false
	_apply_button_style(reincarnation_close_button, "panel")
	reincarnation_close_button.pressed.connect(func() -> void:
		reincarnation_popup.hide()
		_refresh_all()
	)
	button_row.add_child(reincarnation_close_button)

	add_child(reincarnation_popup)


# 打开主动轮回确认弹窗
func _on_reincarnation_pressed() -> void:
	var player := GameState.player
	var progress: Dictionary = player.get_reincarnation_progress()
	reincarnation_confirm_label.text = "本轮进度：主线 %d/%d 章，累计击杀 Boss %d 次。\n\n轮回后将结算评级并发放轮回印记、天赋点；\n当前等级、装备、资源与地图进度将被重置（软死亡），\n但图鉴、Boss情报、天赋、印记将永久保留。\n\n确定要主动轮回吗？" % [
		int(progress.get("max_chapter_reached", 1)),
		int(progress.get("total_chapters", 48)),
		_boss_kill_total()
	]
	reincarnation_result_label.visible = false
	reincarnation_result_label.text = ""
	reincarnation_cancel_button.visible = true
	reincarnation_confirm_button.visible = true
	reincarnation_close_button.visible = false
	reincarnation_popup.popup_centered()


# 获取累计击杀Boss数
func _boss_kill_total() -> int:
	var player := GameState.player
	var total := 0
	for boss_id in player.boss_kill_records:
		total += int(player.boss_kill_records[boss_id])
	return total


# 执行主动轮回结算
func _do_reincarnation() -> void:
	var player := GameState.player
	var result: Dictionary = player.perform_reincarnation()
	var rating: String = str(result.get("rating", "C"))
	var marks: int = int(result.get("marks", 0))
	var talent: int = int(result.get("talent_points", 0))
	var killed: int = int(result.get("killed_bosses", 0))
	var total_bosses: int = int(result.get("total_bosses", 0))
	var ratio: float = float(result.get("chapter_ratio", 0.0))
	reincarnation_result_label.visible = true
	reincarnation_result_label.text = "━━━━ 轮回结算 ━━━━\n评级：%s\n主线进度：%d%%（击杀 Boss %d/%d）\n获得轮回印记 ×%d\n获得天赋点 ×%d\n\n软死亡：等级/装备/资源/地图进度已重置\n保留：图鉴 / Boss情报 / 天赋 / 印记\n\n进入第 %d 轮。" % [
		rating,
		int(ratio * 100.0),
		killed,
		total_bosses,
		marks,
		talent,
		int(player.reincarnation)
	]
	reincarnation_confirm_label.text = ""
	reincarnation_cancel_button.visible = false
	reincarnation_confirm_button.visible = false
	reincarnation_close_button.visible = true


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	return sep
