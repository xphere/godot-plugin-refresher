@tool
extends HBoxContainer

signal request_refresh_plugin(p_name)
signal confirm_refresh_plugin(p_name)

@onready var options = $OptionButton

var icon: Texture2D


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	# This is the scene opened in the editor!
	$RefreshButton.icon = icon


func update_items(p_plugins: Dictionary) -> void:
	if not options:
		return
	
	options.clear()
	var plugin_dirs : Array = p_plugins.keys()
	for idx in plugin_dirs.size():
		var plugin_dirname : String = plugin_dirs[idx]
		var plugin_name : String = p_plugins[plugin_dirname]
		options.add_item(plugin_name, idx)
		options.set_item_metadata(idx, plugin_dirname)


func select_plugin(p_name: String) -> void:
	if not options:
		return
	
	if p_name.is_empty():
		return
	
	for idx in options.get_item_count():
		var plugin : String = options.get_item_metadata(idx)
		if plugin == p_name:
			options.selected = options.get_item_id(idx)
			break


func _on_RefreshButton_pressed() -> void:
	if options.selected == -1:
		return # nothing selected

	var plugin : String = options.get_item_metadata(options.selected)
	if plugin.is_empty():
		return
	
	request_refresh_plugin.emit(plugin)


func show_warning(p_name: String) -> void:
	$ConfirmationDialog.dialog_text = """
		Plugin `%s` is currently disabled.\n
		Do you want to enable it now?
	""" % [p_name]
	$ConfirmationDialog.popup_centered()


func _on_ConfirmationDialog_confirmed() -> void:
	var plugin : String = options.get_item_metadata(options.selected)
	confirm_refresh_plugin.emit(plugin)
