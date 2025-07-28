class_name EnterBuildingPopup extends PanelContainer


@onready var yes_button := $VBoxContainer/VBoxContainer/YesButton as Button
@onready var no_button := $VBoxContainer/VBoxContainer/NoButton as Button
@onready var building_label := $VBoxContainer/Label as Label


func setup(building_name: String, building_stats: String, 
		can_use: bool) -> void:
	var prompt_text := ("Enter %s?\n%s" % [building_name, building_stats])
	yes_button.set_disabled(!can_use)
	building_label.set_text(prompt_text)


func _on_button_pressed() -> void:
	self.hide()
