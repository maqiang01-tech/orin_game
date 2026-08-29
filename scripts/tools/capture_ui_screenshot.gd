extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var capture_size := Vector2i(720, 1280)
	if args.size() > 1 and str(args[1]) == "small":
		capture_size = Vector2i(360, 640)
	root.size = capture_size
	var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	if args.size() > 0 and scene.has_method("_switch_tab"):
		var requested_page := str(args[0])
		scene.call("_switch_tab", "team" if requested_page == "partners" else requested_page)
		await process_frame
		await process_frame
		if requested_page == "partners" and scene.has_method("_on_team_sub_tab_pressed"):
			scene.call("_on_team_sub_tab_pressed", "partners")
			await process_frame
	var image := root.get_texture().get_image()
	var page_id := str(args[0]) if args.size() > 0 else "camp"
	if capture_size.x == 360:
		page_id += "_small"
	image.save_png("res://tmp/ui_capture_%s.png" % page_id)
	quit()
