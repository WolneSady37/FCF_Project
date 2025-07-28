## A popup showing an overview of [Building] effects
## (required stats to use and stats given on use).[br]
## Disappears after the player taps anywhere on the map.
class_name BuildingStatsPopup extends PanelContainer

@onready var _name_label := $VBoxContainer/NameLabel as Label
@onready var _stats_label := $VBoxContainer/StatsLabel as Label


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide()
		queue_free()


## Displays this popup.
func show_popup(building_name: String, building_stats: String, 
		pos: Vector2) -> void:
	_name_label.set_text(building_name)
	_stats_label.set_text(building_stats)
	self.global_position = pos
	
	show()
