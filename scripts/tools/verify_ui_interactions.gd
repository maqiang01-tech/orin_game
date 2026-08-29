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
	_check(zoom_container.size.x > scroll.size.x, "World map is still squeezed to viewport width.")

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
	var player = _player()
	player.materials["cores"] = 999
	player.materials["spirit_battery"] = 99
	var before_level: int = int(player.get_base_facility_level("bed"))
	if before_level >= player.base_level:
		return
	scene.set("base_selected_facility", {"id": "bed", "name": "床铺", "desc": "增加休息恢复量"})
	scene.call("_on_base_upgrade_pressed")
	_check(player.get_base_facility_level("bed") == before_level + 1, "Base facility upgrade did not persist in player state.")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _player():
	return root.get_node("GameState").get("player")
