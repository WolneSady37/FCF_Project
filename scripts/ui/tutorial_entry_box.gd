class_name TutorialEntryBox extends VBoxContainer

@onready var _tutorial_image := $TextureRect as TextureRect
@onready var _tutorial_text := $RichTextLabel as RichTextLabel

func setup(entry: TutorialEntry) -> void:
	if entry == null:
		push_warning("TutorialEntry is null.")
		return
	
	_tutorial_text.set_text(entry.tutorial_text)
	_tutorial_image.set_texture(entry.tutorial_image)
