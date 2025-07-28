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

## A [VoteEffect] that removes a given number of [Bandit]s from the map.
class_name RemoveBanditsEffect extends VoteEffect

## Amount of [Bandit]s to remove.
@export var bandits_to_remove: int = 1

var _selected_bandits: Array[Bandit] = []
var _preview_color := Color(Color.BLUE, 0.5)
var _default_color := Color(Color.WHITE, 1.0)


func execute(_context: GameplayManager) -> void:
	assert(_context, "Context for RemoveBanditsEffect cannot be null.")
	if _selected_bandits.is_empty():
		_pick_bandits(_context.get_map())
	
	for bandit: Bandit in _selected_bandits:
		bandit.queue_free()
	
	_selected_bandits.clear()


func show_preview(_map: GameMap):
	if _selected_bandits.is_empty(): # Roll bandits only once
		_pick_bandits(_map)
	
	for bandit: Bandit in _selected_bandits:
		bandit.modulate = _preview_color


func hide_preview(_map: GameMap):
	for bandit: Bandit in _selected_bandits:
		bandit.modulate = _default_color


func _pick_bandits(_map: GameMap) -> void:
	var i: int = bandits_to_remove
	while i > 0:
		var bandits := _map.get_bandits()
		if bandits.is_empty():
			break
		
		var _bandit := bandits.pick_random() as Bandit
		assert(_bandit, "%s: not a Bandit" % _bandit.get_name())
		_selected_bandits.append(_bandit)
		i -= 1
