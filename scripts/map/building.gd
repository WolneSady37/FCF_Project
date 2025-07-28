# Copyright 2025 Absynth Studio & Free Courts Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Base class for all Buildings that can exist on a map.
class_name Building extends Area2D

const STATS_POPUP_SCENE: PackedScene = preload("uid://cc8heywcrg2ha")

## [StatComponent] that defines stat changes 
## when interacting with this [Building].
@export var building_stats: StatComponent:
	set(value):
		building_stats = value.duplicate() as StatComponent if value else null

## Should interacting with this [Building] end the current day?
@export var should_end_day: bool = false
## Should interacting with this [Building] start the voting process?
@export var should_start_vote: bool = false
## Should interacting with this [Building] fully reset player stats to maximum?
@export var fully_reset_stats: bool = false

@export_group("Sounds")
## Sound played on interaction with this [Building].
## If empty, no sound will play.
@export var use_sound: AudioStreamOggVorbis


func _ready() -> void:
	assert(building_stats, 
		"Building '%s' is missing StatComponent. Assign one via Inspector." % \
		self.get_name())
	
	add_to_group(&"buildings", true)
	var _group: StringName = get_name().to_snake_case()
	if !is_in_group(_group):
		add_to_group(_group, true)
	
	input_event.connect(_on_input_event)
	SignalBus.building_registered.emit(self)


func _exit_tree() -> void:
	SignalBus.building_unregistered.emit(self)
	if area_entered.is_connected(_on_entered):
		area_entered.disconnect(_on_entered)


## Use this [Building], triggering its effects
## (e.g. applying [StatComponent] changes, starting vote, ending the day...)
func use_building(player: Player) -> void:
	if !check_player_stats(player):
		print("Cannot use building: Insufficient stats.")
		return
	
	if use_sound:
		SoundHandler.play_sound(use_sound)
	
	player.alter_stats(building_stats)
	SignalBus.building_used.emit(self)
	if should_start_vote:
		SignalBus.vote_start_requested.emit()
	if should_end_day:
		SignalBus.end_day_requested.emit()


## Returns [code]true[/code] if player has enough stats to use this [Building].
func check_player_stats(player: Player) -> bool:
	if building_stats.energy < 0 && player.energy < absi(building_stats.energy):
		return false
	if building_stats.money < 0 && player.money < absi(building_stats.money):
		return false
	if building_stats.health < 0 && player.health < absi(building_stats.health):
		return false
	
	return true


## @deprecated
func _on_entered(_other: Node2D) -> void:
	push_warning("This method is deprecated")
	return


func _on_input_event(_viewport: Node, 
		_event: InputEvent, _shape_idx: int) -> void:
	var event := _event as InputEventMouseButton
	if event == null:
		return
	
	if event.pressed:
		var _popup := STATS_POPUP_SCENE.instantiate() as BuildingStatsPopup
		if _popup:
			add_child(_popup)
			_popup.show_popup(
				self.get_name(), 
				building_stats.to_string(), 
				self.get_global_position()
			)
