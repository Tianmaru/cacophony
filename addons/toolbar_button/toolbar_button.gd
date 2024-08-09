tool
extends EditorPlugin

var button
var active_tool

func get_plugin_name() -> String:
	return "SpatialTool Plugin"

func _enter_tree():
	print("Plugin '%s' is active." % get_plugin_name())
	add_custom_type("SpatialTool", "Spatial", preload("spatial_tool.gd"), preload("SpatialTool.svg"))

func _exit_tree():
	print("exit")
	if button:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
		button.queue_free()
		button = null
	remove_custom_type("SpatialTool")

func button_clicked():
	active_tool.emit_signal("run")

func edit(object):
	active_tool = object

func make_visible(visible):
	if visible:
		button = Button.new()
		button.connect("button_down", self, "button_clicked")
		button.text = active_tool.button_text
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
	elif button:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
		button.queue_free()
		button = null

func handles(object) -> bool:
	if object is SpatialTool:
		return true
	return false
