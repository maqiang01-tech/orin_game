extends Control

# ============================================================
# 异变纪元：幸存者编队 - 主界面框架
# 包含：顶部状态栏 + 6个Tab页面 + 底部Tab导航
# ============================================================

const UI_FRAME_TEXTURE = preload("res://assets/images/ui/ui_frame_full.png")
const UI_PANEL_CARD_TEXTURE = preload("res://assets/images/ui/ui_panel_card.png")
const UI_ROUTE_CARD_TEXTURE = preload("res://assets/images/ui/ui_route_card.png")

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
var partner_detail_stats: Label
var partner_detail_skills: Label

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

# 背包界面引用
var inventory_label: Label

# 图鉴界面引用
var codex_label: Label

# 当前选中的伙伴
var selected_partner: Dictionary = {}


func _ready() -> void:
	GameState.ensure_initial_survivors()
	_build_background_frame()
	_build_status_bar()
	_build_content_area()
	_build_tab_navigation()
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
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 11)


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
	partner_detail_popup.size = Vector2(320, 480)
	partner_detail_popup.add_theme_stylebox_override("panel", _make_flat_style(Color(0.06, 0.08, 0.09, 0.96), COLOR_CYAN, 1, 5, 0))
	add_child(partner_detail_popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	partner_detail_popup.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	partner_detail_name = Label.new()
	_apply_label_style(partner_detail_name, 20, COLOR_CYAN)
	vbox.add_child(partner_detail_name)

	partner_detail_stats = Label.new()
	_apply_label_style(partner_detail_stats, 15)
	partner_detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_stats)

	partner_detail_skills = Label.new()
	_apply_label_style(partner_detail_skills, 15)
	partner_detail_skills.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(partner_detail_skills)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(0, 32)
	_apply_button_style(close_button)
	close_button.pressed.connect(func() -> void: partner_detail_popup.hide())
	vbox.add_child(close_button)


# ============================================================
# 探索界面
# ============================================================
func _build_explore_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "ExplorePage"
	page.add_theme_constant_override("separation", 6)

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
	map_margin.add_theme_constant_override("margin_left", 12)
	map_margin.add_theme_constant_override("margin_top", 12)
	map_margin.add_theme_constant_override("margin_right", 12)
	map_margin.add_theme_constant_override("margin_bottom", 12)
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

	var title := Label.new()
	title.text = "图鉴"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var codex_panel := _make_panel_container()
	codex_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(codex_panel)
	var codex_box := _make_panel_margin(codex_panel, 12)

	codex_label = Label.new()
	_apply_label_style(codex_label, 14)
	codex_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	codex_box.add_child(codex_label)

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

	# 主线进度
	var chapter_info := "第 %d 章" % player.chapter_id
	for chapter in DataManager.chapters:
		if chapter.get("id") == player.chapter_id:
			chapter_info = "第 %d 章 · %s" % [chapter["id"], chapter.get("title", "")]
			break
	home_chapter_label.text = chapter_info

	# 事件通知
	if DataManager.events.size() > 0:
		var first_event: Dictionary = DataManager.events[0]
		home_event_label.text = first_event.get("description", "暂无新事件。")
	else:
		home_event_label.text = "暂无新事件。"


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
		var button := Button.new()
		button.text = "%s  %s  Lv.%d  %s" % [
			survivor["name"],
			"★".repeat(survivor.get("star", 1)),
			survivor["level"],
			survivor.get("rarity", "")
		]
		button.custom_minimum_size = Vector2(0, 38)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(button)
		button.pressed.connect(_on_partner_clicked.bind(survivor))
		partner_list_container.add_child(button)


func _on_partner_clicked(partner: Dictionary) -> void:
	selected_partner = partner
	partner_detail_name.text = "%s · %s" % [partner["name"], partner.get("title", "")]
	var stats: Dictionary = partner.get("stats", {})
	partner_detail_stats.text = "HP %d/%d  |  能量 %d/%d\n攻击 %d  |  防御 %d\n灵能 %d  |  抵抗 %d\n速度 %d" % [
		partner.get("hp", 0), partner.get("max_hp", 0),
		partner.get("energy", 0), partner.get("max_energy", 0),
		stats.get("attack", 0), stats.get("defense", 0),
		stats.get("spirit", 0), stats.get("resistance", 0),
		stats.get("speed", 0)
	]

	# 技能列表（支持 initial_skills 和 skills 两种格式）
	var skill_text := "【技能】\n"
	var skills: Array = partner.get("skills", [])
	if skills.size() == 0 and partner.has("initial_skills"):
		skills = partner["initial_skills"]
	if skills.size() > 0:
		for skill_ref in skills:
			var skill_id: String = skill_ref.get("id", "") if skill_ref is Dictionary else str(skill_ref)
			if DataManager.skills.has(skill_id):
				var skill: Dictionary = DataManager.skills[skill_id]
				skill_text += "%s  Lv.%d\n" % [skill.get("name", skill_id), skill_ref.get("level", 1) if skill_ref is Dictionary else 1]
	else:
		skill_text += "暂无技能"
	partner_detail_skills.text = skill_text

	partner_detail_popup.popup_centered()


func _refresh_explore() -> void:
	if explore_view_mode == "site":
		_show_site_map()
		return
	_show_world_map()
	return

	var player := GameState.player
	explore_status_label.text = "消耗：半天（%s）" % player.get_time_label()

	# 清空路线
	for child in explore_route_container.get_children():
		explore_route_container.remove_child(child)
		child.queue_free()

	# 检查是否正在探索中
	if exploration_system.is_exploring():
		_show_explore_nodes()
		return

	# 从探索路线数据生成路线按钮
	var available_routes: Array = exploration_system.get_available_routes(player.day)

	# 最多显示3个
	var shown_routes: Array = available_routes.slice(0, 3)

	if shown_routes.size() == 0:
		var empty_label := Label.new()
		empty_label.text = "当前没有可探索的路线。"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		explore_route_container.add_child(empty_label)
		return

	for route in shown_routes:
		var route_button := Button.new()
		var route_id: String = route.get("id", "")
		var completed_count: int = player.get_route_completed_count(route_id)
		var recommended_level: String = route.get("recommended_level", "LV ?")
		var route_text := "%s  [%s]  (已完成%d次)" % [route.get("name", "未知路线"), recommended_level, completed_count]
		route_button.text = route_text
		route_button.custom_minimum_size = Vector2(0, 44)
		route_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(route_button, "route")
		route_button.pressed.connect(_on_route_clicked.bind(route))
		explore_route_container.add_child(route_button)


func _clear_explore_container() -> void:
	for child in explore_route_container.get_children():
		explore_route_container.remove_child(child)
		child.queue_free()


func _show_world_map() -> void:
	var player := GameState.player
	explore_status_label.text = "大地图 · %s · 口粮 %d" % [player.get_time_label(), player.supplies.get("food", 0)]
	_clear_explore_container()

	var map_title := Label.new()
	map_title.text = "【荒原大地图】"
	_apply_label_style(map_title, 16, COLOR_AMBER)
	explore_route_container.add_child(map_title)

	var hint := Label.new()
	hint.text = "选择一个地点进入小地图。资源点、秘境、事件建筑都会在小地图内探索。"
	_apply_label_style(hint, 12, COLOR_MUTED)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explore_route_container.add_child(hint)

	var map_card := TextureRect.new()
	map_card.texture = UI_PANEL_CARD_TEXTURE
	map_card.custom_minimum_size = Vector2(0, 96)
	map_card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_card.stretch_mode = TextureRect.STRETCH_SCALE
	map_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explore_route_container.add_child(map_card)

	for site in _get_world_sites():
		_add_world_site_button(site)


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

	current_world_site = site.duplicate(true)
	current_site_floor = 1
	current_site_total_floors = maxi(1, int(site.get("total_floors", 1)))
	explore_view_mode = "site"
	_generate_current_site_grid()
	_set_home_status("进入%s的小地图。" % current_world_site.get("name", "未知地点"))
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
	old_cell["content"] = "empty"
	current_site_position = target_pos
	_process_site_cell(target_cell)
	target_cell["content"] = "player"
	_refresh_explore()


func _process_site_cell(cell: Dictionary) -> void:
	match cell.get("content", "empty"):
		"loot":
			var item: String = cell.get("item", "food")
			var qty: int = int(cell.get("qty", 1))
			GameState.player.add_resource(item, qty)
			_set_home_status("拾取：%s×%d。" % [_format_resource_label(item), qty])
		"enemy":
			var enemy_id: String = cell.get("enemy_id", "")
			if enemy_id != "" and DataManager.beasts.has(enemy_id):
				_run_battle(enemy_id)
			else:
				_set_home_status("遭遇未知异兽，已将其驱散。")
		"special":
			_process_site_special(cell.get("special_type", "cache"))
		_:
			_set_home_status("继续探索。")


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
	_run_battle(battle_id)
	_apply_node_effects(node.get("effects", {}))
	exploration_system.advance_node()
	_refresh_explore()


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
				_run_battle(battle_id)
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
	_run_battle(battle_id)
	_apply_node_effects(node.get("effects", {}))
	_recruit_partner(node.get("join_partner", ""), "击败BOSS！%s 加入了队伍（替补席）。")
	exploration_system.advance_node()
	_refresh_explore()


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


func _run_battle(beast_id: String) -> void:
	if not DataManager.beasts.has(beast_id):
		return

	var beast: Dictionary = DataManager.beasts[beast_id].duplicate(true)
	var player_survivors: Array = GameState.player.survivors
	if player_survivors.size() == 0:
		return

	var survivor: Dictionary = {}
	for survivor_id in GameState.player.active_survivor_ids:
		for s in player_survivors:
			if s["id"] == survivor_id:
				survivor = s
				break
		if not survivor.is_empty():
			break

	if survivor.is_empty():
		survivor = player_survivors[0]

	var battle := BattleSystem.create_battle(survivor, beast)
	BattleSystem.player_basic_attack(battle)

	var damage: int = battle["log"][0]["value"]
	_set_home_status("战斗：%s 造成 %d 点伤害，%s 剩余 HP %d。" % [
		survivor["name"], damage, beast["name"], battle["enemy"]["hp"]
	])


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


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	return sep
