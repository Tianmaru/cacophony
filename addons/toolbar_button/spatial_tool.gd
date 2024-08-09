tool
class_name SpatialTool
extends Spatial

"""
Spatial Node that comes with a spatial menu button.
Whenever the button is clicked in the editor, it emits a 'run' signal.
Other tool scripts can connect to this signal to provide functionality in the editor.
For example, this node can be used to generate new procedural maps without leaving the editor.
"""

# emitted whenever the button in this node's spatial menu is pressed
signal run

# change the text of the spatial menu button
# The button itself is managed by the EditorPlugin Script
export(String) var button_text = "Click me!"
