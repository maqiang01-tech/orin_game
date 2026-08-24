extends Control

const COLOR_BG := Color(0.015, 0.02, 0.025, 1.0)
const COLOR_PANEL := Color(0.035, 0.055, 0.065, 0.92)
const COLOR_CARD := Color(0.025, 0.04, 0.048, 0.96)
const COLOR_CYAN := Color(0.0, 0.88, 1.0, 1.0)
const COLOR_AMBER := Color(1.0, 0.64, 0.1, 1.0)
const COLOR_RED := Color(1.0, 0.22, 0.18, 1.0)
const COLOR_GREEN := Color(0.24, 0.95, 0.55, 1.0)
const COLOR_TEXT := Color(0.84, 0.94, 0.98, 1.0)
const DESIGN_SIZE := Vector2(720, 1280)
const BATTLE_STAGE_WIDTH := 620.0
const UNIT_CARD_SIZE := Vector2(138, 196)

var battle: Dictionary = {}
var unit_cards: Dictionary = {}
var selected_target_id: String = ""
var current_actor_id: String = ""
var auto_mode := false
var is_animating := false

var design_root: Control
var battlefield: Control
var battlefield_bg: TextureRect
var card_layer: Control
var fx_layer: Control
var status_label: Label
var round_label: Label
var actor_label: Label
var action_box: HBoxContainer
var log_label: RichTextLabel
var auto_button: Button
var last_viewport_size := Vector2.ZERO


func _ready() -> void:
        _force_portrait_debug_window()
        DataManager.ensure_loaded()
        _build_ui()
        _start_demo_battle()
        if not get_viewport().size_changed.is_connected(_fit_design_root):
                get_viewport().size_changed.connect(_fit_design_root)
        _fit_design_root.call_deferred()


func _process(_delta: float) -> void:
        var viewport_size := get_viewport().get_visible_rect().size
        if viewport_size != last_viewport_size:
                _fit_design_root()


func _force_portrait_debug_window() -> void:
        var window := get_window()
        if window == null:
                return
        window.min_size = Vector2i(360, 640)


func _build_ui() -> void:
        var bg := ColorRect.new()
        bg.color = COLOR_BG
        bg.set_anchors_preset(Control.PRESET_FULL_RECT)
        add_child(bg)

        design_root = Control.new()
        design_root.name = "DesignRoot"
        design_root.clip_contents = true
        design_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
        design_root.position = Vector2.ZERO
        design_root.size = DESIGN_SIZE
        add_child(design_root)

        var frame := TextureRect.new()
        frame.texture = load("res://assets/images/ui/ui_frame_full.png")
        frame.set_anchors_preset(Control.PRESET_FULL_RECT)
        frame.stretch_mode = TextureRect.STRETCH_SCALE
        frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
        design_root.add_child(frame)

        var root := MarginContainer.new()
        root.set_anchors_preset(Control.PRESET_FULL_RECT)
        root.add_theme_constant_override("margin_left", 28)
        root.add_theme_constant_override("margin_right", 28)
        root.add_theme_constant_override("margin_top", 28)
        root.add_theme_constant_override("margin_bottom", 28)
        design_root.add_child(root)

        var main := VBoxContainer.new()
        main.add_theme_constant_override("separation", 10)
        root.add_child(main)

        var top_panel := PanelContainer.new()
        top_panel.custom_minimum_size = Vector2(0, 96)
        top_panel.add_theme_stylebox_override("panel", _style(COLOR_PANEL, COLOR_CYAN, 2, 6))
        main.add_child(top_panel)

        var top_box := VBoxContainer.new()
        top_box.add_theme_constant_override("separation", 3)
        top_panel.add_child(top_box)

        round_label = Label.new()
        round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        round_label.add_theme_color_override("font_color", COLOR_CYAN)
        round_label.add_theme_font_size_override("font_size", 24)
        top_box.add_child(round_label)

        actor_label = Label.new()
        actor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        actor_label.add_theme_color_override("font_color", COLOR_AMBER)
        actor_label.add_theme_font_size_override("font_size", 16)
        top_box.add_child(actor_label)

        status_label = Label.new()
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        status_label.add_theme_color_override("font_color", COLOR_TEXT)
        status_label.add_theme_font_size_override("font_size", 14)
        top_box.add_child(status_label)

        battlefield = PanelContainer.new()
        battlefield.size_flags_vertical = Control.SIZE_EXPAND_FILL
        battlefield.clip_contents = true
        battlefield.add_theme_stylebox_override("panel", _style(Color(0.02, 0.025, 0.03, 0.90), COLOR_CYAN, 2, 8))
        main.add_child(battlefield)

        battlefield_bg = TextureRect.new()
        battlefield_bg.texture = load("res://assets/images/exploration/world_map_wide_city_realm_v5_clean.png")
        battlefield_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        battlefield_bg.stretch_mode = TextureRect.STRETCH_SCALE
        battlefield_bg.modulate = Color(0.42, 0.52, 0.56, 0.35)
        battlefield_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        battlefield.add_child(battlefield_bg)

        card_layer = Control.new()
        card_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
        battlefield.add_child(card_layer)

        fx_layer = Control.new()
        fx_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
        fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
        battlefield.add_child(fx_layer)

        var bottom := PanelContainer.new()
        bottom.custom_minimum_size = Vector2(0, 260)
        bottom.add_theme_stylebox_override("panel", _style(COLOR_PANEL, COLOR_CYAN, 2, 6))
        main.add_child(bottom)

        var bottom_box := VBoxContainer.new()
        bottom_box.add_theme_constant_override("separation", 8)
        bottom.add_child(bottom_box)

        action_box = HBoxContainer.new()
        action_box.add_theme_constant_override("separation", 8)
        bottom_box.add_child(action_box)

        log_label = RichTextLabel.new()
        log_label.fit_content = false
        log_label.scroll_active = false
        log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
        log_label.bbcode_enabled = true
        log_label.add_theme_color_override("default_color", COLOR_TEXT)
        log_label.add_theme_font_size_override("normal_font_size", 14)
        bottom_box.add_child(log_label)
        _fit_design_root()


func _fit_design_root() -> void:
        if design_root == null:
                return
        var viewport_size := get_viewport().get_visible_rect().size
        if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
                viewport_size = DESIGN_SIZE
        var scale_value := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
        last_viewport_size = viewport_size
        design_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
        design_root.size = DESIGN_SIZE
        design_root.scale = Vector2(scale_value, scale_value)
        design_root.position = (viewport_size - DESIGN_SIZE * scale_value) * 0.5
        design_root.position = Vector2(roundf(design_root.position.x), roundf(design_root.position.y))
        _layout_battle_background()
        _layout_unit_cards()


func _layout_battle_background() -> void:
        if battlefield_bg == null or battlefield_bg.texture == null or battlefield == null:
                return
        var box_size := battlefield.size
        if box_size.x <= 0.0 or box_size.y <= 0.0:
                box_size = Vector2(664.0, 724.0)
        var texture_size := battlefield_bg.texture.get_size()
        if texture_size.x <= 0.0 or texture_size.y <= 0.0:
                return
        var fit_scale := minf(box_size.x / texture_size.x, box_size.y / texture_size.y)
        var draw_size := texture_size * fit_scale
        battlefield_bg.size = draw_size
        battlefield_bg.position = (box_size - draw_size) * 0.5


func _start_demo_battle() -> void:
        var party := _get_demo_party()
        var enemies := _get_demo_enemies()
        var bonus := GameState.player.get_formation_bonus() if GameState.player != null else {}
        battle = BattleSystem.create_battle(party, enemies, bonus, [0, 4, 8])
        selected_target_id = str(battle["enemy_party"][0]) if not battle["enemy_party"].is_empty() else ""
        _create_unit_cards()
        _refresh_all()
        _process_next_turn()


func _get_demo_party() -> Array:
        GameState.ensure_initial_survivors()
        var party: Array = []
        for survivor in GameState.player.survivors:
                party.append(survivor.duplicate(true))
                if party.size() >= 3:
                        break
        if party.size() < 3:
                for partner in DataManager.partners:
                        var exists := false
                        for owned in party:
                                if str(owned.get("id", "")) == str(partner.get("id", "")):
                                        exists = true
                                        break
                        if not exists:
                                party.append(partner.duplicate(true))
                        if party.size() >= 3:
                                break
        return party


func _get_demo_enemies() -> Array:
        var result: Array = []
        for beast_id in ["flame_hound", "crawler", "mutated_cockroach"]:
                if DataManager.beasts.has(beast_id):
                        result.append(DataManager.beasts[beast_id].duplicate(true))
        return result


func _create_unit_cards() -> void:
        for child in card_layer.get_children():
                child.queue_free()
        unit_cards.clear()

        for unit_id in battle["player_party"]:
                _add_unit_card(str(unit_id))
        for unit_id in battle["enemy_party"]:
                _add_unit_card(str(unit_id))
        _layout_unit_cards()


func _add_unit_card(unit_id: String) -> void:
        var unit: Dictionary = battle["units"][unit_id]
        var card := Control.new()
        card.custom_minimum_size = UNIT_CARD_SIZE
        card.size = UNIT_CARD_SIZE
        card.clip_contents = false
        card.gui_input.connect(_on_unit_slot_input.bind(unit_id))
        card_layer.add_child(card)
        unit_cards[unit_id] = card

        var back_panel := PanelContainer.new()
        back_panel.name = "BackPanel"
        back_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
        back_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
        back_panel.add_theme_stylebox_override("panel", _style(COLOR_CARD, COLOR_CYAN, 2, 6))
        card.add_child(back_panel)

        var portrait_slot := Control.new()
        portrait_slot.name = "PortraitSlot"
        portrait_slot.clip_contents = true
        portrait_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(portrait_slot)

        var portrait_bg := PanelContainer.new()
        portrait_bg.name = "PortraitBg"
        portrait_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
        portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
        portrait_bg.add_theme_stylebox_override("panel", _style(Color(0.02, 0.025, 0.03, 0.75), Color(0.0, 0.5, 0.6, 0.55), 1, 4))
        portrait_slot.add_child(portrait_bg)

        var portrait := TextureRect.new()
        portrait.name = "Portrait"
        portrait.texture = _get_unit_texture(unit)
        portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
        portrait_slot.add_child(portrait)

        var name_label := Label.new()
        name_label.name = "NameLabel"
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        name_label.add_theme_color_override("font_color", COLOR_TEXT)
        name_label.add_theme_font_size_override("font_size", 15)
        name_label.text = str(unit.get("name", unit_id))
        name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(name_label)

        var hp_bar := ProgressBar.new()
        hp_bar.name = "HpBar"
        hp_bar.show_percentage = false
        hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(hp_bar)

        var ep_bar := ProgressBar.new()
        ep_bar.name = "EpBar"
        ep_bar.show_percentage = false
        ep_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(ep_bar)

        var hp_label := Label.new()
        hp_label.name = "HpLabel"
        hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        hp_label.add_theme_color_override("font_color", COLOR_TEXT)
        hp_label.add_theme_font_size_override("font_size", 12)
        hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(hp_label)

        var tag := Label.new()
        tag.name = "TagLabel"
        tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        tag.add_theme_color_override("font_color", COLOR_AMBER)
        tag.add_theme_font_size_override("font_size", 12)
        tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(tag)
        _update_unit_component_layout(card)


func _on_unit_slot_input(event: InputEvent, unit_id: String) -> void:
        if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
                _on_unit_card_pressed(unit_id)


func _update_unit_component_layout(card: Control) -> void:
        var s := card.size
        var pad := 8.0
        var portrait_h := maxf(88.0, s.y - 106.0)
        var portrait_slot: Control = card.get_node("PortraitSlot")
        portrait_slot.position = Vector2(pad, pad)
        portrait_slot.size = Vector2(s.x - pad * 2.0, portrait_h)

        var name_label: Label = card.get_node("NameLabel")
        name_label.position = Vector2(pad, portrait_slot.position.y + portrait_slot.size.y + 4.0)
        name_label.size = Vector2(s.x - pad * 2.0, 20.0)

        var hp_bar: ProgressBar = card.get_node("HpBar")
        hp_bar.position = Vector2(pad, name_label.position.y + name_label.size.y + 4.0)
        hp_bar.size = Vector2(s.x - pad * 2.0, 14.0)

        var ep_bar: ProgressBar = card.get_node("EpBar")
        ep_bar.position = Vector2(pad, hp_bar.position.y + hp_bar.size.y + 3.0)
        ep_bar.size = Vector2(s.x - pad * 2.0, 10.0)

        var hp_label: Label = card.get_node("HpLabel")
        hp_label.position = Vector2(pad, ep_bar.position.y + ep_bar.size.y + 2.0)
        hp_label.size = Vector2(s.x - pad * 2.0, 18.0)

        var tag: Label = card.get_node("TagLabel")
        tag.position = Vector2(pad, s.y - 22.0)
        tag.size = Vector2(s.x - pad * 2.0, 16.0)


func _layout_unit_cards() -> void:
        if battlefield == null or unit_cards.is_empty():
                return
        var w := 664.0
        var h := battlefield.size.y
        if h <= 0.0:
                h = 724.0
        var card_size := UNIT_CARD_SIZE
        var stage_width := minf(w - 24.0, BATTLE_STAGE_WIDTH)
        var stage_left := (w - stage_width) * 0.5
        var column_gap := (stage_width - card_size.x * 3.0) / 2.0
        var col_x := [
                stage_left,
                stage_left + card_size.x + column_gap,
                stage_left + (card_size.x + column_gap) * 2.0
        ]
        var player_positions := [
                Vector2(col_x[0], h - card_size.y - 36.0),
                Vector2(col_x[1], h - card_size.y - 70.0),
                Vector2(col_x[2], h - card_size.y - 36.0)
        ]
        var enemy_positions := [
                Vector2(col_x[0], 48.0),
                Vector2(col_x[1], 82.0),
                Vector2(col_x[2], 48.0)
        ]

        for i in range(battle.get("player_party", []).size()):
                var unit_id := str(battle["player_party"][i])
                if unit_cards.has(unit_id):
                        unit_cards[unit_id].size = card_size
                        unit_cards[unit_id].position = player_positions[i]
                        _update_unit_component_layout(unit_cards[unit_id])
        for i in range(battle.get("enemy_party", []).size()):
                var unit_id := str(battle["enemy_party"][i])
                if unit_cards.has(unit_id):
                        unit_cards[unit_id].size = card_size
                        unit_cards[unit_id].position = enemy_positions[i]
                        _update_unit_component_layout(unit_cards[unit_id])


func _process_next_turn() -> void:
        if is_animating:
                return
        if battle.is_empty():
                return
        if battle.get("battle_over", false):
                _finish_battle()
                return

        current_actor_id = BattleSystem.get_current_actor(battle)
        if current_actor_id == "":
                BattleSystem.check_battle_over(battle)
                _refresh_all()
                if battle.get("battle_over", false):
                        _finish_battle()
                return

        _refresh_all()
        var actor: Dictionary = battle["units"][current_actor_id]
        if actor.get("team", "") == "enemy" or auto_mode:
                _set_actions_enabled(false)
                _run_auto_turn(current_actor_id)
        else:
                _build_action_buttons()
                _set_actions_enabled(true)


func _run_auto_turn(actor_id: String) -> void:
        await get_tree().create_timer(0.45).timeout
        if battle.is_empty() or battle.get("battle_over", false):
                return
        if BattleSystem.get_current_actor(battle) != actor_id:
                return
        var action: Dictionary = BattleSystem.decide_ai_action(battle, actor_id)
        var action_type := str(action.get("action", "attack"))
        var target_id := str(action.get("target_id", ""))
        var skill_id := str(action.get("skill_id", ""))
        var targets := []
        if target_id != "":
                targets.append(target_id)
        _execute_action(action_type, targets, skill_id)


func _build_action_buttons() -> void:
        for child in action_box.get_children():
                child.queue_free()

        _add_action_button("攻击", _on_attack_pressed)
        var usable := BattleSystem.get_usable_skills(battle, current_actor_id)
        for i in range(mini(2, usable.size())):
                var skill_id := str(usable[i])
                var skill: Dictionary = DataManager.skills.get(skill_id, {})
                _add_action_button(str(skill.get("name", skill_id)), _on_skill_pressed.bind(skill_id))
        _add_action_button("防御", _on_guard_pressed)

        auto_button = _add_action_button("自动:关", _on_auto_pressed)
        auto_button.toggle_mode = true
        auto_button.button_pressed = auto_mode


func _add_action_button(label: String, callable: Callable) -> Button:
        var button := Button.new()
        button.text = label
        button.custom_minimum_size = Vector2(0, 52)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.add_theme_stylebox_override("normal", _style(Color(0.025, 0.06, 0.07, 0.95), COLOR_CYAN, 2, 5))
        button.add_theme_stylebox_override("hover", _style(Color(0.06, 0.08, 0.08, 0.98), COLOR_AMBER, 2, 5))
        button.add_theme_color_override("font_color", COLOR_TEXT)
        button.add_theme_font_size_override("font_size", 15)
        button.pressed.connect(callable)
        action_box.add_child(button)
        return button


func _on_attack_pressed() -> void:
        var target_id := _get_selected_enemy()
        if target_id == "":
                return
        _execute_action("attack", [target_id], "")


func _on_skill_pressed(skill_id: String) -> void:
        var target_id := _pick_skill_target(skill_id)
        var targets := []
        if target_id != "":
                targets.append(target_id)
        _execute_action("skill", targets, skill_id)


func _on_guard_pressed() -> void:
        _execute_action("guard", [], "")


func _on_auto_pressed() -> void:
        auto_mode = not auto_mode
        if auto_button != null:
                auto_button.text = "自动:开" if auto_mode else "自动:关"
        if auto_mode and not is_animating:
                _process_next_turn()


func _on_unit_card_pressed(unit_id: String) -> void:
        if battle.is_empty() or not battle["units"].has(unit_id):
                return
        var unit: Dictionary = battle["units"][unit_id]
        if unit.get("team", "") == "enemy" and not unit.get("defeated", false):
                selected_target_id = unit_id
                _refresh_all()


func _execute_action(action_type: String, target_ids: Array, skill_id: String) -> void:
        if is_animating or battle.get("battle_over", false):
                return
        var actor_id := BattleSystem.get_current_actor(battle)
        if actor_id == "" or not battle["units"].has(actor_id):
                return
        is_animating = true
        _set_actions_enabled(false)

        var before := _snapshot_hp()
        var target_id := str(target_ids[0]) if not target_ids.is_empty() else ""
        var action_name := _get_action_name(action_type, skill_id)
        status_label.text = "%s 使用 %s" % [battle["units"][actor_id].get("name", actor_id), action_name]
        await _animate_cast(actor_id, target_id)

        BattleSystem.perform_action(battle, actor_id, action_type, target_ids, skill_id)
        await _show_hp_deltas(before)

        is_animating = false
        _refresh_all()
        await get_tree().create_timer(0.22).timeout
        _process_next_turn()


func _animate_cast(actor_id: String, target_id: String) -> void:
        if unit_cards.has(actor_id):
                var card: Control = unit_cards[actor_id]
                var start := card.position
                var dir := 1.0 if battle["units"][actor_id].get("team", "") == "player" else -1.0
                var tween := create_tween()
                tween.tween_property(card, "position:x", start.x + 24.0 * dir, 0.12)
                tween.tween_property(card, "position:x", start.x, 0.12)
                await tween.finished
        if target_id != "" and unit_cards.has(target_id):
                var target: Control = unit_cards[target_id]
                var tween2 := create_tween()
                tween2.tween_property(target, "modulate", Color(1.0, 0.45, 0.45, 1.0), 0.08)
                tween2.tween_property(target, "modulate", Color.WHITE, 0.12)
                await tween2.finished


func _show_hp_deltas(before: Dictionary) -> void:
        var changed := false
        for unit_id in battle["units"]:
                var unit: Dictionary = battle["units"][unit_id]
                var old_hp := float(before.get(unit_id, unit.get("hp", 0.0)))
                var new_hp := float(unit.get("hp", 0.0))
                var delta := roundi(new_hp - old_hp)
                if delta != 0 and unit_cards.has(unit_id):
                        changed = true
                        _spawn_float_text(unit_cards[unit_id], delta)
        _refresh_unit_cards()
        if changed:
                await get_tree().create_timer(0.45).timeout


func _spawn_float_text(card: Control, delta: int) -> void:
        var label := Label.new()
        label.text = ("+" if delta > 0 else "") + str(delta)
        label.add_theme_font_size_override("font_size", 24)
        label.add_theme_color_override("font_color", COLOR_GREEN if delta > 0 else COLOR_RED)
        label.position = card.position + Vector2(card.size.x * 0.36, 8)
        fx_layer.add_child(label)
        var tween := create_tween()
        tween.tween_property(label, "position:y", label.position.y - 42.0, 0.45)
        tween.parallel().tween_property(label, "modulate:a", 0.0, 0.45)
        tween.finished.connect(label.queue_free)


func _snapshot_hp() -> Dictionary:
        var result := {}
        for unit_id in battle["units"]:
                result[unit_id] = float(battle["units"][unit_id].get("hp", 0.0))
        return result


func _refresh_all() -> void:
        if battle.is_empty():
                return
        round_label.text = "演示战斗  第 %d 回合" % int(battle.get("round", 1))
        if current_actor_id != "" and battle["units"].has(current_actor_id):
                actor_label.text = "当前行动：%s" % battle["units"][current_actor_id].get("name", current_actor_id)
        else:
                actor_label.text = "当前行动：等待"
        if battle.get("battle_over", false):
                status_label.text = "战斗胜利" if battle.get("victory", false) else "战斗失败"
        elif status_label.text == "":
                status_label.text = "点击敌人选择目标，使用攻击或技能推进回合。"
        _refresh_unit_cards()
        _refresh_log()


func _refresh_unit_cards() -> void:
        for unit_id in unit_cards:
                if not battle["units"].has(unit_id):
                        continue
                var unit: Dictionary = battle["units"][unit_id]
                var card: Control = unit_cards[unit_id]
                var back_panel: PanelContainer = card.get_node("BackPanel")
                var hp_bar: ProgressBar = card.get_node("HpBar")
                var ep_bar: ProgressBar = card.get_node("EpBar")
                var hp_label: Label = card.get_node("HpLabel")
                var tag: Label = card.get_node("TagLabel")
                hp_bar.max_value = maxf(1.0, float(unit.get("max_hp", 1.0)))
                hp_bar.value = clampf(float(unit.get("hp", 0.0)), 0.0, hp_bar.max_value)
                ep_bar.max_value = maxf(1.0, float(unit.get("max_energy", 1.0)))
                ep_bar.value = clampf(float(unit.get("energy", 0.0)), 0.0, ep_bar.max_value)
                hp_label.text = "HP %d/%d  EP %d" % [int(unit.get("hp", 0)), int(unit.get("max_hp", 0)), int(unit.get("energy", 0))]
                if unit.get("defeated", false):
                        card.modulate = Color(0.35, 0.35, 0.35, 0.78)
                        tag.text = "倒下"
                        back_panel.add_theme_stylebox_override("panel", _style(COLOR_CARD, Color(0.2, 0.35, 0.38, 0.75), 2, 6))
                else:
                        card.modulate = Color.WHITE
                        tag.text = "目标" if unit_id == selected_target_id else str(unit.get("type", ""))
                        var border := COLOR_AMBER if unit_id == selected_target_id or unit_id == current_actor_id else COLOR_CYAN
                        back_panel.add_theme_stylebox_override("panel", _style(COLOR_CARD, border, 2, 6))
                if unit_id == current_actor_id:
                        tag.text = "行动中"


func _refresh_log() -> void:
        var lines: Array = battle.get("log", [])
        var start := maxi(0, lines.size() - 6)
        var text := ""
        for i in range(start, lines.size()):
                text += str(lines[i]) + "\n"
        log_label.text = text


func _finish_battle() -> void:
        _set_actions_enabled(false)
        _build_end_buttons()
        status_label.text = "战斗胜利，异兽被击退。" if battle.get("victory", false) else "战斗失败，队伍需要撤离。"
        _refresh_all()


func _build_end_buttons() -> void:
        for child in action_box.get_children():
                child.queue_free()
        _add_action_button("重新演示", _start_demo_battle)
        _add_action_button("退出场景", func() -> void: get_tree().change_scene_to_file("res://scenes/main/main.tscn"))


func _set_actions_enabled(enabled: bool) -> void:
        for child in action_box.get_children():
                if child is Button:
                        child.disabled = not enabled


func _get_selected_enemy() -> String:
        if selected_target_id != "" and battle["units"].has(selected_target_id):
                var selected: Dictionary = battle["units"][selected_target_id]
                if selected.get("team", "") == "enemy" and not selected.get("defeated", false):
                        return selected_target_id
        var alive := BattleSystem.get_alive_team_units(battle, "enemy")
        return str(alive[0]) if not alive.is_empty() else ""


func _pick_skill_target(skill_id: String) -> String:
        var skill: Dictionary = DataManager.skills.get(skill_id, {})
        var type_text := str(skill.get("type", ""))
        if type_text.begins_with("辅助"):
                return current_actor_id
        return _get_selected_enemy()


func _get_action_name(action_type: String, skill_id: String) -> String:
        if action_type == "skill":
                var skill: Dictionary = DataManager.skills.get(skill_id, {})
                return str(skill.get("name", skill_id))
        if action_type == "guard":
                return "防御"
        return "攻击"


func _get_unit_texture(unit: Dictionary) -> Texture2D:
        var base_id := str(unit.get("base_id", ""))
        if unit.get("team", "") == "player":
                return _get_character_texture(base_id)
        return _get_beast_texture(base_id)


func _get_character_texture(character_id: String) -> Texture2D:
        var sheet_data: Dictionary = DataManager.character_assets.get("portrait_sheet", {})
        var chars: Dictionary = DataManager.character_assets.get("characters", {})
        if not chars.has(character_id):
                return null
        var texture := load(str(sheet_data.get("path", "")))
        if texture == null:
                return null
        var rect_data: Array = chars[character_id].get("portrait_rect", [])
        return _make_atlas(texture, rect_data)


func _get_beast_texture(beast_id: String) -> Texture2D:
        var beasts: Dictionary = DataManager.beast_assets.get("beasts", {})
        if beasts.has(beast_id):
                var portrait_path := str(beasts[beast_id].get("portrait", ""))
                if portrait_path != "":
                        var portrait := load(portrait_path)
                        if portrait != null:
                                return portrait
        var sheet_data: Dictionary = DataManager.beast_assets.get("avatar_sheet", {})
        var texture := load(str(sheet_data.get("path", "")))
        if texture == null or not beasts.has(beast_id):
                return null
        var rect_data: Array = beasts[beast_id].get("avatar_rect", [])
        return _make_atlas(texture, rect_data)


func _make_atlas(texture: Texture2D, rect_data: Array) -> Texture2D:
        if rect_data.size() < 4:
                return texture
        var atlas := AtlasTexture.new()
        atlas.atlas = texture
        atlas.region = Rect2(float(rect_data[0]), float(rect_data[1]), float(rect_data[2]), float(rect_data[3]))
        return atlas


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
        var style := StyleBoxFlat.new()
        style.bg_color = bg
        style.border_color = border
        style.border_width_left = width
        style.border_width_top = width
        style.border_width_right = width
        style.border_width_bottom = width
        style.corner_radius_top_left = radius
        style.corner_radius_top_right = radius
        style.corner_radius_bottom_left = radius
        style.corner_radius_bottom_right = radius
        style.content_margin_left = 10
        style.content_margin_top = 8
        style.content_margin_right = 10
        style.content_margin_bottom = 8
        return style
