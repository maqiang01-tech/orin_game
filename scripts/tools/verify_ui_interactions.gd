extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
	if packed_scene == null:
		push_error("Main scene could not be loaded.")
		quit(1)
		return
	var scene := packed_scene.instantiate()
	if scene.get_script() == null or not scene.has_method("_switch_tab"):
		push_error("Main scene script did not load; interaction verification cannot run.")
		quit(1)
		return
	root.add_child(scene)
	await process_frame
	await process_frame

	_verify_navigation(scene)
	await _verify_world_map(scene)
	await _verify_formation(scene)
	await _verify_base(scene)
	await _verify_reincarnation(scene)

	if failures.is_empty():
		print("UI interaction verification: PASS")
		quit()
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _verify_navigation(scene: Node) -> void:
	var buttons: Dictionary = scene.get("tab_buttons")
	_check(buttons.size() == 5, "Bottom navigation must contain five buttons.")
	var expected_home_size := Vector2(136.8, 128)
	var selected_home_count := 0
	for button in buttons.values():
		var nav_button := button as Button
		_check(nav_button.size.is_equal_approx(expected_home_size), "Bottom navigation hotspot does not match the five-column production bar.")
		var rect := nav_button.get_global_rect()
		_check(rect.position.x >= 0.0 and rect.end.x <= 720.0, "Bottom navigation button exceeds the horizontal viewport.")
		_check(rect.position.y >= 1134.0 and rect.end.y <= 1280.0, "Bottom navigation button exceeds its safe area.")
		var image := nav_button.get_node_or_null("ButtonImage") as TextureRect
		_check(image != null and image.visible == nav_button.button_pressed, "Navigation must overlay artwork only for the selected tab.")
		if nav_button.button_pressed:
			selected_home_count += 1
			_check(image != null and image.texture == nav_button.get_meta("pressed_texture"), "Navigation selection must use its complete selected-state artwork.")
		else:
			_check(image == null or not image.visible, "Unselected tabs must use only the normal artwork embedded in the navigation bar.")
	_check(selected_home_count == 1, "Navigation must show exactly one selected tab.")

	scene.call("_switch_tab", "explore")
	for id in buttons:
		var nav_button := buttons[id] as Button
		_check(nav_button.size.is_equal_approx(expected_home_size), "Navigation hotspot changed size after switching pages.")
		var image := nav_button.get_node_or_null("ButtonImage") as TextureRect
		_check(image != null and image.visible == nav_button.button_pressed, "Only the active page may render selected navigation artwork.")
		if image != null:
			var expected_texture = nav_button.get_meta("pressed_texture") if id == "explore" else nav_button.get_meta("normal_texture")
			_check(image.texture == expected_texture, "Navigation highlight does not match the selected page.")
	var team_button := buttons.get("team") as Button
	var team_image := team_button.get_node_or_null("ButtonImage") as TextureRect
	scene.call("_on_image_button_hover_changed", team_button, true)
	_check(team_image != null and team_image.texture == team_button.get_meta("normal_texture"), "Hover must not use the selected navigation texture.")
	scene.call("_on_image_button_hover_changed", team_button, false)
	scene.call("_switch_tab", "camp")


func _verify_world_map(scene: Node) -> void:
	scene.call("_switch_tab", "explore")
	await process_frame
	await process_frame
	var canvas := scene.get("world_map_canvas") as Control
	var go_button := scene.get("world_map_go_button") as Button
	_check(canvas != null, "Target world map canvas was not created.")
	_check(go_button != null and go_button.size.is_equal_approx(Vector2(508, 88)), "Target location action hotspot is missing or misaligned.")
	if canvas == null:
		return
	var hotspot_count := 0
	for child in canvas.get_children():
		if child is Button and child.has_meta("world_site_id"):
			hotspot_count += 1
			_check((child as Button).get_theme_stylebox("normal") is StyleBoxEmpty, "Explore node hotspots must remain visually transparent over production artwork.")
	_check(hotspot_count == 5, "Target explore map must expose five location hotspots.")

	var sites: Array = scene.call("_get_target_explore_sites")
	if sites.size() > 1:
		var player = _player()
		var food_before := int(player.supplies.get("food", 0))
		scene.call("_select_world_site", sites[1])
		_check(int(player.supplies.get("food", 0)) == food_before, "Selecting a world site consumed food before confirmation.")
		_check(str((scene.get("selected_world_site") as Dictionary).get("id", "")) == str(sites[1].get("id", "")), "World site selection did not update detail state.")


func _verify_formation(scene: Node) -> void:
	scene.call("_switch_tab", "team")
	await process_frame
	_check(scene.find_child("TargetTeamRating", true, false) != null, "Target formation rating panel is missing.")
	var occupied_index := -1
	var player = _player()
	for i in range(player.formation_grid.size()):
		if player.get_grid_survivor(i) != "":
			occupied_index = i
			break
	if occupied_index < 0:
		return
	var survivor_id: String = str(player.get_grid_survivor(occupied_index))
	scene.set("selected_formation_survivor_id", "")
	scene.call("_on_grid_cell_pressed", occupied_index)
	_check(player.get_grid_survivor(occupied_index) == "", "Clicking an occupied formation cell did not remove the survivor.")
	var survivor_still_owned := false
	for survivor in player.survivors:
		if str(survivor.get("id", "")) == survivor_id:
			survivor_still_owned = true
			break
	_check(survivor_still_owned, "Removing a survivor from formation deleted the owned partner.")


func _verify_base(scene: Node) -> void:
	scene.call("_switch_tab", "base")
	await process_frame
	var composite_scroll := scene.find_child("BaseCompositeScroll", true, false) as ScrollContainer
	_check(composite_scroll != null, "Base composite scroll view is missing.")
	var facility_buttons: Dictionary = scene.get("base_facility_buttons")
	_check(facility_buttons.size() == 6, "Base composite must expose six facility hotspots.")
	for button_value in facility_buttons.values():
		var hotspot := button_value as Button
		_check(hotspot != null, "Base facility hotspot is not a Button control.")
		if hotspot != null:
			_check(hotspot.get_theme_stylebox("normal") is StyleBoxEmpty, "Base facility hotspot must remain visually transparent.")
	var bed_hotspot := facility_buttons.get("bed") as Button
	_check(bed_hotspot != null, "Bed facility hotspot is missing.")
	if bed_hotspot != null:
		bed_hotspot.pressed.emit()
		await process_frame
		var detail_panel := scene.find_child("BaseFacilityDetail", true, false) as PanelContainer
		_check(detail_panel != null and detail_panel.visible, "Facility hotspot did not open the detail panel.")
		var detail_label := detail_panel.find_child("BodyLabel", true, false) as Label if detail_panel != null else null
		_check(detail_label != null and "床铺" in detail_label.text, "Facility hotspot opened the wrong detail content.")
	var player = _player()
	player.materials["cores"] = 999
	player.materials["spirit_battery"] = 99
	var before_level: int = int(player.get_base_facility_level("bed"))
	if before_level >= player.base_level:
		return
	scene.set("base_selected_facility", {"id": "bed", "name": "床铺", "desc": "增加休息恢复量"})
	scene.call("_on_base_upgrade_pressed")
	_check(player.get_base_facility_level("bed") == before_level + 1, "Base facility upgrade did not persist in player state.")


func _verify_reincarnation(scene: Node) -> void:
	scene.call("_switch_tab", "reincarnation")
	await process_frame
	var button := scene.find_child("ReincarnateButton", true, false) as Button
	_check(button != null, "Reincarnation action button is missing.")
	if button == null:
		return
	var normal := button.get_theme_stylebox("normal") as StyleBoxTexture
	var hover := button.get_theme_stylebox("hover") as StyleBoxTexture
	var pressed := button.get_theme_stylebox("pressed") as StyleBoxTexture
	_check(normal != null and hover != null and pressed != null, "Reincarnation button state skins are incomplete.")
	if normal != null and hover != null and pressed != null:
		_check(normal.texture == hover.texture and normal.texture == pressed.texture, "Reincarnation button active states use mismatched visual bounds.")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _player():
	return root.get_node("GameState").get("player")
