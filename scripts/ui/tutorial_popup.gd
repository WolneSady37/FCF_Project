## Displays a popup with tutorials.[br]
## Tutorials consist of text and an optional image 
## and are organized into [TutorialData] 
## that can hold any number of [TutorialEntry].
class_name TutorialPopup extends PanelContainer

## Emitted when this TutorialPopup is closed,
## either by skipping tutorial or reaching the final entry and proceeding.
signal tutorial_closed

const ENTRY_BOX := \
		preload("res://scenes/ui/tutorial_entry_box.tscn") as PackedScene

var _current_index: int = 0

## Reference to main tutorial entry container.
@onready var entries_container := %TutorialEntryContainer as Container

@onready var _back_button := %BackButton as Button
@onready var _next_button := %NextButton as Button
@onready var _skip_button := %SkipButton as Button
@onready var _title_label := %TitleLabel as Label


func _ready() -> void:
	assert(ENTRY_BOX.can_instantiate())
	_back_button.pressed.connect(_on_back_pressed)
	_next_button.pressed.connect(_on_next_pressed)
	_skip_button.pressed.connect(_on_skip_pressed)
	_update_tutorial()


func _exit_tree() -> void:
	_back_button.pressed.disconnect(_on_back_pressed)
	_next_button.pressed.disconnect(_on_next_pressed)
	_skip_button.pressed.disconnect(_on_skip_pressed)


## Initializes the popup with [TutorialData].
## If [TutorialData] contains no entries, raises a warning and hides the popup.
func setup_tutorial(tutorial_data: TutorialData):
	if tutorial_data.tutorial_entries.is_empty():
		push_warning("No tutorial entries detected.")
		hide()
		return
	
	_current_index = 0
	_title_label.set_text(tutorial_data.tutorial_title.to_upper())
	for entry in tutorial_data.tutorial_entries:
		var _entry_box := ENTRY_BOX.instantiate() as TutorialEntryBox
		entries_container.add_child(_entry_box)
		_entry_box.setup(entry)
		_entry_box.hide()
	
	show()
	_back_button.set_disabled(true)
	_update_tutorial()


func _update_tutorial() -> void:
	for i: int in entries_container.get_child_count():
		var entry := entries_container.get_child(i)
		entry.set_visible(i == _current_index)


func _on_back_pressed() -> void:
	if _current_index > 0:
		_next_button.set_text("Next")
		_current_index -= 1
		_update_tutorial()
	
	if _current_index == 0:
		_back_button.set_disabled(true)


func _on_next_pressed() -> void:
	if _current_index < entries_container.get_child_count() - 1:
		_back_button.set_disabled(false)
		_current_index += 1
		_update_tutorial()
	else:
		_on_skip_pressed()
	
	if _current_index == entries_container.get_child_count() - 1:
		_next_button.set_text("OK")


func _on_skip_pressed() -> void:
	for entry in entries_container.get_children():
		entry.queue_free()
	
	tutorial_closed.emit()
	hide()
