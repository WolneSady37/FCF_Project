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

extends State

var _bandit: Bandit
var _selected_tile: Vector2i
var _ghost := Sprite2D.new()


func initialize(state_machine: StateMachine) -> void:
	super(state_machine)
	_bandit = target as Bandit
	assert(_bandit, "Target node '%s' is not a Bandit" % target.name)
	_bandit.add_child(_ghost)


func enter(_args: Dictionary = {}) -> void:
	_selected_tile = _args.get(&"selected_tile", Vector2i.ZERO)
	
	var _btilemap := _bandit.tilemap_wref.get_ref() as GameplayTileMap
	if _btilemap == null:
		push_error("%s: Tilemap reference lost!" % _bandit.name)
		return
	
	if _ghost != null:
		_ghost.set_position(_btilemap.to_global(
			_btilemap.map_to_local(_selected_tile))
		)
		_ghost.set_texture(_bandit.bandit_sprite)
		_ghost.set_self_modulate(Color(Color.RED, 0.6))
		_ghost.set_as_top_level(true)
		_ghost.set_z_index(2)
		_ghost.show()
	
	# Wait one frame before finishing turn
	# to defer check until after all bandits had taken their turn
	await get_tree().process_frame
	_bandit.turn_finished.emit()


func exit():
	_ghost.hide()
