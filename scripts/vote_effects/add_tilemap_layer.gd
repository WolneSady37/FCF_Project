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

## A [VoteEffect] that expands the [GameplayTileMap] by adding a new layer.
## Requires a [PackedScene] defining that extra layer for each [GameMap].
class_name AddTilemapLayer extends VoteEffect

@export var tilemap_layer_per_map: Array[PackedScene]

var _layer_instance: TileMapLayer = null


func execute(_context: GameplayManager) -> void:
	assert(_context, "Context for AddTilemapLayer cannot be null.")
	var _map := _context.get_map()
	if _layer_instance && _layer_instance.get_parent() == _map.get_tilemap():
		hide_preview(_map)
	
	if _layer_instance == null:
		_instantiate_tilemap(_context.get_map(), 1.0)


func show_preview(_map: GameMap):
	_instantiate_tilemap(_map, 0.6)


func hide_preview(_map: GameMap):
	if is_instance_valid(_layer_instance):
		_map.get_tilemap().remove_child(_layer_instance)
		_layer_instance.queue_free()
		_layer_instance = null


func _instantiate_tilemap(map: GameMap, alpha: float) -> void:
	var _tilemap_layer := tilemap_layer_per_map[map.map_id]
	assert(_tilemap_layer && _tilemap_layer.can_instantiate())
	
	_layer_instance = _tilemap_layer.instantiate()
	_layer_instance.modulate = Color(1.0, 1.0, 1.0, alpha)
	
	map.get_tilemap().add_child(_layer_instance)
