extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	root.size = Vector2i(720, 1280)
	var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
	var scene := packed_scene.instantiate()
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
	var expected_size := Vector2(144, 96)
	for button in buttons.values():
		var nav_button := button as Button
		_check(nav_button.size.is_equal_approx(expected_size), "Bottom navigation button size changed from 144x96.")
		var rect := nav_button.get_global_rect()
		_check(rect.position.x >= 0.0 and rect.end.x <= 720.0, "Bottom navigation button exceeds the horizontal viewport.")
		_check(rect.position.y >= 1139.0 and rect.end.y <= 1280.0, "Bottom navigation button exceeds its safe area.")


func _verify_world_map(scene: Node) -> void:
	scene.call("_switch_tab", "explore")
	await process_frame
	await process_frame
	var scroll := scene.get("world_map_scroll") as ScrollContainer
	var zoom_container := scene.get("world_map_zoom_container") as Control
	_check(scroll != null and zoom_container != null, "World map scroll controls were not created.")
	if scroll == null or zoom_container == null:
		return
	_check(zoom_container.size.x <= scroll.size.x + 2.0 and zoom_container.size.y <= scroll.size.y + 2.0, "World map overview does not show the complete image.")
	scene.call("_on_world_map_immersive_pressed")
	await process_frame
	_check(zoom_container.size.x > scroll.size.x, "World map detail mode did not expand into a draggable canvas.")

	scroll.scroll_horizontal = 0
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(320, 300)
	scene.call("_on_world_map_input", press)
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(100, 300)
	motion.relative = Vector2(-220, 0)
	scene.call("_on_world_map_input", motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = Vector2(100, 300)
	scene.call("_on_world_map_input", release)
	_check(scroll.scroll_horizontal > 0, "World map mouse drag did not change horizontal scroll.")

	var sites: Array = scene.call("_get_region_world_sites")
	if sites.size() > 1:
		var player = _player()
		var food_before := int(player.supplies.get("food", 0))
		scene.call("_select_world_site", sites[1])
		_check(int(player.supplies.get("food", 0)) == food_before, "Selecting a world site consumed food before confirmation.")
		_check(str((scene.get("selected_world_site") as Dictionary).get("id", "")) == str(sites[1].get("id", "")), "World site selection did not update detail state.")


func _verify_formation(scene: Node) -> void:
	scene.call("_switch_tab", "team")
	await process_frame
	_check(scene.find_child("TeamRadar", true, false) != null, "Formation six-axis radar chart is missing.")
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
