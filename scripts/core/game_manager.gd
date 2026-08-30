extends Control

# ============================================================
# 异变纪元：幸存者编队 - 主界面框架
# 包含：顶部状态栏 + 6个Tab页面 + 底部Tab导航
# ============================================================

const UI_FRAME_TEXTURE = preload("res://assets/images/ui/ui_frame_full.png")
const UI_PANEL_CARD_TEXTURE = preload("res://assets/images/ui/ui_panel_card.png")
const UI_ROUTE_CARD_TEXTURE = preload("res://assets/images/ui/ui_route_card.png")
const UI_EFFECT_BUTTON_DARK_TEXTURE = preload("res://assets/images/ui/extracted/buttons/action_search.png")
const UI_EFFECT_BUTTON_AMBER_TEXTURE = preload("res://assets/images/ui/extracted/buttons/primary_go.png")
const UI_EFFECT_NAV_TEXTURE = preload("res://assets/images/ui/extracted/buttons/nav_explore_normal.png")
const UI_EFFECT_NAV_SELECTED_TEXTURE = preload("res://assets/images/ui/extracted/buttons/nav_explore_selected.png")
const UI_HOME_BG_TEXTURE = preload("res://assets/images/ui/extracted/backgrounds/subway_station.png")
const UI_APP_BG_TEXTURE = preload("res://assets/images/ui/extracted/backgrounds/wide_ruined_city.png")
const UI_EFFECT_PANEL_TEXTURE = preload("res://assets/images/ui/extracted/panels/panel_dark_thin.png")
const UI_COMPONENT_PANEL_TEXTURE = preload("res://assets/images/ui/extracted/component_panel_dark_clean.png")
const UI_COMPONENT_BUTTON_DARK_TEXTURE = preload("res://assets/images/ui/extracted/component_button_dark_clean.png")
const UI_COMPONENT_BUTTON_AMBER_TEXTURE = preload("res://assets/images/ui/extracted/component_button_amber_clean.png")
const UI_COMPONENT_BUTTON_RED_TEXTURE = preload("res://assets/images/ui/extracted/component_button_red_clean.png")
const UI_LATEST_HOME_CARD_TEXTURE = preload("res://assets/images/ui/extracted/latest_bg_ruined_station.png")
const UI_LATEST_PRIMARY_BUTTON_TEXTURE = preload("res://assets/images/ui/extracted/latest_button_primary_amber.png")
const UI_LATEST_REINCARNATION_BUTTON_TEXTURE = preload("res://assets/images/ui/extracted/latest_button_reincarnation_red.png")
const UI_LATEST_MISSION_PANEL_TEXTURE = preload("res://assets/images/ui/extracted/latest_mission_panel.png")
const UI_HOME_SEARCH_TEXTURE = preload("res://assets/images/ui/extracted/buttons/action_search.png")
const UI_HOME_REST_TEXTURE = preload("res://assets/images/ui/extracted/buttons/action_rest.png")
const UI_HOME_LEAVE_TEXTURE = preload("res://assets/images/ui/extracted/buttons/action_leave.png")
const UI_PROD_BG_CITY = preload("res://assets/images/ui/production/04_backgrounds/bg_city_ruins.png")
const UI_PROD_BG_SUBWAY = preload("res://assets/images/ui/production/04_backgrounds/bg_subway_abandoned.png")
const UI_PROD_BG_BASE = preload("res://assets/images/ui/production/04_backgrounds/bg_base_shelter.png")
const UI_PROD_BG_REINCARNATION = preload("res://assets/images/ui/production/04_backgrounds/bg_reincarnation_hall.png")
const UI_PROD_PANEL_SCENE = preload("res://assets/images/ui/production/07_panels/panel_scene.png")
const UI_PROD_PANEL_MAIN_QUEST = preload("res://assets/images/ui/production/07_panels/panel_main_quest.png")
const UI_PROD_PANEL_LOCATION_INFO = preload("res://assets/images/ui/production/07_panels/panel_location_info.png")
const UI_PROD_PANEL_CHARACTER = preload("res://assets/images/ui/production/07_panels/panel_character.png")
const UI_PROD_PANEL_BASE_FACILITY = preload("res://assets/images/ui/production/07_panels/panel_base_facility.png")
const UI_PROD_PANEL_FORMATION = preload("res://assets/images/ui/production/07_panels/panel_formation.png")
const UI_PROD_PANEL_TEAM_RATING = preload("res://assets/images/ui/production/07_panels/panel_team_rating.png")
const UI_PROD_PANEL_BOSS = preload("res://assets/images/ui/production/07_panels/panel_boss.png")
const UI_PROD_FRAME_GRAY = preload("res://assets/images/ui/production/08_frames/frame_gray.png")
const UI_PROD_FRAME_SELECTED_GLOW = preload("res://assets/images/ui/production/08_frames/frame_selected_glow.png")
const UI_PROD_PROGRESS_TRACK = preload("res://assets/images/ui/production/09_progress_bars/progress_track_dark.png")
const UI_PROD_PROGRESS_GOLD = preload("res://assets/images/ui/production/09_progress_bars/progress_fill_gold.png")
const UI_PROD_PROGRESS_RED = preload("res://assets/images/ui/production/09_progress_bars/progress_fill_red.png")
const UI_PROD_PROGRESS_BLUE = preload("res://assets/images/ui/production/09_progress_bars/progress_fill_blue.png")
const UI_PROD_PROGRESS_GREEN = preload("res://assets/images/ui/production/09_progress_bars/progress_fill_green.png")
const UI_PROD_PROGRESS_PURPLE = preload("res://assets/images/ui/production/09_progress_bars/progress_fill_purple.png")
const UI_PROD_SLOT_EQUIPMENT = preload("res://assets/images/ui/production/10_slots/slot_equipment_normal.png")
const UI_PROD_ITEM_BANDAGE = preload("res://assets/images/ui/production/13_dedicated/items/item_bandage.png")
const UI_PROD_ITEM_BATTERY = preload("res://assets/images/ui/production/13_dedicated/items/item_battery.png")
const UI_PROD_ITEM_PARTS = preload("res://assets/images/ui/production/13_dedicated/items/item_mechanical_parts.png")
const UI_PROD_BOSS_WARDEN = preload("res://assets/images/ui/production/13_dedicated/boss/boss_warden_portrait.png")
const UI_PROD_CTA_PRIMARY_NORMAL = preload("res://assets/images/ui/production/01_buttons/cta/btn_primary_normal.png")
const UI_PROD_CTA_PRIMARY_HOVER = preload("res://assets/images/ui/production/01_buttons/cta/btn_primary_hover.png")
const UI_PROD_CTA_PRIMARY_PRESSED = preload("res://assets/images/ui/production/01_buttons/cta/btn_primary_pressed.png")
const UI_PROD_CTA_PRIMARY_DISABLED = preload("res://assets/images/ui/production/01_buttons/cta/btn_primary_disabled.png")
const UI_PROD_CTA_DANGER_NORMAL = preload("res://assets/images/ui/production/01_buttons/cta/btn_danger_normal.png")
const UI_PROD_CTA_DANGER_HOVER = preload("res://assets/images/ui/production/01_buttons/cta/btn_danger_hover.png")
const UI_PROD_CTA_DANGER_PRESSED = preload("res://assets/images/ui/production/01_buttons/cta/btn_danger_pressed.png")
const UI_PROD_CTA_DANGER_DISABLED = preload("res://assets/images/ui/production/01_buttons/cta/btn_danger_disabled.png")
const UI_PROD_CTA_SECONDARY_NORMAL = preload("res://assets/images/ui/production/01_buttons/cta/btn_secondary_normal.png")
const UI_PROD_CTA_SECONDARY_HOVER = preload("res://assets/images/ui/production/01_buttons/cta/btn_secondary_hover.png")
const UI_PROD_CTA_SECONDARY_PRESSED = preload("res://assets/images/ui/production/01_buttons/cta/btn_secondary_pressed.png")
const UI_PROD_CTA_SECONDARY_DISABLED = preload("res://assets/images/ui/production/01_buttons/cta/btn_secondary_disabled.png")
const UI_PROD_BTN_SEARCH_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_search_normal.png")
const UI_PROD_BTN_SEARCH_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_search_hover.png")
const UI_PROD_BTN_SEARCH_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_search_pressed.png")
const UI_PROD_BTN_REST_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_rest_normal.png")
const UI_PROD_BTN_REST_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_rest_hover.png")
const UI_PROD_BTN_REST_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_rest_pressed.png")
const UI_PROD_BTN_LEAVE_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_leave_normal.png")
const UI_PROD_BTN_LEAVE_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_leave_hover.png")
const UI_PROD_BTN_LEAVE_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_leave_pressed.png")
const UI_PROD_BTN_ADJUST_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_adjust_team_normal.png")
const UI_PROD_BTN_ADJUST_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_adjust_team_hover.png")
const UI_PROD_BTN_ADJUST_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_adjust_team_pressed.png")
const UI_PROD_BTN_EQUIP_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_equipment_normal.png")
const UI_PROD_BTN_EQUIP_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_equipment_hover.png")
const UI_PROD_BTN_EQUIP_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_equipment_pressed.png")
const UI_PROD_BTN_SKILL_NORMAL = preload("res://assets/images/ui/production/01_buttons/function/btn_skill_normal.png")
const UI_PROD_BTN_SKILL_HOVER = preload("res://assets/images/ui/production/01_buttons/function/btn_skill_hover.png")
const UI_PROD_BTN_SKILL_PRESSED = preload("res://assets/images/ui/production/01_buttons/function/btn_skill_pressed.png")
const UI_PROD_SYSTEM_NORMAL = preload("res://assets/images/ui/production/01_buttons/system/btn_system_normal.png")
const UI_PROD_SYSTEM_PRESSED = preload("res://assets/images/ui/production/01_buttons/system/btn_system_pressed.png")
const UI_PROD_SYSTEM_DISABLED = preload("res://assets/images/ui/production/01_buttons/system/btn_system_disabled.png")
const UI_PROD_ICON_SETTINGS = preload("res://assets/images/ui/production/03_icons/system/icon_settings.png")
const UI_PROD_ICON_QUESTION = preload("res://assets/images/ui/production/03_icons/system/icon_question.png")
const UI_PROD_ICON_NOTIFICATION = preload("res://assets/images/ui/production/03_icons/system/icon_notification.png")
const UI_PROD_ICON_CLOSE = preload("res://assets/images/ui/production/03_icons/system/icon_close.png")
const UI_PROD_PANEL_RESOURCE = preload("res://assets/images/ui/production/07_panels/panel_resource.png")
const UI_GLOBAL_BG_BLACK_IRON = preload("res://assets/images/ui/production/17_generated/bg_global_subway_black_iron.png")
const UI_BASE_COMPOSITE = preload("res://assets/images/ui/production/17_generated/bg_base_facilities_composite.png")
const UI_CHARACTER_STATUS_FRAME = preload("res://assets/images/ui/production/17_generated/frame_character_status_empty_v2.png")
const UI_HOME_SURVIVAL_MASTER = preload("res://assets/images/ui/production/17_generated/home_survival_master_complete.png")
const UI_SUPPLEMENT_BOTTOM_NAV_BLACK_IRON = preload("res://assets/images/ui/production/16_supplement/bottom_nav_black_iron.png")
const UI_SUPPLEMENT_STATUS_BAR_BLACK_IRON = preload("res://assets/images/ui/production/16_supplement/status_bar_black_iron.png")
const UI_PROD_WINDOW_MEDIUM = preload("res://assets/images/ui/production/05_windows/window_medium.png")
const UI_PROD_WINDOW_LARGE = preload("res://assets/images/ui/production/05_windows/window_large.png")
const UI_PROD_NODE_HOSPITAL = preload("res://assets/images/ui/production/02_map_nodes/node_hospital_normal.png")
const UI_PROD_NODE_HOSPITAL_SELECTED = preload("res://assets/images/ui/production/02_map_nodes/node_hospital_selected.png")
const UI_PROD_NODE_SUPERMARKET = preload("res://assets/images/ui/production/02_map_nodes/node_supermarket_normal.png")
const UI_PROD_NODE_SUPERMARKET_SELECTED = preload("res://assets/images/ui/production/02_map_nodes/node_supermarket_selected.png")
const UI_PROD_NODE_SUBWAY = preload("res://assets/images/ui/production/02_map_nodes/node_subway_normal.png")
const UI_PROD_NODE_SUBWAY_DANGER = preload("res://assets/images/ui/production/02_map_nodes/node_subway_danger.png")
const UI_PROD_NODE_SAFEHOUSE = preload("res://assets/images/ui/production/02_map_nodes/node_safehouse_normal.png")
const UI_PROD_NODE_SAFEHOUSE_SELECTED = preload("res://assets/images/ui/production/02_map_nodes/node_safehouse_selected.png")
const UI_PROD_NODE_UNKNOWN = preload("res://assets/images/ui/production/02_map_nodes/node_unknown_normal.png")
const UI_PROD_NODE_UNKNOWN_LOCKED = preload("res://assets/images/ui/production/02_map_nodes/node_unknown_locked.png")
const UI_PROD_SLOT_FORMATION_NORMAL = preload("res://assets/images/ui/production/10_slots/slot_formation_normal.png")
const UI_PROD_SLOT_FORMATION_OCCUPIED = preload("res://assets/images/ui/production/10_slots/slot_formation_occupied.png")
const UI_PROD_SLOT_FORMATION_SELECTED = preload("res://assets/images/ui/production/10_slots/slot_formation_selected.png")
const UI_PROD_SLOT_PARTNER_NORMAL = preload("res://assets/images/ui/production/10_slots/slot_partner_normal.png")
const UI_PROD_SLOT_PARTNER_SELECTED = preload("res://assets/images/ui/production/10_slots/slot_partner_selected.png")
const UI_PROD_NAV_NORMAL_TEXTURES = [
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_survival_normal.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_explore_normal.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_team_normal.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_base_normal.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_reincarnation_normal.png")
]
const UI_PROD_NAV_SELECTED_TEXTURES = [
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_survival_selected.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_explore_selected.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_team_selected.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_base_selected.png"),
	preload("res://assets/images/ui/production/11_bottom_navigation/nav_reincarnation_selected.png")
]
const UI_NAV_NORMAL_TEXTURES = [
	preload("res://assets/images/ui/extracted/buttons/nav_survival_normal.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_explore_normal.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_formation_normal.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_base_normal.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_reincarnation_normal.png")
]
const UI_NAV_SELECTED_TEXTURES = [
	preload("res://assets/images/ui/extracted/buttons/nav_survival_selected.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_explore_selected.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_formation_selected.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_base_selected.png"),
	preload("res://assets/images/ui/extracted/buttons/nav_reincarnation_selected.png")
]
const WORLD_MAP_TEXTURE = preload("res://assets/images/exploration/world_map_wide_city_realm_v5_clean.png")

const COLOR_TEXT = Color(0.88, 0.84, 0.76)
const COLOR_MUTED = Color(0.58, 0.54, 0.48)
const COLOR_CYAN = Color(0.82, 0.66, 0.43)
const COLOR_AMBER = Color(0.96, 0.65, 0.14)

# 永久天赋配置
const TALENT_CONFIG: Array = [
	{"id": "vitality", "name": "强健体魄", "direction": "生存", "desc": "初始HP上限 +5%/级", "max_level": 5, "cost": 1},
	{"id": "endurance", "name": "充沛体力", "direction": "生存", "desc": "体力上限 +10%/级", "max_level": 5, "cost": 1},
	{"id": "weapon_mastery", "name": "武器掌握", "direction": "战斗", "desc": "攻击 +5%/级", "max_level": 5, "cost": 1},
	{"id": "combat_instinct", "name": "战斗技巧", "direction": "战斗", "desc": "暴击率 +2%/级", "max_level": 5, "cost": 1},
	{"id": "past_memory", "name": "前世记忆", "direction": "命运", "desc": "解锁隐藏Boss情报", "max_level": 1, "cost": 2},
	{"id": "truth_insight", "name": "真相洞察", "direction": "命运", "desc": "真相进度获取 +10%/级", "max_level": 5, "cost": 1}
]

# UI 引用
var background_frame: TextureRect
var status_bar: Control
var content_container: Control
var bottom_tab_bar: Control
var tab_pages: Dictionary = {}  # tab_id -> Control
var tab_buttons: Dictionary = {}  # tab_id -> Button

# 当前Tab
var current_tab: String = "camp"

# 集结地界面引用
var home_day_label: Label
var home_team_label: Label
var home_event_label: Label
var home_chapter_label: Label
var home_status_panel: PanelContainer
var home_status_label: Label
var home_reincarnation_label: Label
var scene_title_label: Label
var scene_desc_label: Label
var scene_hot_container: VBoxContainer
var story_card_title_label: Label
var story_card_text_label: Label
var story_card_button_container: HBoxContainer

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
var partner_select_popup: PopupPanel
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
var world_map_scroll: ScrollContainer
var world_map_canvas: Control
var world_map_zoom_container: Control
var world_map_base_size := Vector2.ZERO
var world_map_zoom: float = 1.0
var world_map_touches: Dictionary = {}
var world_map_last_pinch_distance: float = 0.0
var world_map_dragging: bool = false
var world_map_drag_start := Vector2.ZERO
var world_map_scroll_start := Vector2.ZERO
var selected_world_site: Dictionary = {}
var world_map_detail_title: Label
var world_map_detail_info: Label
var world_map_go_button: Button
var world_map_fit_button: Button
var world_map_overview_mode: bool = true

# 背包界面引用
var inventory_label: Label
var inventory_content_container: VBoxContainer
var base_content_container: VBoxContainer
var base_detail_label: Label
var base_selected_facility: Dictionary = {}
var base_upgrade_button: Button
var base_facility_buttons: Dictionary = {}
var base_detail_panel: PanelContainer
var reincarnation_content_container: VBoxContainer
var codex_popup: PopupPanel
var talent_popup: PopupPanel
var talent_content_box: VBoxContainer
var boss_preview_popup: PopupPanel
var boss_preview_content_box: VBoxContainer
var story_content_container: VBoxContainer
var team_formation_view: Control
var team_partner_view: Control

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
var battle_scene_instance: Control
const BATTLE_SCENE_PATH := "res://scenes/battle/battle_scene.tscn"

# 轮回结算UI引用
var reincarnation_popup: PopupPanel
var reincarnation_confirm_label: Label
var reincarnation_result_label: Label
var reincarnation_rating_label: Label
var reincarnation_cancel_button: Button
var reincarnation_confirm_button: Button
var reincarnation_close_button: Button

# 剧情播放UI引用
var story_popup: PopupPanel
var story_title_label: Label
var story_speaker_label: Label
var story_text_label: Label
var story_action_box: HBoxContainer
var story_tutorial_label: Label
var story_home_button: Button

# 商城UI引用
var store_popup: PopupPanel
var store_content_box: VBoxContainer

# 抽奖结果UI引用
var gacha_result_popup: PopupPanel
var gacha_result_label: Label


class WorldMapConnections:
	extends Control

	var connection_points: Array = []
	var line_color := Color(0.95, 0.64, 0.22, 0.42)
	var label_color := Color(0.96, 0.86, 0.66, 0.9)

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
				draw_rect(Rect2(label_position - Vector2(3, label_size.y + 2), label_size + Vector2(6, 4)), Color(0.06, 0.04, 0.02, 0.86), true)
				draw_string(font, label_position, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, label_color)


class TeamRadarChart:
	extends Control

	var values := PackedFloat32Array([0.72, 0.86, 0.44, 0.38, 0.68, 0.76])
	var labels := PackedStringArray(["输出", "生存", "控制", "治疗", "AOE", "速度"])

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		var center := Vector2(size.x * 0.5, size.y * 0.5 + 4.0)
		var radius := minf(size.x, size.y) * 0.34
		var font := ThemeDB.fallback_font
		for ring in range(1, 5):
			var ring_points := PackedVector2Array()
			for i in range(7):
				var angle := -PI * 0.5 + TAU * float(i % 6) / 6.0
				ring_points.append(center + Vector2(cos(angle), sin(angle)) * radius * float(ring) / 4.0)
			draw_polyline(ring_points, Color(0.52, 0.48, 0.40, 0.45), 1.0, true)

		var value_points := PackedVector2Array()
		for i in range(6):
			var angle := -PI * 0.5 + TAU * float(i) / 6.0
			var direction := Vector2(cos(angle), sin(angle))
			var outer := center + direction * radius
			draw_line(center, outer, Color(0.48, 0.45, 0.38, 0.42), 1.0, true)
			value_points.append(center + direction * radius * clampf(values[i], 0.0, 1.0))

		if value_points.size() >= 3:
			draw_colored_polygon(value_points, Color(0.86, 0.49, 0.12, 0.30))
			var outline := value_points.duplicate()
			outline.append(value_points[0])
			draw_polyline(outline, Color(1.0, 0.66, 0.20, 0.92), 2.0, true)

		for i in range(6):
			var angle := -PI * 0.5 + TAU * float(i) / 6.0
			var direction := Vector2(cos(angle), sin(angle))
			var text_size := font.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
			var text_pos := center + direction * (radius + 22.0) - Vector2(text_size.x * 0.5, -text_size.y * 0.35)
			draw_string(font, text_pos, labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.88, 0.84, 0.76, 1.0))


func _ready() -> void:
	GameState.ensure_initial_survivors()
	_build_background_frame()
	_build_effect_status_bar()
	_build_content_area()
	_build_tab_navigation()
	_build_reincarnation_popup()
	_build_story_popup()
	_build_gacha_result_popup()
	_build_codex_popup()
	_build_store_popup()
	_build_talent_popup()
	_build_boss_preview_popup()
	exploration_system = ExplorationSystem.new()
	exploration_system.player = GameState.player
	exploration_system.data_manager = DataManager
	dungeon_manager = DungeonManager.new()
	_switch_tab("camp")
	_refresh_all()


func _build_background_frame() -> void:
	background_frame = TextureRect.new()
	background_frame.name = "BackgroundFrame"
	background_frame.texture = UI_GLOBAL_BG_BLACK_IRON
	background_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_frame.stretch_mode = TextureRect.STRETCH_SCALE
	background_frame.modulate = Color.WHITE
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
	margin_bottom: int = 4,
	texture_margin_left: int = 0,
	texture_margin_top: int = 0,
	texture_margin_right: int = 0,
	texture_margin_bottom: int = 0,
	draw_center: bool = true
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.draw_center = draw_center
	style.texture_margin_left = texture_margin_left
	style.texture_margin_top = texture_margin_top
	style.texture_margin_right = texture_margin_right
	style.texture_margin_bottom = texture_margin_bottom
	style.content_margin_left = margin_left
	style.content_margin_top = margin_top
	style.content_margin_right = margin_right
	style.content_margin_bottom = margin_bottom
	return style


func _make_effect_button_style(texture: Texture2D, content_margin: int = 8, texture_margin: int = 10) -> StyleBoxTexture:
	return _make_texture_style(texture, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, false)


func _make_component_style(texture: Texture2D, content_margin: int = 10, texture_margin: int = 18, draw_center: bool = true) -> StyleBoxTexture:
	return _make_texture_style(texture, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, draw_center)


func _make_ui_style(texture: Texture2D, margin: int = 16, slice: int = 28, draw_center: bool = true) -> StyleBoxTexture:
	return _make_texture_style(texture, margin, margin, margin, margin, slice, slice, slice, slice, draw_center)


func _place_control(control: Control, x: float, y: float, w: float, h: float) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = Vector2(x, y)
	control.size = Vector2(w, h)
	control.custom_minimum_size = Vector2(w, h)


func _add_page_background(page: Control, texture: Texture2D, tint: Color = Color(0.55, 0.52, 0.46, 0.34)) -> void:
	var bg := TextureRect.new()
	bg.texture = texture
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = tint
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(bg)


func _apply_panel_texture(panel: PanelContainer, texture: Texture2D = UI_PROD_PANEL_LOCATION_INFO, margin: int = 16) -> void:
	panel.add_theme_stylebox_override("panel", _make_ui_style(texture, margin, 28, true))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _apply_tinted_panel_texture(
	panel: PanelContainer,
	texture: Texture2D,
	tint: Color = Color(0.60, 0.56, 0.48, 1.0),
	margin: int = 16,
	slice: int = 28
) -> void:
	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = margin
	empty.content_margin_top = margin
	empty.content_margin_right = margin
	empty.content_margin_bottom = margin
	panel.add_theme_stylebox_override("panel", empty)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var frame := NinePatchRect.new()
	frame.name = "BlackIronFrame"
	frame.texture = texture
	frame.patch_margin_left = slice
	frame.patch_margin_top = slice
	frame.patch_margin_right = slice
	frame.patch_margin_bottom = slice
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.modulate = tint
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(frame)


func _apply_texture_button_skin(
	button: Button,
	normal_texture: Texture2D,
	hover_texture: Texture2D,
	pressed_texture: Texture2D,
	disabled_texture: Texture2D = null,
	content_margin: int = 12,
	texture_margin: int = 24
) -> void:
	var disabled := disabled_texture if disabled_texture != null else normal_texture
	button.add_theme_stylebox_override("normal", _make_texture_style(normal_texture, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, true))
	button.add_theme_stylebox_override("hover", _make_texture_style(hover_texture, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, true))
	button.add_theme_stylebox_override("pressed", _make_texture_style(pressed_texture, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, true))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", _make_texture_style(disabled, content_margin, content_margin, content_margin, content_margin, texture_margin, texture_margin, texture_margin, texture_margin, true))


func _apply_system_icon_button(button: Button, icon_texture: Texture2D) -> void:
	button.text = ""
	button.icon = null
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_ALL
	_apply_texture_button_skin(button, UI_PROD_SYSTEM_NORMAL, UI_PROD_SYSTEM_PRESSED, UI_PROD_SYSTEM_PRESSED, UI_PROD_SYSTEM_DISABLED, 0, 18)

	var icon := TextureRect.new()
	icon.name = "ButtonIcon"
	icon.texture = icon_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.anchor_left = 0.22
	icon.anchor_top = 0.22
	icon.anchor_right = 0.78
	icon.anchor_bottom = 0.78
	button.add_child(icon)


func _apply_slot_button_skin(button: Button, normal_texture: Texture2D, selected_texture: Texture2D = null) -> void:
	var selected := selected_texture if selected_texture != null else normal_texture
	_apply_texture_button_skin(button, normal_texture, selected, selected, selected, 6, 16)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.78, 0.30, 1.0))
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_focus_color", COLOR_AMBER)
	button.add_theme_color_override("font_outline_color", Color.BLACK)
	button.add_theme_constant_override("outline_size", 2)


func _make_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	_apply_label_style(label, 15, COLOR_AMBER)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.012, 0.006, 0.95))
	label.add_theme_constant_override("outline_size", 2)
	return label


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


func _apply_direct_texture_button_style(button: Button, normal_texture: Texture2D, pressed_texture: Texture2D, texture_margin: int = 18) -> void:
	var normal := _make_texture_style(normal_texture, 0, 0, 0, 0, texture_margin, texture_margin, texture_margin, texture_margin, true)
	var hover := _make_texture_style(pressed_texture, 0, 0, 0, 0, texture_margin, texture_margin, texture_margin, texture_margin, true)
	var pressed := _make_texture_style(pressed_texture, 0, 0, 0, 0, texture_margin, texture_margin, texture_margin, texture_margin, true)
	button.text = ""
	button.icon = null
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _apply_image_button(button: Button, normal_texture: Texture2D, pressed_texture: Texture2D = null) -> void:
	button.text = ""
	button.icon = null
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.set_meta("normal_texture", normal_texture)
	button.set_meta("pressed_texture", pressed_texture if pressed_texture != null else normal_texture)
	button.set_meta("image_button_hovered", false)
	button.mouse_entered.connect(_on_image_button_hover_changed.bind(button, true))
	button.mouse_exited.connect(_on_image_button_hover_changed.bind(button, false))
	button.focus_entered.connect(_on_image_button_focus_changed.bind(button, true))
	button.focus_exited.connect(_on_image_button_focus_changed.bind(button, false))

	var image := TextureRect.new()
	image.name = "ButtonImage"
	image.texture = normal_texture
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(image)


func _update_image_button_texture(button: Button, selected: bool) -> void:
	if not button.has_node("ButtonImage"):
		return
	var image := button.get_node("ButtonImage") as TextureRect
	if image == null:
		return
	var highlighted := selected or button.has_focus() or bool(button.get_meta("image_button_hovered", false))
	image.texture = button.get_meta("pressed_texture") if highlighted else button.get_meta("normal_texture")


func _on_image_button_hover_changed(button: Button, hovered: bool) -> void:
	button.set_meta("image_button_hovered", hovered)
	_update_image_button_texture(button, button.button_pressed)


func _on_image_button_focus_changed(button: Button, _focused: bool) -> void:
	_update_image_button_texture(button, button.button_pressed)


func _apply_route_card_texture_style(button: Button) -> void:
	var normal := _make_effect_button_style(UI_EFFECT_BUTTON_DARK_TEXTURE, 14, 10)
	var hover := _make_effect_button_style(UI_EFFECT_BUTTON_AMBER_TEXTURE, 14, 10)
	var pressed := _make_effect_button_style(UI_EFFECT_BUTTON_AMBER_TEXTURE, 14, 10)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", pressed)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.03, 0.9))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 13)


func _apply_map_region_style(button: Button) -> void:
	_apply_texture_button_skin(button, UI_PROD_CTA_SECONDARY_NORMAL, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 6, 34)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_font_size_override("font_size", 11)


func _apply_label_style(label: Label, font_size: int = 16, color: Color = COLOR_TEXT) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)


func _apply_button_style(button: Button, kind: String = "row") -> void:
	var font_size := 15
	match kind:
		"route":
			_apply_texture_button_skin(button, UI_PROD_CTA_SECONDARY_NORMAL, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 10, 34)
		"panel":
			_apply_texture_button_skin(button, UI_PROD_CTA_SECONDARY_NORMAL, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 10, 34)
		"primary":
			_apply_texture_button_skin(button, UI_PROD_CTA_PRIMARY_NORMAL, UI_PROD_CTA_PRIMARY_HOVER, UI_PROD_CTA_PRIMARY_PRESSED, UI_PROD_CTA_PRIMARY_DISABLED, 12, 34)
			font_size = 19
		"danger":
			# The generated hover/pressed bitmaps have different transparent padding.
			# Keep the normal frame for all active states so the button never appears to shrink.
			_apply_texture_button_skin(button, UI_PROD_CTA_DANGER_NORMAL, UI_PROD_CTA_DANGER_NORMAL, UI_PROD_CTA_DANGER_NORMAL, UI_PROD_CTA_DANGER_DISABLED, 12, 34)
			font_size = 18
		"tab":
			_apply_texture_button_skin(button, UI_PROD_CTA_SECONDARY_NORMAL, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 4, 34)
			button.add_theme_color_override("font_color", COLOR_MUTED)
			button.add_theme_color_override("font_hover_color", Color(1.0, 0.82, 0.36, 1.0))
			button.add_theme_color_override("font_pressed_color", Color(1.0, 0.78, 0.24, 1.0))
			button.add_theme_color_override("font_focus_color", COLOR_AMBER)
			button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
			button.add_theme_constant_override("outline_size", 2)
			button.add_theme_font_size_override("font_size", 13)
			return
		"search":
			_apply_texture_button_skin(button, UI_PROD_BTN_SEARCH_NORMAL, UI_PROD_BTN_SEARCH_HOVER, UI_PROD_BTN_SEARCH_PRESSED, null, 10, 24)
		"rest":
			_apply_texture_button_skin(button, UI_PROD_BTN_REST_NORMAL, UI_PROD_BTN_REST_HOVER, UI_PROD_BTN_REST_PRESSED, null, 10, 24)
		"leave":
			_apply_texture_button_skin(button, UI_PROD_BTN_LEAVE_NORMAL, UI_PROD_BTN_LEAVE_HOVER, UI_PROD_BTN_LEAVE_PRESSED, null, 10, 24)
		"adjust_team":
			_apply_texture_button_skin(button, UI_PROD_BTN_ADJUST_NORMAL, UI_PROD_BTN_ADJUST_HOVER, UI_PROD_BTN_ADJUST_PRESSED, null, 10, 24)
		"equipment":
			_apply_texture_button_skin(button, UI_PROD_BTN_EQUIP_NORMAL, UI_PROD_BTN_EQUIP_HOVER, UI_PROD_BTN_EQUIP_PRESSED, null, 10, 24)
		"skill":
			_apply_texture_button_skin(button, UI_PROD_BTN_SKILL_NORMAL, UI_PROD_BTN_SKILL_HOVER, UI_PROD_BTN_SKILL_PRESSED, null, 10, 24)
		_:
			_apply_texture_button_skin(button, UI_PROD_CTA_SECONDARY_NORMAL, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 8, 34)

	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_color_override("font_pressed_color", COLOR_AMBER)
	button.add_theme_color_override("font_focus_color", Color(1.0, 0.92, 0.72, 1.0))
	button.add_theme_font_size_override("font_size", font_size)


func _make_panel_container() -> PanelContainer:
	var panel := PanelContainer.new()
	_apply_panel_texture(panel)
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
func _build_effect_status_bar() -> void:
	status_bar = Control.new()
	status_bar.name = "StatusBar"
	_place_control(status_bar, 0, 0, 720, 154)
	add_child(status_bar)

	var resource_frame := TextureRect.new()
	resource_frame.name = "StatusResourceFrame"
	resource_frame.texture = UI_SUPPLEMENT_STATUS_BAR_BLACK_IRON
	resource_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	resource_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_place_control(resource_frame, 12, 54, 696, 74)
	resource_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_bar.add_child(resource_frame)

	var day_label := Label.new()
	day_label.name = "DayLabel"
	day_label.text = "第 1 轮 · 第 1 天 · 上午 · 阴"
	_apply_label_style(day_label, 18, Color(0.84, 0.72, 0.56, 1.0))
	_place_control(day_label, 24, 16, 380, 32)
	status_bar.add_child(day_label)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.visible = false
	status_bar.add_child(name_label)

	var weather_label := Label.new()
	weather_label.name = "WeatherLabel"
	weather_label.text = "☁ 黑雨"
	_apply_label_style(weather_label, 12, COLOR_TEXT)
	weather_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place_control(weather_label, 486, 22, 58, 24)
	status_bar.add_child(weather_label)

	var notification_button := Button.new()
	notification_button.name = "NotificationButton"
	_place_control(notification_button, 552, 14, 40, 40)
	_apply_system_icon_button(notification_button, UI_PROD_ICON_NOTIFICATION)
	notification_button.tooltip_text = "消息"
	notification_button.pressed.connect(func() -> void: _set_home_status("当前没有新的营地消息。"))
	status_bar.add_child(notification_button)

	var codex_button := Button.new()
	codex_button.name = "CodexButton"
	_place_control(codex_button, 604, 14, 40, 40)
	_apply_system_icon_button(codex_button, UI_PROD_ICON_QUESTION)
	codex_button.tooltip_text = "图鉴"
	codex_button.pressed.connect(_on_codex_button_pressed)
	status_bar.add_child(codex_button)

	var settings_button := Button.new()
	settings_button.name = "SettingsButton"
	_place_control(settings_button, 656, 14, 40, 40)
	_apply_system_icon_button(settings_button, UI_PROD_ICON_SETTINGS)
	settings_button.pressed.connect(_on_settings_pressed)
	status_bar.add_child(settings_button)

	var hp_label := _make_status_value_label("❤  HP\n100/100", Color(0.90, 0.30, 0.25, 1.0))
	hp_label.name = "HpLabel"
	_place_control(hp_label, 18, 66, 132, 50)
	status_bar.add_child(hp_label)

	var stamina_label := _make_status_value_label("⚡  体力\n100/100", COLOR_AMBER)
	stamina_label.name = "StaminaLabel"
	_place_control(stamina_label, 156, 66, 132, 50)
	status_bar.add_child(stamina_label)

	var hunger_label := _make_status_value_label("●  饥饿\n100/100", Color(0.78, 0.58, 0.32, 1.0))
	hunger_label.name = "HungerLabel"
	_place_control(hunger_label, 294, 66, 132, 50)
	status_bar.add_child(hunger_label)

	var mutation_label := _make_status_value_label("☣  感染\n0%", Color(0.86, 0.20, 0.18, 1.0))
	mutation_label.name = "MutationLabel"
	_place_control(mutation_label, 570, 66, 132, 50)
	status_bar.add_child(mutation_label)

	var thirst_label := _make_status_value_label("◆  水分\n100/100", Color(0.35, 0.68, 0.88, 1.0))
	thirst_label.name = "ThirstLabel"
	_place_control(thirst_label, 432, 66, 132, 50)
	status_bar.add_child(thirst_label)


func _make_status_value_label(text: String, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	_apply_label_style(label, 14, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.92))
	label.add_theme_constant_override("outline_size", 2)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _build_status_bar() -> void:
	status_bar = VBoxContainer.new()
	status_bar.add_theme_constant_override("separation", 3)
	status_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	status_bar.offset_top = 8
	status_bar.offset_bottom = 84
	status_bar.offset_left = 16
	status_bar.offset_right = -16
	add_child(status_bar)

	# 第一行：天数+时间 + 名称 + 天气 + 图鉴 + 设置
	var row1 := HBoxContainer.new()
	row1.name = "Row1"
	row1.add_theme_constant_override("separation", 10)
	status_bar.add_child(row1)

	var day_label := Label.new()
	day_label.name = "DayLabel"
	day_label.text = "DAY 1 · 上午"
	_apply_label_style(day_label, 17, COLOR_CYAN)
	row1.add_child(day_label)

	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = "陈末"
	_apply_label_style(name_label, 15)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row1.add_child(name_label)

	var weather_label := Label.new()
	weather_label.name = "WeatherLabel"
	weather_label.text = "☁ 黑雨"
	_apply_label_style(weather_label, 14, COLOR_MUTED)
	row1.add_child(weather_label)

	var codex_button := Button.new()
	codex_button.name = "CodexButton"
	codex_button.text = "📖"
	codex_button.custom_minimum_size = Vector2(32, 32)
	_apply_button_style(codex_button, "tab")
	codex_button.tooltip_text = "图鉴"
	codex_button.pressed.connect(_on_codex_button_pressed)
	row1.add_child(codex_button)

	var settings_button := Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = "⚙️"
	settings_button.custom_minimum_size = Vector2(32, 32)
	_apply_button_style(settings_button, "tab")
	settings_button.pressed.connect(_on_settings_pressed)
	row1.add_child(settings_button)

	# 第二行：HP + 饥饿 + 水分 + 体力 + 变异值
	var row2 := HBoxContainer.new()
	row2.name = "Row2"
	row2.add_theme_constant_override("separation", 14)
	status_bar.add_child(row2)

	var hp_label := Label.new()
	hp_label.name = "HpLabel"
	hp_label.text = "❤️ 100%"
	_apply_label_style(hp_label, 14, COLOR_TEXT)
	row2.add_child(hp_label)

	var hunger_label := Label.new()
	hunger_label.name = "HungerLabel"
	hunger_label.text = "🍖 100"
	_apply_label_style(hunger_label, 14, COLOR_AMBER)
	row2.add_child(hunger_label)

	var thirst_label := Label.new()
	thirst_label.name = "ThirstLabel"
	thirst_label.text = "💧 100"
	_apply_label_style(thirst_label, 14, COLOR_CYAN)
	row2.add_child(thirst_label)

	var stamina_label := Label.new()
	stamina_label.name = "StaminaLabel"
	stamina_label.text = "⚡ 100"
	_apply_label_style(stamina_label, 14, COLOR_AMBER)
	row2.add_child(stamina_label)

	var mutation_label := Label.new()
	mutation_label.name = "MutationLabel"
	mutation_label.text = "☣ 0%"
	_apply_label_style(mutation_label, 14, COLOR_MUTED)
	mutation_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mutation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row2.add_child(mutation_label)


# ============================================================
# 第2步：中间内容区（6个Tab页面）
# ============================================================
func _build_content_area() -> void:
	content_container = Control.new()
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(content_container)

	# 创建5个Tab页面
	tab_pages["camp"] = _build_effect_home_page()
	tab_pages["explore"] = _build_explore_page()
	tab_pages["team"] = _build_team_page()
	tab_pages["base"] = _build_base_page()
	tab_pages["reincarnation"] = _build_reincarnation_page()

	# 默认全部隐藏
	for page in tab_pages.values():
		page.visible = false
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content_container.add_child(page)


# ============================================================
# 第3步：集结地主界面
# ============================================================
func _build_home_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "HomePage"
	page.add_theme_constant_override("separation", 6)

	# 主场景区域（背景 + 交互热点）
	var scene_panel := _make_panel_container()
	scene_panel.custom_minimum_size = Vector2(0, 250)
	page.add_child(scene_panel)
	var scene_box := _make_panel_margin(scene_panel, 12)

	scene_title_label = Label.new()
	scene_title_label.text = "🏥 废弃医院"
	_apply_label_style(scene_title_label, 18, COLOR_CYAN)
	scene_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_box.add_child(scene_title_label)

	scene_desc_label = Label.new()
	scene_desc_label.text = "昏暗的走廊，消毒水味弥漫。"
	_apply_label_style(scene_desc_label, 13, COLOR_MUTED)
	scene_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scene_box.add_child(scene_desc_label)

	scene_hot_container = VBoxContainer.new()
	scene_hot_container.add_theme_constant_override("separation", 6)
	scene_box.add_child(scene_hot_container)

	# 剧情/事件卡片
	var story_card := _make_panel_container()
	story_card.custom_minimum_size = Vector2(0, 150)
	page.add_child(story_card)
	var story_box := _make_panel_margin(story_card, 12)

	story_card_title_label = Label.new()
	story_card_title_label.text = "主线 · 第1章"
	_apply_label_style(story_card_title_label, 16, COLOR_AMBER)
	story_box.add_child(story_card_title_label)

	story_card_text_label = Label.new()
	story_card_text_label.text = "从废墟中醒来……"
	_apply_label_style(story_card_text_label, 13)
	story_card_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_box.add_child(story_card_text_label)

	story_card_button_container = HBoxContainer.new()
	story_card_button_container.add_theme_constant_override("separation", 8)
	story_box.add_child(story_card_button_container)

	# 快速操作
	var quick_panel := _make_panel_container()
	page.add_child(quick_panel)
	var quick_box := _make_panel_margin(quick_panel, 12)

	var quick_row := HBoxContainer.new()
	quick_row.add_theme_constant_override("separation", 8)
	quick_box.add_child(quick_row)

	var heal_button := Button.new()
	heal_button.text = "治疗"
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

	var save_button := Button.new()
	save_button.text = "保存"
	save_button.custom_minimum_size = Vector2(0, 34)
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(save_button)
	save_button.pressed.connect(_on_save_pressed)
	quick_row.add_child(save_button)

	var store_button := Button.new()
	store_button.text = "商城"
	store_button.custom_minimum_size = Vector2(0, 34)
	store_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(store_button)
	store_button.pressed.connect(_on_store_pressed)
	quick_row.add_child(store_button)

	var quick_row2 := HBoxContainer.new()
	quick_row2.add_theme_constant_override("separation", 8)
	quick_box.add_child(quick_row2)

	var talent_button := Button.new()
	talent_button.text = "天赋"
	talent_button.custom_minimum_size = Vector2(0, 34)
	talent_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(talent_button)
	talent_button.pressed.connect(_on_talent_pressed)
	quick_row2.add_child(talent_button)

	var reincarnation_button := Button.new()
	reincarnation_button.text = "轮回"
	reincarnation_button.custom_minimum_size = Vector2(0, 34)
	reincarnation_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(reincarnation_button)
	reincarnation_button.pressed.connect(_on_reincarnation_pressed)
	quick_row2.add_child(reincarnation_button)

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
func _build_effect_home_page() -> Control:
	var page := Control.new()
	page.name = "HomePage"
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var master := TextureRect.new()
	master.name = "HomeMasterBackground"
	master.texture = UI_HOME_SURVIVAL_MASTER
	master.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	master.stretch_mode = TextureRect.STRETCH_SCALE
	master.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	master.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(master)

	# The master image owns the complete frame. Runtime values and actions stay as controls.
	var date_back := ColorRect.new()
	date_back.color = Color(0.015, 0.014, 0.012, 0.94)
	_place_control(date_back, 188, 20, 360, 40)
	date_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(date_back)
	var home_date := Label.new()
	home_date.name = "HomeDateValue"
	_apply_label_style(home_date, 18, Color(0.82, 0.74, 0.64, 1.0))
	home_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	home_date.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_place_control(home_date, 188, 20, 360, 40)
	home_date.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_child(home_date)

	var status_value_specs := [
		["HomeHpValue", 39, Color(0.91, 0.33, 0.28, 1.0)],
		["HomeStaminaValue", 181, COLOR_AMBER],
		["HomeHungerValue", 323, Color(0.78, 0.58, 0.32, 1.0)],
		["HomeThirstValue", 465, Color(0.35, 0.68, 0.88, 1.0)],
		["HomeMutationValue", 607, Color(0.86, 0.20, 0.18, 1.0)]
	]
	for spec in status_value_specs:
		var value_label := Label.new()
		value_label.name = str(spec[0])
		var value_color: Color = spec[2]
		_apply_label_style(value_label, 11, value_color)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.add_theme_color_override("font_outline_color", Color.BLACK)
		value_label.add_theme_constant_override("outline_size", 2)
		_place_control(value_label, float(spec[1]), 119, 108, 24)
		value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.add_child(value_label)

	var location_layer := Control.new()
	location_layer.name = "HomeLocationCard"
	location_layer.clip_contents = true
	_place_control(location_layer, 24, 160, 672, 604)
	page.add_child(location_layer)

	scene_title_label = Label.new()
	scene_title_label.text = "废弃地铁站"
	_apply_label_style(scene_title_label, 34, Color(0.96, 0.92, 0.84, 1.0))
	scene_title_label.add_theme_constant_override("outline_size", 3)
	scene_title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	_place_control(scene_title_label, 30, 34, 430, 54)
	location_layer.add_child(scene_title_label)

	scene_desc_label = Label.new()
	scene_desc_label.text = "黑暗中传来金属摩擦声。你握紧手中的武器，小心翼翼地向前移动。"
	_apply_label_style(scene_desc_label, 17, Color(0.88, 0.86, 0.78, 1.0))
	scene_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_control(scene_desc_label, 30, 104, 390, 180)
	location_layer.add_child(scene_desc_label)

	scene_hot_container = VBoxContainer.new()
	scene_hot_container.add_theme_constant_override("separation", 6)
	scene_hot_container.visible = false
	_place_control(scene_hot_container, 30, 292, 390, 120)
	location_layer.add_child(scene_hot_container)

	var continue_button := Button.new()
	continue_button.name = "ContinueExploreButton"
	continue_button.text = ""
	_place_control(continue_button, 174, 624, 372, 104)
	continue_button.focus_mode = Control.FOCUS_ALL
	_apply_transparent_hotspot_skin(continue_button)
	continue_button.pressed.connect(func() -> void: _switch_tab("explore"))
	page.add_child(continue_button)

	var mission_panel := Control.new()
	mission_panel.name = "MainMissionPanel"
	_place_control(mission_panel, 26, 778, 668, 190)
	page.add_child(mission_panel)

	var mission_layer := Control.new()
	mission_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mission_panel.add_child(mission_layer)

	story_card_title_label = Label.new()
	story_card_title_label.visible = false
	mission_layer.add_child(story_card_title_label)

	story_card_text_label = Label.new()
	story_card_text_label.text = "第 12 章：失联基地\n前往失联基地核心区，寻找信号源并确认幸存者下落。"
	_apply_label_style(story_card_text_label, 16, COLOR_TEXT)
	story_card_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_control(story_card_text_label, 118, 62, 510, 76)
	mission_layer.add_child(story_card_text_label)

	var progress := TextureProgressBar.new()
	_place_control(progress, 118, 144, 470, 12)
	progress.max_value = 1.0
	progress.value = 0.0
	progress.texture_under = UI_PROD_PROGRESS_TRACK
	progress.texture_progress = UI_PROD_PROGRESS_RED
	mission_layer.add_child(progress)

	var progress_text := Label.new()
	progress_text.text = "0/1"
	_apply_label_style(progress_text, 13, COLOR_AMBER)
	progress_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place_control(progress_text, 590, 134, 48, 24)
	mission_layer.add_child(progress_text)

	story_card_button_container = HBoxContainer.new()
	story_card_button_container.visible = false
	mission_layer.add_child(story_card_button_container)

	var search_button := Button.new()
	search_button.name = "HomeSearchButton"
	_place_control(search_button, 24, 990, 216, 144)
	_apply_transparent_hotspot_skin(search_button)
	search_button.pressed.connect(func() -> void: _switch_tab("explore"))
	page.add_child(search_button)

	var rest_button := Button.new()
	rest_button.name = "HomeRestButton"
	_place_control(rest_button, 252, 990, 216, 144)
	_apply_transparent_hotspot_skin(rest_button)
	rest_button.pressed.connect(_on_rest_pressed)
	page.add_child(rest_button)

	var leave_button := Button.new()
	leave_button.name = "HomeLeaveButton"
	_place_control(leave_button, 480, 990, 216, 144)
	_apply_transparent_hotspot_skin(leave_button)
	leave_button.pressed.connect(func() -> void: _set_home_status("当前区域暂未开放撤离结算。"))
	page.add_child(leave_button)

	home_status_panel = _make_panel_container()
	home_status_panel.visible = false
	_place_control(home_status_panel, 54, 722, 612, 50)
	page.add_child(home_status_panel)

	var status_box := _make_panel_margin(home_status_panel, 10)
	home_status_label = Label.new()
	home_status_label.text = ""
	_apply_label_style(home_status_label, 13, COLOR_TEXT)
	home_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_box.add_child(home_status_label)

	return page


func _make_home_action_button(text: String, style_kind: String = "panel") -> Button:
	var button := Button.new()
	button.text = ""
	button.focus_mode = Control.FOCUS_ALL
	button.clip_contents = true
	_apply_button_style(button, style_kind)
	var lines := text.split("\n")

	var title := Label.new()
	title.text = str(lines[0])
	_apply_label_style(title, 22, COLOR_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	_place_control(title, 86, 36, 112, 28)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)

	var subtitle := Label.new()
	subtitle.text = str(lines[1]) if lines.size() > 1 else ""
	_apply_label_style(subtitle, 16, COLOR_MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_constant_override("outline_size", 2)
	subtitle.add_theme_color_override("font_outline_color", Color.BLACK)
	_place_control(subtitle, 80, 66, 126, 24)
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(subtitle)
	return button


func _build_formation_page() -> Control:
	var page := Control.new()
	page.name = "FormationPage"

	formation_label = Label.new()
	formation_label.text = "编队 · 强攻阵"
	_apply_label_style(formation_label, 32, COLOR_TEXT)
	formation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(formation_label, 0, 20, 720, 52)
	page.add_child(formation_label)

	var power_row := Label.new()
	power_row.text = "队伍战力  %d" % (_get_team_level(GameState.player) * 1000)
	_apply_label_style(power_row, 29, COLOR_AMBER)
	power_row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(power_row, 0, 91, 720, 48)
	page.add_child(power_row)

	var card_row := HBoxContainer.new()
	card_row.add_theme_constant_override("separation", 0)
	_place_control(card_row, 12, 160, 696, 360)
	page.add_child(card_row)
	for survivor in _get_formation_showcase_survivors():
		card_row.add_child(_make_formation_character_card(survivor))

	var grid_panel := PanelContainer.new()
	_place_control(grid_panel, 24, 540, 362, 440)
	_apply_tinted_panel_texture(grid_panel, UI_PROD_PANEL_FORMATION, Color(0.56, 0.51, 0.42, 1.0), 14)
	page.add_child(grid_panel)
	var grid_box := _make_panel_margin(grid_panel, 10)

	var grid_title := Label.new()
	grid_title.text = "编队阵型（3×3）"
	_apply_label_style(grid_title, 15, COLOR_AMBER)
	grid_box.add_child(grid_title)

	# 九宫格编队网格
	formation_grid_container = GridContainer.new()
	formation_grid_container.columns = 3
	formation_grid_container.add_theme_constant_override("h_separation", 6)
	formation_grid_container.add_theme_constant_override("v_separation", 6)
	formation_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_box.add_child(formation_grid_container)

	# 创建9个格子按钮
	formation_grid_buttons = []
	for i in range(9):
		var grid_button := Button.new()
		grid_button.custom_minimum_size = Vector2(96, 92)
		grid_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_slot_button_skin(grid_button, UI_PROD_SLOT_FORMATION_NORMAL, UI_PROD_SLOT_FORMATION_SELECTED)
		grid_button.pressed.connect(_on_grid_cell_pressed.bind(i))
		formation_grid_container.add_child(grid_button)
		formation_grid_buttons.append(grid_button)

	var rating_panel := PanelContainer.new()
	_place_control(rating_panel, 398, 540, 298, 440)
	_apply_tinted_panel_texture(rating_panel, UI_PROD_PANEL_TEAM_RATING, Color(0.56, 0.51, 0.42, 1.0), 14)
	page.add_child(rating_panel)
	var rating_box := _make_panel_margin(rating_panel, 14)
	var rating_title := Label.new()
	rating_title.text = "队伍能力评估"
	_apply_label_style(rating_title, 16, COLOR_AMBER)
	rating_box.add_child(rating_title)
	var radar := TeamRadarChart.new()
	radar.name = "TeamRadar"
	radar.custom_minimum_size = Vector2(250, 322)
	radar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	radar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rating_box.add_child(radar)
	var rating_summary := Label.new()
	rating_summary.text = "综合评价  B  ·  生存能力突出"
	_apply_label_style(rating_summary, 13, COLOR_TEXT)
	rating_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating_box.add_child(rating_summary)

	formation_selection_label = Label.new()
	formation_selection_label.text = "点击「调整编队」选择伙伴，再点击阵位放置"
	_apply_label_style(formation_selection_label, 13, COLOR_MUTED)
	formation_selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(formation_selection_label, 24, 988, 672, 22)
	page.add_child(formation_selection_label)


	var adjust_button := Button.new()
	adjust_button.text = "调整编队"
	_place_control(adjust_button, 24, 1018, 208, 112)
	_apply_button_style(adjust_button, "adjust_team")
	adjust_button.pressed.connect(_on_adjust_team_pressed)
	page.add_child(adjust_button)

	var equip_button := Button.new()
	equip_button.text = "装备"
	_place_control(equip_button, 256, 1018, 208, 112)
	_apply_button_style(equip_button, "equipment")
	equip_button.pressed.connect(func() -> void: _set_home_status("装备页待接入角色装备快捷入口。"))
	page.add_child(equip_button)

	var skill_button := Button.new()
	skill_button.text = "技能"
	_place_control(skill_button, 488, 1018, 208, 112)
	_apply_button_style(skill_button, "skill")
	skill_button.pressed.connect(func() -> void: _set_home_status("技能页待接入角色技能强化入口。"))
	page.add_child(skill_button)

	return page


func _get_formation_showcase_survivors() -> Array:
	var result: Array = []
	var used_ids: Array[String] = []
	for survivor in GameState.player.survivors:
		result.append(survivor)
		used_ids.append(str(survivor.get("id", "")))
		if result.size() >= 5:
			return result
	for partner in DataManager.partners:
		var partner_id := str(partner.get("id", ""))
		if partner_id in used_ids:
			continue
		result.append(partner)
		used_ids.append(partner_id)
		if result.size() >= 5:
			break
	return result


func _make_formation_character_card(survivor: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(138, 360)
	card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var survivor_id := str(survivor.get("id", ""))
	var role_name := "输出"
	var role_color := Color(0.84, 0.35, 0.22, 1.0)
	var hp_texture: Texture2D = UI_PROD_PROGRESS_RED
	match survivor_id:
		"lin_mei":
			role_name = "治疗"
			role_color = Color(0.48, 0.67, 0.30, 1.0)
			hp_texture = UI_PROD_PROGRESS_GREEN
		"old_zhou", "lao_zhou":
			role_name = "坦克"
			role_color = Color(0.35, 0.61, 0.72, 1.0)
			hp_texture = UI_PROD_PROGRESS_BLUE
		"chen_feng":
			role_name = "控制"
			role_color = Color(0.58, 0.39, 0.69, 1.0)
			hp_texture = UI_PROD_PROGRESS_PURPLE
		"su_xiao":
			role_name = "输出"
			role_color = Color(0.82, 0.57, 0.24, 1.0)
			hp_texture = UI_PROD_PROGRESS_GOLD

	var frame := TextureRect.new()
	frame.texture = UI_CHARACTER_STATUS_FRAME
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(frame)

	var layer := Control.new()
	layer.clip_contents = true
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.add_child(layer)

	var name := Label.new()
	name.text = str(survivor.get("name", "伙伴"))
	_apply_label_style(name, 16, COLOR_TEXT)
	_place_control(name, 10, 10, 116, 24)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(name)

	var role := Label.new()
	role.text = role_name
	_apply_label_style(role, 12, role_color)
	_place_control(role, 10, 34, 70, 20)
	role.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(role)

	var character := TextureRect.new()
	character.texture = _get_production_character_texture(survivor_id)
	character.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_place_control(character, 8, 50, 122, 214)
	character.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(character)

	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.018, 0.018, 0.82)
	_place_control(shade, 7, 260, 124, 94)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(shade)

	var level := Label.new()
	level.text = "Lv.%d" % int(survivor.get("level", 1))
	_apply_label_style(level, 13, COLOR_TEXT)
	_place_control(level, 10, 266, 55, 20)
	level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(level)

	var hp := TextureProgressBar.new()
	hp.texture_under = UI_PROD_PROGRESS_TRACK
	hp.texture_progress = hp_texture
	hp.value = clampf(float(survivor.get("hp", 100.0)), 0.0, float(survivor.get("max_hp", 100.0)))
	hp.max_value = maxf(1.0, float(survivor.get("max_hp", 100.0)))
	_place_control(hp, 9, 288, 120, 12)
	hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hp)

	var hp_text := Label.new()
	hp_text.text = "%d/%d" % [int(survivor.get("hp", 100)), int(survivor.get("max_hp", 100))]
	_apply_label_style(hp_text, 10, COLOR_MUTED)
	hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(hp_text, 10, 299, 118, 16)
	hp_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hp_text)

	var item_textures: Array[Texture2D] = [UI_PROD_ITEM_PARTS, UI_PROD_ITEM_BATTERY, UI_PROD_ITEM_BANDAGE]
	for i in range(3):
		var slot := NinePatchRect.new()
		slot.texture = UI_PROD_SLOT_EQUIPMENT
		slot.patch_margin_left = 16
		slot.patch_margin_top = 16
		slot.patch_margin_right = 16
		slot.patch_margin_bottom = 16
		_place_control(slot, 9 + i * 41, 316, 38, 36)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(slot)
		var item := TextureRect.new()
		item.texture = item_textures[i]
		item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_place_control(item, 14 + i * 41, 320, 28, 28)
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(item)

	var click := Button.new()
	click.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	click.add_theme_stylebox_override("hover", _make_ui_style(UI_PROD_FRAME_SELECTED_GLOW, 0, 30, false))
	click.add_theme_stylebox_override("pressed", _make_ui_style(UI_PROD_FRAME_SELECTED_GLOW, 0, 30, false))
	click.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	click.pressed.connect(_on_partner_clicked.bind(survivor))
	card.add_child(click)

	return card


func _get_production_character_texture(survivor_id: String) -> Texture2D:
	var asset_id := survivor_id
	match survivor_id:
		"player_chenmo":
			asset_id = "chen_mo"
		"old_zhou":
			asset_id = "lao_zhou"
	var path := "res://assets/images/ui/production/12_characters/full/char_%s_full.png" % asset_id
	if ResourceLoader.exists(path):
		var source := load(path) as Texture2D
		var crop_regions := {
			"chen_mo": Rect2(120, 18, 540, 1116),
			"lin_mei": Rect2(150, 18, 468, 1116),
			"lao_zhou": Rect2(100, 18, 568, 1116),
			"chen_feng": Rect2(160, 18, 460, 1116),
			"su_xiao": Rect2(130, 18, 508, 1116)
		}
		if crop_regions.has(asset_id):
			var cropped := AtlasTexture.new()
			cropped.atlas = source
			cropped.region = crop_regions[asset_id]
			return cropped
		return source
	var portrait_path := "res://assets/images/ui/production/12_characters/portraits/portrait_%s.png" % asset_id
	if ResourceLoader.exists(portrait_path):
		return load(portrait_path) as Texture2D
	return UI_PROD_BG_SUBWAY


# ============================================================
# 伙伴界面
# ============================================================
func _build_partners_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "PartnersPage"
	page.add_theme_constant_override("separation", 10)

	var title := Label.new()
	title.text = "所有伙伴 · 状态与培养"
	_apply_label_style(title, 22, COLOR_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(0, 42)
	page.add_child(title)

	var hint := Label.new()
	hint.text = "点击伙伴查看属性、装备、技能与好感度"
	_apply_label_style(hint, 13, COLOR_MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(hint)

	# 滚动容器
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	partner_list_container = VBoxContainer.new()
	partner_list_container.add_theme_constant_override("separation", 8)
	partner_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(partner_list_container)

	# 伙伴详情弹窗
	_build_partner_detail_popup()

	return page


# 打开伙伴选择弹窗（调整编队）
func _on_adjust_team_pressed() -> void:
	if partner_select_popup == null:
		_build_partner_select_popup()
	_refresh_formation()
	partner_select_popup.popup_centered()


# ============================================================
# 伙伴选择弹窗（调整编队）
# ============================================================
func _build_partner_select_popup() -> void:
	partner_select_popup = PopupPanel.new()
	partner_select_popup.size = Vector2(640, 860)
	partner_select_popup.add_theme_stylebox_override("panel", _make_ui_style(UI_PROD_WINDOW_MEDIUM, 16, 28, true))
	add_child(partner_select_popup)

	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	partner_select_popup.add_child(layer)

	var title := Label.new()
	title.text = "调整编队 · 选择伙伴"
	_apply_label_style(title, 24, COLOR_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(title, 20, 18, 600, 40)
	layer.add_child(title)

	var hint := Label.new()
	hint.text = "点击伙伴选中，再点击阵位上阵；点击已有阵位可下阵"
	_apply_label_style(hint, 13, COLOR_MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(hint, 20, 60, 600, 24)
	layer.add_child(hint)

	formation_debug_label = Label.new()
	formation_debug_label.text = ""
	formation_debug_label.visible = false
	_apply_label_style(formation_debug_label, 12, COLOR_MUTED)
	formation_debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_control(formation_debug_label, 20, 86, 600, 18)
	layer.add_child(formation_debug_label)

	var scroll := ScrollContainer.new()
	_place_control(scroll, 20, 108, 600, 660)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layer.add_child(scroll)

	formation_survivor_container = VBoxContainer.new()
	formation_survivor_container.add_theme_constant_override("separation", 6)
	formation_survivor_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	formation_survivor_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(formation_survivor_container)

	var close_button := Button.new()
	close_button.text = "关闭"
	_place_control(close_button, 220, 780, 200, 56)
	_apply_button_style(close_button, "panel")
	close_button.pressed.connect(func() -> void: partner_select_popup.hide())
	layer.add_child(close_button)


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
	var page := Control.new()
	page.name = "ExplorePage"

	var title := Label.new()
	title.text = "废土城区地图"
	_apply_label_style(title, 32, Color(0.86, 0.66, 0.38, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(title, 185, 92, 350, 48)
	page.add_child(title)

	explore_status_label = Label.new()
	explore_status_label.text = "消耗：半天（上午）"
	_apply_label_style(explore_status_label, 14, COLOR_TEXT)
	explore_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(explore_status_label, 180, 132, 360, 26)
	page.add_child(explore_status_label)

	var route_title := Label.new()
	route_title.text = "区域探索"
	_apply_label_style(route_title, 18, COLOR_AMBER)
	_place_control(route_title, 36, 162, 200, 34)
	page.add_child(route_title)

	var map_panel := PanelContainer.new()
	_place_control(map_panel, 24, 190, 672, 890)
	_apply_panel_texture(map_panel, UI_PROD_PANEL_LOCATION_INFO, 0)
	page.add_child(map_panel)

	var map_margin := MarginContainer.new()
	map_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_margin.add_theme_constant_override("margin_left", 24)
	map_margin.add_theme_constant_override("margin_top", 24)
	map_margin.add_theme_constant_override("margin_right", 24)
	map_margin.add_theme_constant_override("margin_bottom", 24)
	map_panel.add_child(map_margin)

	explore_route_container = VBoxContainer.new()
	explore_route_container.add_theme_constant_override("separation", 8)
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
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "🎒 背包"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	inventory_content_container = VBoxContainer.new()
	inventory_content_container.add_theme_constant_override("separation", 8)
	inventory_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inventory_content_container)

	return page


func _build_base_page() -> Control:
	var page := Control.new()
	page.name = "BasePage"

	var scroll := ScrollContainer.new()
	scroll.name = "BaseCompositeScroll"
	_place_control(scroll, 12, 140, 696, 999)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	var composite_layer := Control.new()
	composite_layer.name = "BaseCompositeLayer"
	composite_layer.custom_minimum_size = Vector2(696, 1237)
	scroll.add_child(composite_layer)

	var composite := TextureRect.new()
	composite.texture = UI_BASE_COMPOSITE
	composite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	composite.stretch_mode = TextureRect.STRETCH_SCALE
	_place_control(composite, 0, 0, 696, 1237)
	composite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	composite_layer.add_child(composite)

	base_facility_buttons.clear()
	var facilities := _get_base_facility_definitions()
	var regions := [
		Rect2(20, 424, 318, 258), Rect2(354, 424, 320, 258),
		Rect2(20, 703, 318, 251), Rect2(354, 703, 320, 251),
		Rect2(20, 979, 318, 242), Rect2(354, 979, 320, 242)
	]
	for i in range(facilities.size()):
		var facility: Dictionary = facilities[i]
		var button := _make_transparent_facility_hotspot(facility, regions[i])
		composite_layer.add_child(button)
		base_facility_buttons[str(facility.get("id", ""))] = button

	base_detail_panel = PanelContainer.new()
	base_detail_panel.name = "BaseFacilityDetail"
	_place_control(base_detail_panel, 70, 790, 580, 246)
	_apply_panel_texture(base_detail_panel, UI_PROD_WINDOW_MEDIUM, 18)
	base_detail_panel.visible = false
	page.add_child(base_detail_panel)
	var detail_box := _make_panel_margin(base_detail_panel, 20)

	var detail_title := Label.new()
	detail_title.text = "设施详情"
	_apply_label_style(detail_title, 20, COLOR_AMBER)
	detail_box.add_child(detail_title)

	base_detail_label = Label.new()
	base_detail_label.name = "BodyLabel"
	_apply_label_style(base_detail_label, 14, COLOR_TEXT)
	base_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	base_detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_box.add_child(base_detail_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 12)
	detail_box.add_child(action_row)
	base_upgrade_button = Button.new()
	base_upgrade_button.text = "升级设施"
	base_upgrade_button.custom_minimum_size = Vector2(330, 58)
	base_upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(base_upgrade_button, "primary")
	base_upgrade_button.pressed.connect(_on_base_upgrade_pressed)
	action_row.add_child(base_upgrade_button)
	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(140, 58)
	_apply_button_style(close_button, "secondary")
	close_button.pressed.connect(func() -> void: base_detail_panel.visible = false)
	action_row.add_child(close_button)

	return page


func _apply_transparent_hotspot_skin(button: Button) -> void:
	button.text = ""
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var hover := _make_flat_style(Color(1.0, 0.52, 0.08, 0.08), Color(0.96, 0.58, 0.14, 0.82), 2, 2, 0)
	var pressed := _make_flat_style(Color(1.0, 0.44, 0.04, 0.15), Color(1.0, 0.66, 0.18, 1.0), 2, 2, 0)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())


func _build_reincarnation_page() -> Control:
	var page := Control.new()
	page.name = "ReincarnationPage"

	var title := Label.new()
	title.text = "轮回殿堂"
	_apply_label_style(title, 32, COLOR_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(title, 185, 155, 350, 56)
	page.add_child(title)

	var scroll := ScrollContainer.new()
	_place_control(scroll, 35, 230, 650, 838)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	reincarnation_content_container = VBoxContainer.new()
	reincarnation_content_container.add_theme_constant_override("separation", 8)
	reincarnation_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(reincarnation_content_container)

	var action_button := Button.new()
	action_button.name = "ReincarnateButton"
	action_button.text = "主动轮回"
	_place_control(action_button, 79, 1083, 562, 86)
	action_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(action_button, "danger")
	action_button.pressed.connect(_on_reincarnation_pressed)
	page.add_child(action_button)

	return page


# ============================================================
# 主线页面
# ============================================================
func _build_story_page() -> Control:
	var page := VBoxContainer.new()
	page.name = "StoryPage"
	page.add_theme_constant_override("separation", 6)
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var title := Label.new()
	title.text = "📜 主线"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	story_content_container = VBoxContainer.new()
	story_content_container.add_theme_constant_override("separation", 8)
	story_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(story_content_container)

	return page


func _refresh_story() -> void:
	var player := GameState.player
	if story_content_container == null:
		return
	_clear_container(story_content_container)

	var acts: Array = DataManager.main_story.get("acts", [])
	var chapters: Array = DataManager.main_story.get("chapters", [])
	for act in acts:
		var act_id := int(act.get("act_id", 0))
		var act_name := str(act.get("name", ""))
		var act_label := Label.new()
		act_label.text = "【第%d篇 · %s】" % [act_id, act_name]
		_apply_label_style(act_label, 16, COLOR_AMBER)
		story_content_container.add_child(act_label)
		for ch in chapters:
			if int(ch.get("act", 0)) != act_id:
				continue
			var ch_id := int(ch.get("id", 0))
			var ch_name := str(ch.get("name", ""))
			var ch_level := int(ch.get("level", 0))
			var is_boss := str(ch.get("boss_id", "")) != ""
			var is_current := ch_id == player.story_chapter
			var button := Button.new()
			var mark := "👹" if is_boss else "●"
			var current_mark := " ▶" if is_current else ""
			button.text = "%s 第%d章 %s（LV%d）%s" % [mark, ch_id, ch_name, ch_level, current_mark]
			button.custom_minimum_size = Vector2(0, 42)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_apply_button_style(button)
			button.pressed.connect(_on_story_chapter_pressed.bind(ch_id))
			story_content_container.add_child(button)


func _on_story_chapter_pressed(ch_id: int) -> void:
	var player := GameState.player
	# Boss 章节：弹出战前界面
	var boss_id := _get_chapter_boss_id(ch_id)
	if boss_id != "":
		_show_boss_preview(boss_id, ch_id)
		return
	if ch_id >= 1 and ch_id <= 8:
		player.story_chapter = ch_id
		player.story_step = 0
		_on_story_enter_pressed()
	else:
		_set_home_status("第%d章剧情内容待补充" % ch_id)


func _get_chapter_boss_id(ch_id: int) -> String:
	var chapters: Array = DataManager.main_story.get("chapters", [])
	for ch in chapters:
		if int(ch.get("id", 0)) == ch_id:
			return str(ch.get("boss_id", ""))
	return ""


# ============================================================
# 队伍页面（合并编队 + 伙伴）
# ============================================================
func _build_team_page() -> Control:
	var page := Control.new()
	page.name = "TeamPage"

	# 编队页直接铺满（对齐效果图），不再使用「编队/伙伴」子标签

	team_formation_view = _build_formation_page()
	team_formation_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_child(team_formation_view)

	# 由编队页触发的弹窗：伙伴详情 + 伙伴选择
	_build_partner_detail_popup()
	_build_partner_select_popup()

	return page


func _on_team_sub_tab_pressed(mode: String) -> void:
	if team_formation_view != null:
		team_formation_view.visible = (mode == "formation")
	if team_partner_view != null:
		team_partner_view.visible = (mode == "partners")


# ============================================================
# 第1步：底部Tab导航
# ============================================================
func _build_tab_navigation() -> void:
	var tab_bar := Control.new()
	bottom_tab_bar = tab_bar
	tab_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tab_bar.offset_top = -141
	tab_bar.offset_bottom = 0
	tab_bar.offset_left = 0
	tab_bar.offset_right = 0
	# Selected assets contain a soft outer glow. Keep it inside the 141 px nav safe area.
	tab_bar.clip_contents = true
	tab_bar.resized.connect(_layout_tab_navigation)
	add_child(tab_bar)

	var nav_bg := TextureRect.new()
	nav_bg.name = "BottomNavBackground"
	nav_bg.texture = UI_SUPPLEMENT_BOTTOM_NAV_BLACK_IRON
	nav_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nav_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	nav_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_bar.add_child(nav_bg)

	var tabs := [
		{"id": "camp", "label": "生存"},
		{"id": "explore", "label": "探索"},
		{"id": "team", "label": "编队"},
		{"id": "base", "label": "基地"},
		{"id": "reincarnation", "label": "轮回"}
	]

	for i in range(tabs.size()):
		var tab: Dictionary = tabs[i]
		var button := Button.new()
		button.tooltip_text = str(tab["label"])
		button.custom_minimum_size = Vector2(144, 96)
		button.toggle_mode = true
		button.set_meta("nav_index", i)
		_apply_image_button(button, UI_PROD_NAV_NORMAL_TEXTURES[i], UI_PROD_NAV_SELECTED_TEXTURES[i])
		button.pressed.connect(_on_tab_pressed.bind(tab["id"]))
		tab_bar.add_child(button)
		tab_buttons[tab["id"]] = button
	call_deferred("_layout_tab_navigation")


func _layout_tab_navigation() -> void:
	if bottom_tab_bar == null:
		return
	var available_w := bottom_tab_bar.size.x
	if available_w <= 0.0:
		available_w = get_viewport_rect().size.x
	var scale := available_w / 720.0
	var button_w := 144.0 * scale
	var button_h := 96.0 * scale
	var total_w := button_w * 5.0
	var start_x := roundf((available_w - total_w) * 0.5)
	var start_y := roundf((bottom_tab_bar.size.y - button_h) * 0.5)

	var nav_bg := bottom_tab_bar.get_node_or_null("BottomNavBackground") as TextureRect
	if nav_bg != null:
		var shell_h := minf(bottom_tab_bar.size.y, available_w * 349.0 / 2146.0)
		nav_bg.position = Vector2(0, roundf((bottom_tab_bar.size.y - shell_h) * 0.5))
		nav_bg.size = Vector2(available_w, shell_h)

	for id in tab_buttons:
		var button: Button = tab_buttons[id]
		var index := int(button.get_meta("nav_index", 0))
		button.position = Vector2(start_x + float(index) * button_w, start_y)
		button.size = Vector2(button_w, button_h)


# ============================================================
# Tab切换逻辑
# ============================================================
func _on_tab_pressed(tab_id: String) -> void:
	_switch_tab(tab_id)


func _switch_tab(tab_id: String) -> void:
	current_tab = tab_id
	# The formation page owns its full title/power header, matching the production mockup.
	# Hide the persistent survival status bar there so the two headers never overlap.
	if status_bar != null:
		status_bar.visible = tab_id != "team"

	# 更新按钮状态
	for id in tab_buttons:
		var selected: bool = (id == tab_id)
		tab_buttons[id].button_pressed = selected
		_update_image_button_texture(tab_buttons[id], selected)

	# 更新页面可见性
	for id in tab_pages:
		tab_pages[id].visible = (id == tab_id)

	# 切换时刷新对应页面
	match tab_id:
		"camp":
			_refresh_home()
		"explore":
			_refresh_explore()
		"team":
			_refresh_formation()
			_refresh_partners()
		"base":
			_refresh_base_page()
		"reincarnation":
			_refresh_reincarnation_page()


# ============================================================
# 刷新所有界面
# ============================================================
func _refresh_all() -> void:
	_refresh_effect_status_bar()
	_refresh_home()
	_refresh_formation()
	_refresh_partners()
	_refresh_explore()
	_refresh_story()
	_refresh_inventory()
	_refresh_base_page()
	_refresh_reincarnation_page()


func _refresh_effect_status_bar() -> void:
	var player := GameState.player
	if status_bar == null:
		return
	var day_label: Label = status_bar.find_child("DayLabel", true, false)
	var name_label: Label = status_bar.find_child("NameLabel", true, false)
	var weather_label: Label = status_bar.find_child("WeatherLabel", true, false)
	var hp_label: Label = status_bar.find_child("HpLabel", true, false)
	var hunger_label: Label = status_bar.find_child("HungerLabel", true, false)
	var thirst_label: Label = status_bar.find_child("ThirstLabel", true, false)
	var stamina_label: Label = status_bar.find_child("StaminaLabel", true, false)
	var mutation_label: Label = status_bar.find_child("MutationLabel", true, false)

	var weather_text := _get_effect_weather_label(player.day)
	if day_label != null:
		day_label.text = "第 %d 轮 · 第 %d 天 · %s · %s" % [int(player.reincarnation), player.day, player.get_time_label(), weather_text]
	if name_label != null:
		name_label.text = player.player_name
	if weather_label != null:
		weather_label.text = "☁"

	var hp_total := 0
	var hp_max_total := 0
	for survivor in player.survivors:
		hp_total += int(survivor.get("hp", 0))
		hp_max_total += int(survivor.get("max_hp", 1))
	if hp_label != null:
		hp_label.text = "❤ HP\n%d/%d" % [hp_total, hp_max_total]
	if stamina_label != null:
		stamina_label.text = "体力\n%d/100" % player.stamina
	if hunger_label != null:
		hunger_label.text = "饥饿\n%d/100" % player.hunger
	if thirst_label != null:
		thirst_label.text = "水分\n%d/100" % player.thirst
	if mutation_label != null:
		mutation_label.text = "感染\n%d%%" % player.mutation


func _get_effect_weather_label(day: int) -> String:
	var weathers := ["阴", "黑雨", "灰霾", "暴雨", "极夜"]
	return weathers[(day - 1) % weathers.size()]


func _refresh_status_bar() -> void:
	var player := GameState.player
	var day_label: Label = status_bar.find_child("DayLabel", true, false)
	var name_label: Label = status_bar.find_child("NameLabel", true, false)
	var weather_label: Label = status_bar.find_child("WeatherLabel", true, false)
	var hp_label: Label = status_bar.find_child("HpLabel", true, false)
	var hunger_label: Label = status_bar.find_child("HungerLabel", true, false)
	var thirst_label: Label = status_bar.find_child("ThirstLabel", true, false)
	var stamina_label: Label = status_bar.find_child("StaminaLabel", true, false)
	var mutation_label: Label = status_bar.find_child("MutationLabel", true, false)

	day_label.text = "第 %d 轮 · 第 %d 天 · %s · 阴" % [player.reincarnation, player.day, player.get_time_label()]
	name_label.text = player.player_name
	weather_label.text = _get_weather_label(player.day)

	var hp_total := 0
	var hp_max_total := 0
	for survivor in player.survivors:
		hp_total += int(survivor.get("hp", 0))
		hp_max_total += int(survivor.get("max_hp", 1))
	hp_label.text = "❤  HP\n%d/%d" % [hp_total, hp_max_total]
	hunger_label.text = "●  饥饿\n%d/100" % player.hunger
	thirst_label.text = "◆  水分\n%d/100" % player.thirst
	stamina_label.text = "⚡  体力\n%d/100" % player.stamina
	mutation_label.text = "☣  感染\n%d%%" % player.mutation


func _get_weather_label(day: int) -> String:
	var weathers := ["☁ 黑雨", "🌫 灰霾", "☀ 放晴", "🌧 暴雨", "🌑 极夜"]
	return weathers[(day - 1) % weathers.size()]


func _refresh_home() -> void:
	var player := GameState.player
	_refresh_home_master_status(player)
	_refresh_scene_area(player)
	_refresh_story_card(player)


func _refresh_home_master_status(player: PlayerData) -> void:
	var page := tab_pages.get("camp") as Control
	if page == null:
		return
	var date_label := page.find_child("HomeDateValue", true, false) as Label
	if date_label != null:
		date_label.text = "第 %d 轮 · 第 %d 天 · %s · 阴" % [player.reincarnation, player.day, player.get_time_label()]
	var hp_total := 0
	var hp_max_total := 0
	for survivor in player.survivors:
		hp_total += int(survivor.get("hp", 0))
		hp_max_total += int(survivor.get("max_hp", 1))
	var values := {
		"HomeHpValue": "%d/%d" % [hp_total, hp_max_total],
		"HomeStaminaValue": "%d/100" % player.stamina,
		"HomeHungerValue": "%d/100" % player.hunger,
		"HomeThirstValue": "%d/100" % player.thirst,
		"HomeMutationValue": "%d%%" % player.mutation
	}
	for label_name in values:
		var value_label := page.find_child(str(label_name), true, false) as Label
		if value_label != null:
			value_label.text = str(values[label_name])


func _refresh_scene_area(player: PlayerData) -> void:
	var chapter := player.get_current_story_chapter()
	if chapter.is_empty():
		scene_title_label.text = "安全屋"
		scene_desc_label.text = "临时的庇护所。"
		_clear_container(scene_hot_container)
		return
	var locations: Array = chapter.get("locations", [])
	var scene_name := str(chapter.get("name", "废弃地铁站"))
	if not locations.is_empty():
		scene_name = str((locations[0] as Dictionary).get("name", scene_name))
	scene_title_label.text = scene_name
	scene_desc_label.text = "黑暗中传来金属摩擦声。你握紧手中的武器，小心翼翼地向前移动。\n%s" % str(chapter.get("goal", "探索当前区域。"))
	_clear_container(scene_hot_container)
	for i in range(mini(3, locations.size())):
		var loc: Dictionary = locations[i]
		var hot_button := Button.new()
		hot_button.text = "🔍 %s" % str(loc.get("name", ""))
		hot_button.custom_minimum_size = Vector2(0, 32)
		hot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hot_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_apply_button_style(hot_button)
		hot_button.pressed.connect(_on_scene_hot_pressed.bind(loc))
		scene_hot_container.add_child(hot_button)


func _refresh_story_card(player: PlayerData) -> void:
	var chapter := player.get_current_story_chapter()
	# 轮回记忆事件优先显示
	var memory_event: Dictionary = player.try_trigger_reincarnation_event()
	if bool(memory_event.get("triggered", false)):
		story_card_title_label.text = "💭 轮回记忆"
		story_card_text_label.text = str(memory_event.get("text", ""))
		_clear_container(story_card_button_container)
		_add_story_card_button("▶ 继续", _on_story_enter_pressed)
		return
	if chapter.is_empty():
		story_card_title_label.text = "暂无主线任务"
		story_card_text_label.text = "前往「主线」页推进剧情。"
		_clear_container(story_card_button_container)
		return
	story_card_title_label.text = "主线 · 第%d章《%s》" % [player.story_chapter, str(chapter.get("name", ""))]
	var story: Array = chapter.get("story", [])
	var preview_text := ""
	for step in story:
		var t := str(step.get("text", ""))
		if t != "":
			preview_text = t
			break
	if preview_text == "":
		preview_text = str(chapter.get("goal", ""))
	story_card_text_label.text = preview_text
	_clear_container(story_card_button_container)
	_add_story_card_button("▶ 进入剧情", _on_story_enter_pressed)


func _add_story_card_button(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 36)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(button, "panel")
	button.pressed.connect(callback)
	story_card_button_container.add_child(button)


func _on_scene_hot_pressed(loc: Dictionary) -> void:
	var items: Array = loc.get("items", [])
	var result: String = str(loc.get("result", ""))
	if not items.is_empty():
		_set_home_status("获得：%s" % "、".join(items))
	elif result != "":
		_set_home_status(result)
	else:
		_set_home_status("探索：%s" % str(loc.get("name", "")))


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

	# 更新阵型标题（显示当前出战人数）
	if formation_label != null:
		formation_label.text = "编队 · %s（%d/5出战）" % [player.get_formation_name(), player.get_active_count()]

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
			_apply_slot_button_skin(grid_button, UI_PROD_SLOT_FORMATION_OCCUPIED, UI_PROD_SLOT_FORMATION_SELECTED)
		else:
			grid_button.text = "[空]\n%s" % player.get_grid_position_label(i)
			_apply_slot_button_skin(grid_button, UI_PROD_SLOT_FORMATION_NORMAL, UI_PROD_SLOT_FORMATION_SELECTED)

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
	button.text = "%s  Lv.%d  ·  %s  ·  %s" % [survivor["name"], int(survivor["level"]), survivor["profession"], status_text]
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 13)
	# 已选中的伙伴高亮显示
	if survivor_id == selected_formation_survivor_id:
		_apply_slot_button_skin(button, UI_PROD_SLOT_PARTNER_SELECTED, UI_PROD_SLOT_PARTNER_SELECTED)
		button.add_theme_color_override("font_color", COLOR_AMBER)
	else:
		_apply_slot_button_skin(button, UI_PROD_SLOT_PARTNER_NORMAL, UI_PROD_SLOT_PARTNER_SELECTED)
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
	# 5人出战上限：新增上阵（非移动）且已满员时拒绝
	if _find_survivor_grid_position(selected_formation_survivor_id) < 0 and player.is_formation_full():
		_set_home_status("出战人数已达上限（5人），请先下阵一名伙伴。")
		selected_formation_survivor_id = ""
		_refresh_formation()
		return
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
		formation_selection_label.text = "点击「调整编队」选择伙伴，再点击阵位放置"
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
	if partner_list_container == null:
		return
	for child in partner_list_container.get_children():
		partner_list_container.remove_child(child)
		child.queue_free()

	var player := GameState.player
	for survivor in player.survivors:
		player._ensure_partner_training_fields(survivor)
		var affinity_title: String = str(player.get_affinity_level_info(int(survivor.get("affinity", 0))).get("title", "初识"))
		var button := Button.new()
		button.text = ""
		button.custom_minimum_size = Vector2(0, 128)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.clip_contents = true
		_apply_texture_button_skin(button, UI_PROD_PANEL_LOCATION_INFO, UI_PROD_CTA_SECONDARY_HOVER, UI_PROD_CTA_SECONDARY_PRESSED, UI_PROD_CTA_SECONDARY_DISABLED, 0, 28)

		var portrait := TextureRect.new()
		portrait.texture = _get_production_character_texture(str(survivor.get("id", "")))
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_place_control(portrait, 20, 12, 92, 104)
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(portrait)

		var name_label := Label.new()
		name_label.text = "%s  %s" % [survivor.get("name", "伙伴"), "★".repeat(int(survivor.get("star", 1)))]
		_apply_label_style(name_label, 18, COLOR_TEXT)
		_place_control(name_label, 132, 20, 400, 28)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(name_label)

		var state_label := Label.new()
		var grid_index := _find_survivor_grid_position(str(survivor.get("id", "")))
		var formation_state := "已上阵 · %s" % player.get_grid_position_label(grid_index) if grid_index >= 0 else "未上阵"
		state_label.text = "Lv.%d  ·  %s  ·  %s  ·  %s" % [
			int(survivor.get("level", 1)),
			str(survivor.get("profession", "")),
			affinity_title,
			formation_state
		]
		_apply_label_style(state_label, 14, COLOR_AMBER if grid_index >= 0 else COLOR_MUTED)
		_place_control(state_label, 132, 54, 500, 26)
		state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(state_label)

		var stats_label := Label.new()
		stats_label.text = "HP %d/%d  ·  能量 %d/%d  ·  点击查看详情" % [
			int(survivor.get("hp", 0)), int(survivor.get("max_hp", 0)),
			int(survivor.get("energy", 0)), int(survivor.get("max_energy", 0))
		]
		_apply_label_style(stats_label, 12, COLOR_TEXT)
		_place_control(stats_label, 132, 86, 500, 24)
		stats_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(stats_label)
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
	var sites := _get_region_world_sites()
	if selected_world_site.is_empty() and not sites.is_empty():
		selected_world_site = sites[0].duplicate(true)

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
	world_map_fit_button = fit_mode_button
	world_map_overview_mode = true
	fit_mode_button.text = "放大探索"
	fit_mode_button.tooltip_text = "在完整全图与可拖拽细节视图之间切换"
	fit_mode_button.custom_minimum_size = Vector2(96, 34)
	_apply_button_style(fit_mode_button)
	fit_mode_button.pressed.connect(_on_world_map_immersive_pressed)
	map_header.add_child(fit_mode_button)

	var drag_hint := Label.new()
	drag_hint.text = "按住拖动 · 滚轮缩放"
	_apply_label_style(drag_hint, 11, COLOR_MUTED)
	drag_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	drag_hint.custom_minimum_size = Vector2(142, 34)
	map_header.add_child(drag_hint)

	_add_world_map_canvas()
	_add_world_map_detail_card()


func _add_world_map_detail_card() -> void:
	var sites := _get_region_world_sites()
	if sites.is_empty():
		return
	if selected_world_site.is_empty():
		selected_world_site = sites[0].duplicate(true)
	var panel := _make_panel_container()
	_apply_panel_texture(panel, UI_PROD_PANEL_LOCATION_INFO, 14)
	panel.custom_minimum_size = Vector2(0, 200)
	explore_route_container.add_child(panel)
	var box := _make_panel_margin(panel, 12)

	var title := Label.new()
	world_map_detail_title = title
	_apply_label_style(title, 18, COLOR_TEXT)
	box.add_child(title)

	var info := Label.new()
	world_map_detail_info = info
	_apply_label_style(info, 13, COLOR_MUTED)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(info)

	var go_button := Button.new()
	world_map_go_button = go_button
	go_button.text = "前往"
	go_button.custom_minimum_size = Vector2(0, 84)
	go_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(go_button, "primary")
	go_button.pressed.connect(_enter_selected_world_site)
	box.add_child(go_button)
	_update_world_map_detail()


func _select_world_site(site: Dictionary) -> void:
	selected_world_site = site.duplicate(true)
	_update_world_map_detail()
	if world_map_canvas == null:
		return
	for child in world_map_canvas.get_children():
		if child is Button and child.has_meta("world_site_id"):
			var site_button := child as Button
			site_button.button_pressed = str(site_button.get_meta("world_site_id")) == str(selected_world_site.get("id", ""))


func _update_world_map_detail() -> void:
	if selected_world_site.is_empty():
		return
	if world_map_detail_title != null:
		world_map_detail_title.text = str(selected_world_site.get("name", "未知地点"))
	if world_map_detail_info != null:
		world_map_detail_info.text = "危险等级：%d  |  距离：1.2 km  |  体力消耗：20\n%s" % [
			int(selected_world_site.get("danger", 1)),
			str(selected_world_site.get("desc", "探索当前区域。"))
		]
	if world_map_go_button != null:
		world_map_go_button.disabled = GameState.player.supplies.get("food", 0) <= 0


func _enter_selected_world_site() -> void:
	if selected_world_site.is_empty():
		return
	_on_world_site_pressed(selected_world_site)


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
	map_viewport.custom_minimum_size = Vector2(0, 620)
	map_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_viewport.clip_contents = true
	map_viewport.resized.connect(_fit_world_map)
	explore_route_container.add_child(map_viewport)

	var scroll := ScrollContainer.new()
	world_map_scroll = scroll
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 12
	scroll.gui_input.connect(_on_world_map_input)
	map_viewport.add_child(scroll)

	var zoom_container := Control.new()
	world_map_zoom_container = zoom_container
	zoom_container.custom_minimum_size = map_size
	zoom_container.size = map_size
	zoom_container.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.add_child(zoom_container)

	var canvas := Control.new()
	world_map_canvas = canvas
	canvas.custom_minimum_size = map_size
	canvas.size = map_size
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
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
	var full_map_zoom := minf(
		viewport_size.x / world_map_base_size.x,
		viewport_size.y / world_map_base_size.y
	)
	world_map_overview_mode = true
	_set_world_map_zoom(full_map_zoom)
	if world_map_fit_button != null:
		world_map_fit_button.text = "放大探索"
	if world_map_scroll != null:
		world_map_scroll.scroll_horizontal = 0
		world_map_scroll.scroll_vertical = 0


func _on_world_map_immersive_pressed() -> void:
	if world_map_overview_mode:
		var readable_zoom := maxf(world_map_viewport.size.y / world_map_base_size.y, 0.62)
		world_map_overview_mode = false
		_set_world_map_zoom(readable_zoom)
		if world_map_fit_button != null:
			world_map_fit_button.text = "完整全图"
		call_deferred("_center_world_map_on_selected")
	else:
		_fit_world_map()


func _on_world_map_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			world_map_overview_mode = false
			_set_world_map_zoom(world_map_zoom + 0.1)
		elif mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			world_map_overview_mode = false
			_set_world_map_zoom(world_map_zoom - 0.1)
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
			world_map_dragging = mouse_event.pressed
			if mouse_event.pressed and world_map_scroll != null:
				world_map_drag_start = mouse_event.position
				world_map_scroll_start = Vector2(world_map_scroll.scroll_horizontal, world_map_scroll.scroll_vertical)
		return

	if event is InputEventMouseMotion and world_map_dragging and world_map_scroll != null:
		var motion_event := event as InputEventMouseMotion
		var drag_delta := motion_event.position - world_map_drag_start
		world_map_scroll.scroll_horizontal = maxi(0, int(world_map_scroll_start.x - drag_delta.x))
		world_map_scroll.scroll_vertical = maxi(0, int(world_map_scroll_start.y - drag_delta.y))
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
		elif world_map_touches.size() == 1 and world_map_scroll != null:
			world_map_scroll.scroll_horizontal = maxi(0, world_map_scroll.scroll_horizontal - int(drag_event.relative.x))
			world_map_scroll.scroll_vertical = maxi(0, world_map_scroll.scroll_vertical - int(drag_event.relative.y))
		world_map_last_pinch_distance = pinch_distance


func _center_world_map_on_selected() -> void:
	if world_map_scroll == null or selected_world_site.is_empty() or world_map_base_size == Vector2.ZERO:
		return
	var map_data: Dictionary = DataManager.region_data.get("map", {})
	var coordinate_size: Dictionary = map_data.get("coordinate_size", {"x": 200, "y": 150})
	var position_data: Dictionary = selected_world_site.get("position", {})
	var normalized := Vector2(
		float(position_data.get("x", 0)) / maxf(1.0, float(coordinate_size.get("x", 200))),
		1.0 - float(position_data.get("y", 0)) / maxf(1.0, float(coordinate_size.get("y", 150)))
	)
	var scaled_size := world_map_base_size * world_map_zoom
	world_map_scroll.scroll_horizontal = maxi(0, int(normalized.x * scaled_size.x - world_map_scroll.size.x * 0.5))
	world_map_scroll.scroll_vertical = maxi(0, int(normalized.y * scaled_size.y - world_map_scroll.size.y * 0.5))


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
		minimum_zoom = maxf(0.18, minf(
			world_map_viewport.size.x / world_map_base_size.x,
			world_map_viewport.size.y / world_map_base_size.y
		))
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
	var button_width := clampf(map_size.x * 0.11, 74.0, 150.0)
	var button_height := 34.0 if map_size.x < 900.0 else 38.0
	var horizontal_padding := button_width * 0.5 + 18.0
	var vertical_padding := button_height * 0.5 + 18.0
	button.custom_minimum_size = Vector2(button_width, button_height)
	button.size = Vector2(button_width, button_height)
	button.position = Vector2(
		clampf(normalized_x * map_size.x - button_width * 0.5, horizontal_padding - button_width * 0.5, map_size.x - horizontal_padding - button_width * 0.5),
		clampf(normalized_y * map_size.y - button_height * 0.5, vertical_padding - button_height * 0.5, map_size.y - vertical_padding - button_height * 0.5)
	)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.toggle_mode = true
	button.set_meta("world_site_id", str(site.get("id", "")))
	button.button_pressed = str(site.get("id", "")) == str(selected_world_site.get("id", ""))
	_apply_map_region_style(button)
	button.add_theme_font_size_override("font_size", 9 if map_size.x < 900.0 else 11)
	button.pressed.connect(_select_world_site.bind(site))
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
	if not _open_battle_scene():
		battle_data = {}
		battle_site_context = {}
		return false
	return true


func _open_battle_scene() -> bool:
	if battle_scene_instance != null and is_instance_valid(battle_scene_instance):
		battle_scene_instance.queue_free()
		battle_scene_instance = null
	var packed: PackedScene = load(BATTLE_SCENE_PATH)
	if packed == null:
		_set_home_status("战斗场景加载失败。")
		return false
	battle_scene_instance = packed.instantiate()
	battle_scene_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if battle_scene_instance.has_signal("battle_finished"):
		battle_scene_instance.battle_finished.connect(_on_battle_scene_finished)
	if battle_scene_instance.has_method("setup_existing_battle"):
		battle_scene_instance.setup_existing_battle(battle_data)
	add_child(battle_scene_instance)
	battle_scene_instance.move_to_front()
	return true


func _on_battle_scene_finished(result: Dictionary) -> void:
	if result.has("battle") and result["battle"] is Dictionary:
		battle_data = result["battle"]
	var retreat := bool(result.get("retreat", false))
	if battle_scene_instance != null and is_instance_valid(battle_scene_instance):
		battle_scene_instance.queue_free()
	battle_scene_instance = null
	_finish_battle(true, retreat)


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
	if battle_action_bar == null:
		return
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
	var rewards: Dictionary = battle_data.get("rewards", {})
	var enemy_name := ""
	var enemy_base_id := ""
	if not battle_data.is_empty() and not battle_data["enemy_party"].is_empty():
		var first_enemy_id: String = str(battle_data["enemy_party"][0])
		if battle_data["units"].has(first_enemy_id):
			enemy_name = str(battle_data["units"][first_enemy_id].get("name", ""))
			enemy_base_id = str(battle_data["units"][first_enemy_id].get("base_id", first_enemy_id))

	if sync_hp and not battle_data.is_empty():
		_sync_battle_results()
	if sync_hp and victory and not rewards.is_empty():
		_apply_battle_rewards(rewards)

	if battle_popup != null:
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
			var reward_text := BattleSystem.format_rewards(rewards)
			if reward_text != "":
				_set_home_status("战斗胜利！%s 已被击败。\n获得：%s" % [enemy_name, reward_text])
			else:
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


func _apply_battle_rewards(rewards: Dictionary) -> void:
	var player := GameState.player
	if player == null:
		return
	var exp_total := int(rewards.get("exp", 0))
	if exp_total > 0 and not battle_data.is_empty():
		var party_ids: Array = battle_data.get("player_party", [])
		var exp_each := int(ceil(float(exp_total) / maxf(1.0, float(party_ids.size()))))
		for unit_id in party_ids:
			var unit: Dictionary = battle_data["units"].get(unit_id, {})
			var base_id := str(unit.get("base_id", ""))
			for survivor in player.survivors:
				if str(survivor.get("id", "")) == base_id:
					survivor["exp"] = int(survivor.get("exp", 0)) + exp_each
					break
	var gold := int(rewards.get("gold", 0))
	if gold > 0:
		_add_player_loot_resource("gold", gold)
	var resources: Dictionary = rewards.get("resources", {})
	for resource_id in resources:
		_add_player_loot_resource(str(resource_id), int(resources[resource_id]))
	for drop in rewards.get("drops", []):
		if drop is Dictionary:
			var item_id := str(drop.get("id", ""))
			var count := int(drop.get("count", 1))
			if item_id != "":
				player.story_flags["drop_" + item_id] = int(player.story_flags.get("drop_" + item_id, 0)) + count


func _add_player_loot_resource(resource_id: String, amount: int) -> void:
	if amount == 0 or GameState.player == null:
		return
	var player := GameState.player
	if resource_id in player.supplies or resource_id in player.materials:
		if not player.resource_caps.has(resource_id):
			player.resource_caps[resource_id] = 999999
		player.add_resource(resource_id, amount)
		return
	player.materials[resource_id] = int(player.materials.get(resource_id, 0)) + amount
	if not player.resource_caps.has(resource_id):
		player.resource_caps[resource_id] = 999999


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


func _add_info_card(container: VBoxContainer, title: String, body: String, accent: Color = COLOR_AMBER) -> PanelContainer:
	var panel := PanelContainer.new()
	_apply_tinted_panel_texture(panel, UI_PROD_PANEL_LOCATION_INFO, Color(0.62, 0.58, 0.50, 1.0), 12)
	panel.custom_minimum_size = Vector2(0, 82)
	container.add_child(panel)
	var box := _make_panel_margin(panel, 12)

	var title_label := Label.new()
	title_label.text = title
	_apply_label_style(title_label, 15, accent)
	box.add_child(title_label)

	var body_label := Label.new()
	body_label.name = "BodyLabel"
	body_label.text = body
	_apply_label_style(body_label, 13, COLOR_TEXT)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body_label)
	return panel


func _refresh_base_page() -> void:
	var player := GameState.player
	var facilities := _get_base_facility_definitions()
	if base_selected_facility.is_empty() and not facilities.is_empty():
		base_selected_facility = facilities[2].duplicate(true)
	for facility in facilities:
		var facility_id := str(facility.get("id", ""))
		var button := base_facility_buttons.get(facility_id) as Button
		if button == null:
			continue
		button.tooltip_text = "%s Lv.%d · 点击查看详情" % [str(facility.get("name", "设施")), player.get_base_facility_level(facility_id)]
		var selected := facility_id == str(base_selected_facility.get("id", "")) and base_detail_panel != null and base_detail_panel.visible
		button.set_pressed_no_signal(selected)
		var selection_frame := button.get_node_or_null("SelectionFrame") as NinePatchRect
		if selection_frame != null:
			selection_frame.visible = selected
	if not base_selected_facility.is_empty():
		base_selected_facility["level"] = player.get_base_facility_level(str(base_selected_facility.get("id", "")))
		_show_base_facility_detail(base_selected_facility)


func _get_base_facility_definitions() -> Array[Dictionary]:
	var player := GameState.player
	return [
		{"id": "workbench", "name": "工作台", "level": player.get_base_facility_level("workbench"), "desc": "制造工具、武器与装备，提升幸存者战斗力。"},
		{"id": "storage", "name": "仓库", "level": player.get_base_facility_level("storage"), "desc": "存储资源与物资，提升避难所储存上限。"},
		{"id": "bed", "name": "床铺", "level": player.get_base_facility_level("bed"), "desc": "提供休息场所，恢复幸存者体力与状态。"},
		{"id": "medical", "name": "医疗台", "level": player.get_base_facility_level("medical"), "desc": "治疗伤病，研究医疗技术并制作药品。"},
		{"id": "kitchen", "name": "厨房", "level": player.get_base_facility_level("kitchen"), "desc": "烹饪食物，提升食物效果与制作效率。"},
		{"id": "generator", "name": "发电机", "level": player.get_base_facility_level("generator"), "desc": "提供稳定电力，支撑避难所设施运转。"}
	]


func _make_transparent_facility_hotspot(facility: Dictionary, region: Rect2) -> Button:
	var button := Button.new()
	button.name = "Facility_%s" % str(facility.get("id", "unknown"))
	button.text = ""
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_ALL
	_place_control(button, region.position.x, region.position.y, region.size.x, region.size.y)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var selection_frame := NinePatchRect.new()
	selection_frame.name = "SelectionFrame"
	selection_frame.texture = UI_PROD_FRAME_SELECTED_GLOW
	selection_frame.patch_margin_left = 30
	selection_frame.patch_margin_top = 30
	selection_frame.patch_margin_right = 30
	selection_frame.patch_margin_bottom = 30
	selection_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_frame.draw_center = false
	selection_frame.modulate = Color(0.78, 0.48, 0.16, 0.64)
	selection_frame.visible = false
	selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(selection_frame)
	button.mouse_entered.connect(func() -> void: selection_frame.visible = true)
	button.mouse_exited.connect(func() -> void: selection_frame.visible = button.button_pressed)
	var facility_data := facility.duplicate(true)
	button.pressed.connect(_select_base_facility.bind(facility_data))
	return button


func _select_base_facility(facility: Dictionary) -> void:
	base_selected_facility = facility.duplicate(true)
	if base_detail_panel != null:
		base_detail_panel.visible = true
	for facility_id in base_facility_buttons:
		var button := base_facility_buttons[facility_id] as Button
		if button != null:
			button.set_pressed_no_signal(str(facility_id) == str(facility.get("id", "")))
			var selection_frame := button.get_node_or_null("SelectionFrame") as NinePatchRect
			if selection_frame != null:
				selection_frame.visible = button.button_pressed
	_show_base_facility_detail(base_selected_facility)


func _show_base_facility_detail(facility: Dictionary) -> void:
	if base_detail_label == null:
		return
	var facility_id := str(facility.get("id", ""))
	var level := GameState.player.get_base_facility_level(facility_id)
	var cost := GameState.player.get_base_facility_upgrade_cost(facility_id)
	base_detail_label.text = "%s Lv.%d\n%s\n维护状态：稳定  |  下级消耗：晶核 %d、电池 %d" % [
		str(facility.get("name", "设施")),
		level,
		str(facility.get("desc", "")),
		int(cost.get("cores", 0)),
		int(cost.get("spirit_battery", 0))
	]
	if base_upgrade_button != null:
		base_upgrade_button.disabled = level >= GameState.player.base_level
		base_upgrade_button.text = "已达上限" if base_upgrade_button.disabled else "升级设施"


func _on_base_upgrade_pressed() -> void:
	if base_selected_facility.is_empty():
		_set_home_status("请先选择一项设施。")
		return
	var result := GameState.player.upgrade_base_facility(str(base_selected_facility.get("id", "")))
	if bool(result.get("success", false)):
		_set_home_status("%s 已升级至 Lv.%d。" % [base_selected_facility.get("name", "设施"), int(result.get("level", 1))])
	else:
		_set_home_status(str(result.get("reason", "升级失败。")))
	_refresh_base_page()


func _make_facility_button(facility: Dictionary) -> Button:
	var button := Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(0, 244)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_ALL
	button.toggle_mode = true
	button.set_pressed_no_signal(str(facility.get("id", "")) == str(base_selected_facility.get("id", "")))
	_apply_texture_button_skin(button, UI_PROD_PANEL_BASE_FACILITY, UI_PROD_PANEL_BASE_FACILITY, UI_PROD_PANEL_BASE_FACILITY, UI_PROD_PANEL_BASE_FACILITY, 0, 28)

	var image := TextureRect.new()
	image.texture = load(str(facility.get("image", ""))) as Texture2D
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.modulate = Color(0.72, 0.67, 0.58, 0.88)
	_place_control(image, 14, 24, 142, 174)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(image)

	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.18)
	_place_control(shade, 14, 24, 142, 174)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(shade)

	var level_badge := Label.new()
	level_badge.text = "Lv.%d" % int(facility.get("level", 1))
	_apply_label_style(level_badge, 15, COLOR_AMBER)
	level_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_badge.add_theme_stylebox_override("normal", _make_ui_style(UI_PROD_SLOT_EQUIPMENT, 4, 16, true))
	_place_control(level_badge, 174, 30, 72, 36)
	level_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(level_badge)

	var title := Label.new()
	title.text = str(facility.get("name", ""))
	_apply_label_style(title, 20, COLOR_TEXT)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	_place_control(title, 174, 76, 130, 30)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(title)

	var desc := Label.new()
	desc.text = str(facility.get("desc", ""))
	_apply_label_style(desc, 13, COLOR_MUTED)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place_control(desc, 174, 112, 126, 62)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(desc)

	var arrow := Label.new()
	arrow.text = "›"
	_apply_label_style(arrow, 32, Color(0.70, 0.54, 0.34, 1.0))
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_place_control(arrow, 292, 148, 26, 42)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(arrow)

	var level := int(facility.get("level", 1))
	for i in range(5):
		var segment := ColorRect.new()
		segment.color = Color(0.74, 0.45, 0.14, 0.95) if i < level else Color(0.22, 0.22, 0.20, 0.72)
		_place_control(segment, 20 + i * 58, 216, 46, 5)
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(segment)

	var selection_frame := NinePatchRect.new()
	selection_frame.name = "SelectionFrame"
	selection_frame.texture = UI_PROD_FRAME_SELECTED_GLOW
	selection_frame.patch_margin_left = 30
	selection_frame.patch_margin_top = 30
	selection_frame.patch_margin_right = 30
	selection_frame.patch_margin_bottom = 30
	selection_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	selection_frame.draw_center = false
	selection_frame.modulate = Color(0.82, 0.52, 0.18, 0.72)
	selection_frame.visible = button.button_pressed
	selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(selection_frame)
	button.mouse_entered.connect(func() -> void: selection_frame.visible = true)
	button.mouse_exited.connect(func() -> void: selection_frame.visible = button.button_pressed)
	return button


func _refresh_reincarnation_page() -> void:
	if reincarnation_content_container == null:
		return
	var player := GameState.player
	_clear_container(reincarnation_content_container)

	var progress := int(clampf(maxf(player.truth_progress, float(player.highest_chapter_all_time) / 48.0), 0.0, 1.0) * 100.0)
	_add_info_card(reincarnation_content_container, "当前轮回", "%d 轮\n本轮存活：%d 天" % [
		int(player.reincarnation),
		int(player.day)
	], Color(0.86, 0.24, 0.20, 1.0))
	_add_info_card(reincarnation_content_container, "最高章节", "第 %d 章 · %s" % [
		int(player.highest_chapter_all_time),
		_get_chapter_display_name(int(player.highest_chapter_all_time))
	])
	_add_reincarnation_progress_card(progress)
	_add_info_card(reincarnation_content_container, "轮回印记", "%d\n可用于永久天赋和轮回强化。" % int(player.reincarnation_marks), Color(0.86, 0.24, 0.20, 1.0))
	_add_reincarnation_talent_card()
	_add_reincarnation_boss_card()
	_add_info_card(reincarnation_content_container, "本轮结算奖励", "轮回印记 +%d  |  天赋点 +%d" % [
		maxi(1, int(player.day / 3)),
		maxi(1, int(player.highest_chapter_all_time / 6))
	])


func _add_reincarnation_progress_card(progress: int) -> void:
	var panel := PanelContainer.new()
	_apply_tinted_panel_texture(panel, UI_PROD_PANEL_LOCATION_INFO, Color(0.62, 0.58, 0.50, 1.0), 12)
	panel.custom_minimum_size = Vector2(0, 116)
	reincarnation_content_container.add_child(panel)
	var box := _make_panel_margin(panel, 12)
	var title := Label.new()
	title.text = "真相进度  %d%%" % progress
	_apply_label_style(title, 15, COLOR_AMBER)
	box.add_child(title)
	var bar := TextureProgressBar.new()
	bar.texture_under = UI_PROD_PROGRESS_TRACK
	bar.texture_progress = UI_PROD_PROGRESS_GOLD
	bar.value = progress
	bar.max_value = 100
	bar.custom_minimum_size = Vector2(0, 24)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(bar)
	var hint := Label.new()
	hint.text = "推进主线、击败首领并触发轮回记忆可揭开真相。"
	_apply_label_style(hint, 12, COLOR_MUTED)
	box.add_child(hint)


func _add_reincarnation_talent_card() -> void:
	var panel := PanelContainer.new()
	_apply_tinted_panel_texture(panel, UI_PROD_PANEL_LOCATION_INFO, Color(0.62, 0.58, 0.50, 1.0), 12)
	panel.custom_minimum_size = Vector2(0, 150)
	reincarnation_content_container.add_child(panel)
	var box := _make_panel_margin(panel, 12)
	var title := Label.new()
	title.text = "永久天赋  ·  可用点数 %d" % GameState.player.talent_points
	_apply_label_style(title, 15, COLOR_AMBER)
	box.add_child(title)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	for i in range(5):
		var talent_button := Button.new()
		talent_button.text = ""
		talent_button.custom_minimum_size = Vector2(82, 82)
		_apply_slot_button_skin(talent_button, UI_PROD_SLOT_FORMATION_NORMAL, UI_PROD_SLOT_FORMATION_SELECTED)
		var icon := TextureRect.new()
		icon.texture = load("res://assets/images/ui/production/13_dedicated/talents/talent_%02d.png" % (i + 1)) as Texture2D
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		talent_button.add_child(icon)
		talent_button.tooltip_text = "打开永久天赋"
		talent_button.pressed.connect(_on_talent_pressed)
		row.add_child(talent_button)


func _add_reincarnation_boss_card() -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 154)
	_apply_panel_texture(panel, UI_PROD_PANEL_BOSS, 12)
	reincarnation_content_container.add_child(panel)
	var layer := Control.new()
	layer.custom_minimum_size = Vector2(0, 130)
	panel.add_child(layer)
	var portrait := TextureRect.new()
	portrait.texture = UI_PROD_BOSS_WARDEN
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_place_control(portrait, 18, 14, 190, 108)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(portrait)
	var title := Label.new()
	title.text = "BOSS 情报"
	_apply_label_style(title, 17, Color(0.90, 0.25, 0.20, 1.0))
	_place_control(title, 226, 18, 230, 28)
	layer.add_child(title)
	var info := Label.new()
	info.text = "已发现情报：%d\n腐化看守 · 情报尚未完整" % _get_boss_intel_count(GameState.player)
	_apply_label_style(info, 13, COLOR_TEXT)
	_place_control(info, 226, 50, 250, 54)
	layer.add_child(info)
	var button := Button.new()
	button.text = "查看图鉴"
	_place_control(button, 500, 38, 132, 58)
	_apply_button_style(button, "panel")
	button.pressed.connect(_on_codex_button_pressed)
	layer.add_child(button)


func _refresh_inventory() -> void:
	var player := GameState.player
	if inventory_content_container == null:
		return
	_clear_container(inventory_content_container)

	# 消耗品
	var consumable_title := Label.new()
	consumable_title.text = "【消耗品】"
	_apply_label_style(consumable_title, 16, COLOR_AMBER)
	inventory_content_container.add_child(consumable_title)
	_add_inventory_item("口粮", "food", int(player.supplies.get("food", 0)), int(player.resource_caps.get("food", 99)), false)
	_add_inventory_item("药品", "medicine", int(player.supplies.get("medicine", 0)), int(player.resource_caps.get("medicine", 99)), true)

	# 材料
	var material_title := Label.new()
	material_title.text = "【材料】"
	_apply_label_style(material_title, 16, COLOR_AMBER)
	inventory_content_container.add_child(material_title)
	var material_names := {"cores": "晶核", "memory_shards": "记忆碎片", "tickets": "补给券", "spirit_battery": "灵能电池", "ammo": "弹药", "rare_material": "稀有材料", "spirit_core": "灵核"}
	for mat_id in material_names:
		_add_inventory_item(str(material_names[mat_id]), mat_id, int(player.materials.get(mat_id, 0)), int(player.resource_caps.get(mat_id, 999)), false)

	# 装备
	var equip_title := Label.new()
	equip_title.text = "【装备】（%d 件）" % player.owned_equipment.size()
	_apply_label_style(equip_title, 16, COLOR_AMBER)
	inventory_content_container.add_child(equip_title)
	if player.owned_equipment.is_empty():
		var empty_label := Label.new()
		empty_label.text = "暂无装备。探索或锻造可获得。"
		_apply_label_style(empty_label, 13, COLOR_MUTED)
		inventory_content_container.add_child(empty_label)
	else:
		for equip_id in player.owned_equipment:
			var item := DataManager.get_equipment_by_id(str(equip_id))
			var item_label := Label.new()
			var slot_name: String = {"weapon": "武器", "armor": "防具", "accessory": "饰品"}.get(str(item.get("slot", "")), str(item.get("slot", "")))
			item_label.text = "%s · %s（稀有度 %d）" % [str(item.get("name", equip_id)), slot_name, int(item.get("rarity", 1))]
			_apply_label_style(item_label, 13)
			inventory_content_container.add_child(item_label)


# 添加背包物品条目
func _add_inventory_item(display_name: String, item_id: String, count: int, cap: int, usable: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "%s ×%d/%d" % [display_name, count, cap]
	_apply_label_style(label, 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	if usable:
		var use_button := Button.new()
		use_button.text = "使用"
		use_button.custom_minimum_size = Vector2(60, 30)
		_apply_button_style(use_button)
		use_button.pressed.connect(_on_inventory_use_pressed.bind(item_id))
		row.add_child(use_button)

	inventory_content_container.add_child(row)


# 使用背包物品
func _on_inventory_use_pressed(item_id: String) -> void:
	var result: Dictionary = GameState.player.use_consumable(item_id)
	_set_home_status(str(result.get("text", "")))
	_refresh_all()


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


func _on_save_pressed() -> void:
	SaveManager.save_all(GameState.player)
	_set_home_status("游戏已保存（当前轮 + 永久进度）。")
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
			"spirit":
				label = "灵能"
			"defense":
				label = "防御"
			"resistance":
				label = "灵抗"
			"speed":
				label = "速度"
			"ep_start":
				label = "首回合EP"
		parts.append("%s%+.0f%%" % [label, value * 100.0])
	return "、".join(parts)


func _on_settings_pressed() -> void:
	_set_home_status("设置功能开发中……")


# ============================================================
# 图鉴弹窗
# ============================================================
func _build_codex_popup() -> void:
	codex_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	codex_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(320, 0)
	margin.add_child(box)

	var title := Label.new()
	title.text = "📖 图鉴"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	codex_content_container = VBoxContainer.new()
	codex_content_container.add_theme_constant_override("separation", 8)
	codex_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(codex_content_container)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(0, 38)
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(close_button)
	close_button.pressed.connect(func() -> void: codex_popup.hide())
	box.add_child(close_button)

	add_child(codex_popup)


func _on_codex_button_pressed() -> void:
	codex_view_mode = "categories"
	selected_codex_category = ""
	selected_codex_beast_id = ""
	selected_codex_boss_id = ""
	_refresh_codex()
	codex_popup.popup_centered()


# ============================================================
# 永久天赋弹窗
# ============================================================
func _build_talent_popup() -> void:
	talent_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	talent_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(320, 0)
	margin.add_child(box)

	var title := Label.new()
	title.text = "✨ 永久天赋"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	talent_content_box = VBoxContainer.new()
	talent_content_box.add_theme_constant_override("separation", 8)
	talent_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(talent_content_box)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(0, 38)
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(close_button)
	close_button.pressed.connect(func() -> void: talent_popup.hide())
	box.add_child(close_button)

	add_child(talent_popup)


func _on_talent_pressed() -> void:
	_refresh_talent_popup()
	talent_popup.popup_centered()


func _refresh_talent_popup() -> void:
	var player := GameState.player
	if talent_content_box == null:
		return
	_clear_container(talent_content_box)

	var point_label := Label.new()
	point_label.text = "天赋点：%d" % player.talent_points
	_apply_label_style(point_label, 16, COLOR_AMBER)
	point_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	talent_content_box.add_child(point_label)

	var directions := {"生存": [], "战斗": [], "命运": []}
	for talent in TALENT_CONFIG:
		var direction := str(talent.get("direction", ""))
		if directions.has(direction):
			directions[direction].append(talent)

	for direction in ["生存", "战斗", "命运"]:
		var dir_label := Label.new()
		dir_label.text = "【%s】" % direction
		_apply_label_style(dir_label, 16, COLOR_AMBER)
		talent_content_box.add_child(dir_label)
		for talent in directions[direction]:
			var talent_id := str(talent.get("id", ""))
			var talent_name := str(talent.get("name", ""))
			var talent_desc := str(talent.get("desc", ""))
			var max_level := int(talent.get("max_level", 1))
			var cost := int(talent.get("cost", 1))
			var level := player.get_talent_level(talent_id)
			var level_text := "%d/%d" % [level, max_level]
			if level >= max_level:
				level_text = "MAX"
			var button := Button.new()
			button.text = "%s  Lv.%s\n%s（消耗%d点）" % [talent_name, level_text, talent_desc, cost]
			button.custom_minimum_size = Vector2(0, 58)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_apply_button_style(button)
			button.pressed.connect(_on_talent_upgrade_pressed.bind(talent_id, max_level, cost))
			talent_content_box.add_child(button)


func _on_talent_upgrade_pressed(talent_id: String, max_level: int, cost: int) -> void:
	var player := GameState.player
	var result: Dictionary = player.upgrade_talent(talent_id, max_level, cost)
	_set_home_status(str(result.get("text", "")))
	_refresh_talent_popup()
	_refresh_all()


# ============================================================
# Boss 战前界面
# ============================================================
func _build_boss_preview_popup() -> void:
	boss_preview_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	boss_preview_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(320, 0)
	margin.add_child(box)

	boss_preview_content_box = VBoxContainer.new()
	boss_preview_content_box.add_theme_constant_override("separation", 8)
	boss_preview_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(boss_preview_content_box)

	add_child(boss_preview_popup)


func _show_boss_preview(boss_id: String, chapter_id: int) -> void:
	_refresh_boss_preview(boss_id, chapter_id)
	boss_preview_popup.popup_centered()


func _refresh_boss_preview(boss_id: String, chapter_id: int) -> void:
	var player := GameState.player
	if boss_preview_content_box == null:
		return
	_clear_container(boss_preview_content_box)

	var boss := player.get_boss_config(boss_id)
	if boss.is_empty():
		return
	var boss_name := str(boss.get("name", boss_id))
	var recommend_level := int(boss.get("recommended_level", 0))
	var team_level := _get_team_level(player)
	var danger := _get_danger_level(team_level, recommend_level)

	var title := Label.new()
	title.text = "👹 %s" % boss_name
	_apply_label_style(title, 20, COLOR_AMBER)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_preview_content_box.add_child(title)

	var level_info := Label.new()
	level_info.text = "推荐：LV%d\n你的队伍：LV%d\n\n危险等级：%s" % [recommend_level, team_level, danger]
	_apply_label_style(level_info, 14)
	level_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_preview_content_box.add_child(level_info)

	var unlocked: Array = player.get_boss_unlocked_intel(boss_id)
	var intel_text := "【已知情报】\n"
	if unlocked.is_empty():
		intel_text += "尚未解锁任何情报。\n"
	else:
		for item in unlocked:
			intel_text += "✔ %s：%s\n" % [str(item.get("label", "")), str(item.get("value", ""))]
	var intel: Dictionary = boss.get("intel", {})
	for info in intel.get("weakness_info", []):
		if info is Dictionary and not bool(info.get("confirmed", false)):
			intel_text += "??? 待发现\n"
	var intel_label := Label.new()
	intel_label.text = intel_text
	_apply_label_style(intel_label, 13, COLOR_MUTED)
	intel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boss_preview_content_box.add_child(intel_label)

	var roles := _check_team_roles(player)
	var role_text := "【队伍建议】\n"
	for role_name in ["坦克", "治疗", "输出"]:
		var ok := bool(roles.get(role_name, false))
		role_text += "%s  %s\n" % [role_name, "✔" if ok else "✘"]
	var role_label := Label.new()
	role_label.text = role_text
	_apply_label_style(role_label, 13)
	boss_preview_content_box.add_child(role_label)

	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	boss_preview_content_box.add_child(button_row)

	var adjust_button := Button.new()
	adjust_button.text = "调整队伍"
	adjust_button.custom_minimum_size = Vector2(0, 38)
	adjust_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(adjust_button)
	adjust_button.pressed.connect(func() -> void:
		boss_preview_popup.hide()
		_switch_tab("team")
	)
	button_row.add_child(adjust_button)

	var challenge_button := Button.new()
	challenge_button.text = "挑战"
	challenge_button.custom_minimum_size = Vector2(0, 38)
	challenge_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(challenge_button, "panel")
	challenge_button.pressed.connect(func() -> void:
		boss_preview_popup.hide()
		player.story_chapter = chapter_id
		player.story_step = 0
		_on_story_enter_pressed()
	)
	button_row.add_child(challenge_button)


func _get_team_level(player: PlayerData) -> int:
	var total := 0
	var count := 0
	for survivor in player.survivors:
		total += int(survivor.get("level", 1))
		count += 1
	return 1 if count == 0 else int(float(total) / float(count))


func _get_danger_level(player_level: int, recommend_level: int) -> String:
	var diff := player_level - recommend_level
	if diff >= 0:
		return "⚠"
	elif diff >= -2:
		return "⚠⚠"
	elif diff >= -4:
		return "⚠⚠⚠"
	return "⚠⚠⚠⚠⚠"


func _check_team_roles(player: PlayerData) -> Dictionary:
	var roles := {"坦克": false, "治疗": false, "输出": false}
	for survivor in player.survivors:
		var profession := str(survivor.get("profession", ""))
		if profession == "先锋":
			roles["坦克"] = true
		elif profession == "支援者":
			roles["治疗"] = true
		elif profession == "游侠" or profession == "灵能者":
			roles["输出"] = true
	return roles


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

	reincarnation_rating_label = Label.new()
	reincarnation_rating_label.text = ""
	_apply_label_style(reincarnation_rating_label, 48, COLOR_AMBER)
	reincarnation_rating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reincarnation_rating_label.visible = false
	box.add_child(reincarnation_rating_label)

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
	reincarnation_rating_label.visible = false
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
	# 结算前统计（perform_reincarnation 会重置临时数据）
	var survival_text := _get_survival_time_text(player)
	var highest_chapter := int(player.highest_chapter_all_time)
	var highest_level := _get_highest_level(player)
	var intel_count := _get_boss_intel_count(player)
	var result: Dictionary = player.perform_reincarnation()
	var rating: String = str(result.get("rating", "C"))
	var marks: int = int(result.get("marks", 0))
	var talent: int = int(result.get("talent_points", 0))
	var killed: int = int(result.get("killed_bosses", 0))
	var total_bosses: int = int(result.get("total_bosses", 0))

	reincarnation_rating_label.visible = true
	reincarnation_rating_label.text = rating

	reincarnation_result_label.visible = true
	reincarnation_result_label.text = "━━━━━━━━━━━━━━\n存活：%s\n主线：第%d章\n最高等级：LV%d\n击败Boss：%d/%d\n发现Boss情报：%d\n━━━━━━━━━━━━━━\n获得\n轮回印记 +%d\n天赋点 +%d\n━━━━━━━━━━━━━━\n进入第 %d 轮" % [
		survival_text,
		highest_chapter,
		highest_level,
		killed, total_bosses,
		intel_count,
		marks,
		talent,
		int(player.reincarnation)
	]
	reincarnation_confirm_label.text = ""
	reincarnation_cancel_button.visible = false
	reincarnation_confirm_button.visible = false
	reincarnation_close_button.visible = true
	reincarnation_close_button.text = "进入下一轮"


func _get_survival_time_text(player: PlayerData) -> String:
	var hours := player.time_slot * 8
	return "%d天 %d小时" % [player.day, hours]


func _get_highest_level(player: PlayerData) -> int:
	var highest := 1
	for survivor in player.survivors:
		var lv := int(survivor.get("level", 1))
		if lv > highest:
			highest = lv
	return highest


func _get_boss_intel_count(player: PlayerData) -> int:
	var count := 0
	for boss_id in player.boss_intel:
		var state: Dictionary = player.boss_intel[boss_id]
		if bool(state.get("encountered", false)):
			count += 1
	return count


# ============================================================
# 主线剧情播放系统
# ============================================================
func _build_story_popup() -> void:
	story_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	story_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(320, 0)
	margin.add_child(box)

	story_title_label = Label.new()
	story_title_label.text = ""
	_apply_label_style(story_title_label, 18, COLOR_AMBER)
	story_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(story_title_label)

	story_speaker_label = Label.new()
	story_speaker_label.text = ""
	_apply_label_style(story_speaker_label, 15, COLOR_CYAN)
	box.add_child(story_speaker_label)

	story_text_label = Label.new()
	story_text_label.text = ""
	_apply_label_style(story_text_label, 14)
	story_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_text_label.custom_minimum_size = Vector2(0, 120)
	box.add_child(story_text_label)

	story_tutorial_label = Label.new()
	story_tutorial_label.text = ""
	_apply_label_style(story_tutorial_label, 13, COLOR_MUTED)
	story_tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_tutorial_label.visible = false
	box.add_child(story_tutorial_label)

	story_action_box = HBoxContainer.new()
	story_action_box.add_theme_constant_override("separation", 8)
	box.add_child(story_action_box)

	add_child(story_popup)


# 进入主线剧情
func _on_story_enter_pressed() -> void:
	var player := GameState.player
	if player.get_current_story_chapter().is_empty():
		_set_home_status("暂无可用剧情章节。")
		return
	story_popup.popup_centered()
	_play_story_step()


# 播放当前剧情步骤
func _play_story_step() -> void:
	var player := GameState.player
	var chapter := player.get_current_story_chapter()
	var step := player.get_current_story_step()

	story_title_label.text = "第%d章 · %s" % [player.story_chapter, str(chapter.get("name", ""))]
	story_tutorial_label.visible = false
	story_tutorial_label.text = ""
	_clear_story_actions()

	if step.is_empty():
		_finish_story_chapter()
		return

	var step_type: String = str(step.get("type", "dialogue"))
	var speaker: String = str(step.get("speaker", ""))
	var text: String = str(step.get("text", ""))

	match step_type:
		"narration":
			story_speaker_label.text = "【旁白】"
			story_text_label.text = text
			_add_story_continue_button()
		"monologue":
			story_speaker_label.text = "%s（独白）" % speaker
			story_text_label.text = text
			_add_story_continue_button()
		"scene":
			story_speaker_label.text = "【场景】"
			story_text_label.text = "—— %s ——" % str(step.get("name", ""))
			_add_story_continue_button()
		"system":
			story_speaker_label.text = "【系统】"
			story_text_label.text = text
			_add_story_continue_button()
		"tutorial":
			story_speaker_label.text = "📖 教学"
			story_text_label.text = str(step.get("title", ""))
			story_tutorial_label.visible = true
			story_tutorial_label.text = text
			_add_story_continue_button()
		"interaction":
			_play_interaction_step(step)
		"choice":
			_play_choice_step(step)
		"battle":
			_play_battle_step(step)
		"battle_result":
			_play_battle_result_step(step)
		"boss_phase":
			story_speaker_label.text = "⚔️ Boss阶段"
			story_text_label.text = text
			_add_story_continue_button()
		_:
			story_speaker_label.text = speaker if speaker != "" else "【叙述】"
			story_text_label.text = text
			_add_story_continue_button()


func _clear_story_actions() -> void:
	for child in story_action_box.get_children():
		story_action_box.remove_child(child)
		child.queue_free()


func _add_story_continue_button() -> void:
	var button := Button.new()
	button.text = "继续 ▶"
	button.custom_minimum_size = Vector2(0, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(button, "panel")
	button.pressed.connect(_on_story_continue_pressed)
	story_action_box.add_child(button)


func _on_story_continue_pressed() -> void:
	GameState.player.advance_story_step()
	_play_story_step()


func _play_interaction_step(step: Dictionary) -> void:
	var name: String = str(step.get("name", "物体"))
	var action: String = str(step.get("action", "调查"))
	var result: String = str(step.get("result", ""))
	var items: Array = step.get("items", [])
	var note: String = str(step.get("note", ""))
	story_speaker_label.text = "🔍 可交互：%s" % name
	var text := ""
	if not items.is_empty():
		text = "%s → 获得 %s" % [action, "、".join(items)]
		if note != "":
			text += "\n%s" % note
	elif result != "":
		text = "%s → %s" % [action, result]
	else:
		text = action
	story_text_label.text = text
	_add_story_continue_button()


func _play_choice_step(step: Dictionary) -> void:
	var options: Array = step.get("options", [])
	story_speaker_label.text = "【选择】"
	story_text_label.text = "请做出选择："
	for i in range(options.size()):
		var button := Button.new()
		button.text = str(options[i])
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_apply_button_style(button)
		button.pressed.connect(_on_story_choice_pressed.bind(i, str(options[i])))
		story_action_box.add_child(button)


func _on_story_choice_pressed(index: int, choice_text: String) -> void:
	var player := GameState.player
	player.story_flags["story_choice_%d_%d" % [player.story_chapter, player.story_step]] = choice_text
	player.advance_story_step()
	_play_story_step()


func _play_battle_step(step: Dictionary) -> void:
	var enemies: Array = step.get("enemies", [])
	var note: String = str(step.get("note", ""))
	story_speaker_label.text = "⚔️ 战斗"
	var enemies_text := "、".join(enemies) if not enemies.is_empty() else "敌人"
	var text := "遭遇敌人：%s" % enemies_text
	if note != "":
		text += "\n提示：%s" % note
	story_text_label.text = text
	_add_story_continue_button()


func _play_battle_result_step(step: Dictionary) -> void:
	var enemies: String = str(step.get("enemies", ""))
	var exp: int = int(step.get("exp", 0))
	var items: Array = step.get("items", [])
	var note: String = str(step.get("note", ""))
	story_speaker_label.text = "✅ 战斗胜利"
	var text := "击败：%s" % enemies
	if exp > 0:
		text += "\n获得经验：%d" % exp
	if not items.is_empty():
		text += "\n获得：%s" % "、".join(items)
	if note != "":
		text += "\n%s" % note
	story_text_label.text = text
	_add_story_continue_button()


func _finish_story_chapter() -> void:
	var player := GameState.player
	var settlement: Dictionary = player.complete_story_chapter()
	var exp: int = int(settlement.get("exp", 0))
	var items: Array = settlement.get("items", [])
	var unlock: Array = settlement.get("unlock", [])
	story_speaker_label.text = "🎉 章节完成"
	var text := "第%d章完成！" % (player.story_chapter - 1)
	if exp > 0:
		text += "\n获得经验：%d" % exp
	if not items.is_empty():
		text += "\n获得：%s" % "、".join(items)
	if not unlock.is_empty():
		text += "\n解锁：%s" % "、".join(unlock)
	story_text_label.text = text
	var button := Button.new()
	button.text = "完成（返回）"
	button.custom_minimum_size = Vector2(0, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(button, "panel")
	button.pressed.connect(func() -> void:
		story_popup.hide()
		_refresh_all()
	)
	story_action_box.add_child(button)


# ============================================================
# 商城系统 UI
# ============================================================
func _build_store_popup() -> void:
	store_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	store_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(320, 0)
	margin.add_child(box)

	var title := Label.new()
	title.text = "🏪 商城"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 300)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	store_content_box = VBoxContainer.new()
	store_content_box.add_theme_constant_override("separation", 8)
	store_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(store_content_box)

	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(0, 38)
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(close_button)
	close_button.pressed.connect(func() -> void: store_popup.hide())
	box.add_child(close_button)

	add_child(store_popup)


func _on_store_pressed() -> void:
	_refresh_store_page()
	store_popup.popup_centered()


func _refresh_store_page() -> void:
	var player := GameState.player
	if store_content_box == null:
		return
	_clear_container(store_content_box)

	var currency_label := Label.new()
	currency_label.text = "💎 水晶 %d  |  🪙 金币 %d  |  🎫 补给券 %d" % [
		int(player.materials.get("crystal", 0)),
		int(player.materials.get("gold", 0)),
		int(player.materials.get("tickets", 0))
	]
	_apply_label_style(currency_label, 14, COLOR_AMBER)
	currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	store_content_box.add_child(currency_label)

	# 抽奖按钮
	var gacha_row := HBoxContainer.new()
	gacha_row.add_theme_constant_override("separation", 8)
	store_content_box.add_child(gacha_row)

	var gacha1_button := Button.new()
	gacha1_button.text = "🎟️ 抽一次（券×1）"
	gacha1_button.custom_minimum_size = Vector2(0, 40)
	gacha1_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(gacha1_button, "panel")
	gacha1_button.pressed.connect(_on_gacha_pressed.bind(1))
	gacha_row.add_child(gacha1_button)

	var gacha10_button := Button.new()
	gacha10_button.text = "🎟️ 十连（券×10）"
	gacha10_button.custom_minimum_size = Vector2(0, 40)
	gacha10_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(gacha10_button, "panel")
	gacha10_button.pressed.connect(_on_gacha_pressed.bind(10))
	gacha_row.add_child(gacha10_button)

	var tabs: Array = DataManager.store_items.get("tabs", [])
	for tab in tabs:
		var tab_title := Label.new()
		tab_title.text = "【%s】" % str(tab.get("name", ""))
		_apply_label_style(tab_title, 16, COLOR_AMBER)
		store_content_box.add_child(tab_title)
		for item in tab.get("items", []):
			var item_id := str(item.get("id", ""))
			var item_name := str(item.get("name", ""))
			var item_desc := str(item.get("description", ""))
			var price_text: String = StoreSystem.format_price(item.get("price", {}))
			var item_button := Button.new()
			item_button.text = "%s\n%s\n价格：%s" % [item_name, item_desc, price_text]
			item_button.custom_minimum_size = Vector2(0, 64)
			item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			_apply_button_style(item_button)
			item_button.pressed.connect(_on_store_buy_pressed.bind(item_id))
			store_content_box.add_child(item_button)


func _on_store_buy_pressed(item_id: String) -> void:
	var result: Dictionary = StoreSystem.purchase_item(GameState.player, item_id)
	_set_home_status(str(result.get("text", "")))
	_refresh_store_page()
	_refresh_all()


func _build_gacha_result_popup() -> void:
	gacha_result_popup = PopupPanel.new()
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	gacha_result_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(300, 0)
	margin.add_child(box)

	var title := Label.new()
	title.text = "🎉 抽奖结果"
	_apply_label_style(title, 20, COLOR_CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	gacha_result_label = Label.new()
	gacha_result_label.text = ""
	_apply_label_style(gacha_result_label, 14)
	gacha_result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(gacha_result_label)

	var close_button := Button.new()
	close_button.text = "确定"
	close_button.custom_minimum_size = Vector2(0, 38)
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_button_style(close_button, "panel")
	close_button.pressed.connect(func() -> void: gacha_result_popup.hide())
	box.add_child(close_button)

	add_child(gacha_result_popup)


func _on_gacha_pressed(times: int) -> void:
	var result: Dictionary = StoreSystem.do_gacha(GameState.player, times)
	if not result.get("success", false):
		_set_home_status(str(result.get("text", "")))
		return
	_show_gacha_result(result)
	_refresh_store_page()


func _show_gacha_result(result: Dictionary) -> void:
	var results: Array = result.get("results", [])
	var lines: Array[String] = []
	for r in results:
		var rarity := str(r.get("rarity", ""))
		var name := str(r.get("name", ""))
		var mark := "🆕" if bool(r.get("is_new", false)) else ""
		lines.append("[%s] %s %s" % [rarity, name, mark])
	gacha_result_label.text = "本次获得：\n" + ("\n".join(lines) if not lines.is_empty() else "无")
	gacha_result_popup.popup_centered()


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	return sep
