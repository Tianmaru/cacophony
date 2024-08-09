tool
extends PopupDialog

export(String) var title = "Warning" setget set_title
export(String, MULTILINE) var text = "Text" setget set_text
export(Array, String) var buttons = ["OK"] setget set_buttons
export(String) var confirmation_button = "OK"

signal confirmed
signal custom_action(action)

onready var title_label : Label = $VBoxContainer/Title
onready var text_label : RichTextLabel = $VBoxContainer/Text
onready var button_container = $VBoxContainer/ButtonContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	title_label.text = title
	text_label.bbcode_text = text
	update_buttons()

func _on_confirmation_button_up():
	emit_signal("confirmed")
	hide()

func _on_custom_button_up(button : String):
	print("button %s was pressed" % button)
	emit_signal("custom_action", button)

func set_title(value):
	title = value
	if title_label:
		title_label.text = title

func set_text(value):
	text = value
	if text_label:
		text_label.bbcode_text = text

func add_button(button_text : String):
	if not button_container:
		return
	var new_btn = Button.new()
	new_btn.text = button_text
	new_btn.name = button_text + "Button"
	print("adding button")
	if button_text == confirmation_button:
		new_btn.connect("button_up", self, "_on_confirmation_button_up", [], CONNECT_PERSIST)
	else:
		print("connected")
		new_btn.connect("button_up", self, "_on_custom_button_up", [button_text], CONNECT_PERSIST)
	button_container.add_child(new_btn)
	# button_container.move_child(ok_button, button_container.get_child_count() - 1)
	if Engine.editor_hint:
		new_btn.set_owner(get_tree().edited_scene_root)

func set_buttons(value):
	buttons = value
	if button_container:
		update_buttons()

func update_buttons():
	for btn in button_container.get_children():
		btn.queue_free()
	for btn in buttons:
		add_button(btn)

func _on_Text_meta_clicked(meta):
	OS.shell_open(str(meta))
