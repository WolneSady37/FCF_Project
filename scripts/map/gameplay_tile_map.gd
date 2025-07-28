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

## A container for [TileMapLayer]s that make up the game map.
class_name GameplayTileMap extends Node2D

## The size of tile used in tilemap
const TILE_SIZE := Vector2i(256, 256)

## Duration (in seconds) for player to move one tile
@export var movement_duration: float
## The tile position of the house.
## Used to determine where to teleport player on day end.
@export var house_tile_position: Vector2i

@export_group("Bus Stops")
## Contains a list of destination tile coordinates 
## for bus stops present in this map.
@export var destination_tile_coords_list: Array[Vector2i]

@export_group("Node References")
@export var _tilemap: TileMapLayer
@export var _player: Player

var _bus_stops_count: int


## Initializes the tile map and all [BaseTileMapEntity] present in this map.
func initialize(bandits: Array[Bandit]) -> void:
	assert(_tilemap)
	assert(_player)
	
	BaseTileMapEntity.tile_size = TILE_SIZE
	
	_player.tilemap_wref = weakref(self)
	_player.tilemap_position = Vector2i(
		(_player.position - self.position) / (Vector2(TILE_SIZE) * self.scale)
	)
	
	for bandit: Bandit in bandits:
		bandit.tilemap_wref = weakref(self)
		bandit.tilemap_position = Vector2i(
				(bandit.position - self.position) / 
				(Vector2(TILE_SIZE) * self.scale)
		)
		
		bandit.refresh_initial_position()
	
	_bus_stops_count = 0
	SignalBus.building_registered.connect(_on_building_registered)
	SignalBus.building_unregistered.connect(_on_building_unregistered)


## Wrapper method for [method TileMapLayer.map_to_local]
func map_to_local(tile_pos: Vector2i):
	return _tilemap.map_to_local(tile_pos)


## Returns [code]true[/code] if a tile can be walked over.
func is_tile_passable(tile_pos: Vector2i) -> bool:
	var tile_data := _get_tile_data(tile_pos)
	if tile_data == null || !tile_data.has_custom_data("unpassable"):
		return false
	
	return not bool(tile_data.get_custom_data("unpassable"))


## Returns a [StatComponent] associated with tile at [param tile_pos].
func get_tile_stat_component(tile_pos: Vector2i) -> StatComponent:
	var tile_data := _get_tile_data(tile_pos)
	if tile_data == null || !tile_data.has_custom_data("stat_component"):
		return null
	
	var sc: Object = tile_data.get_custom_data("stat_component")
	return sc as StatComponent # can return null


## Returns a [Rect2i] that contains total bounds of an entire tile map.
func get_combined_bounds() -> Rect2i:
	var combined_bounds := Rect2i()
	for c in get_children():
		var layer := c as TileMapLayer
		if layer == null:
			continue
		
		combined_bounds = combined_bounds.merge(layer.get_used_rect())
	
	return combined_bounds


func _get_tile_data(tile_pos: Vector2i, 
		index: int = get_child_count() - 1) -> TileData:
	
	# Check if tile is inside bounds
	var bounds := get_combined_bounds()
	if !bounds.has_point(tile_pos):
		return null
	
	# Get the corresponding tilemap layer
	var _tml := get_child(index) as TileMapLayer
	if _tml != null:
		var cell_tile_data: TileData = _tml.get_cell_tile_data(tile_pos)
		if cell_tile_data != null:
			return cell_tile_data
	
	# Recursively check next layer for valid tiles
	if index > 0:
		return _get_tile_data(tile_pos, index - 1)
	
	# Return null if no layer has valid tiles
	return null


func _on_building_registered(building: Building) -> void:
	var bus_stop := building as BusStop
	if bus_stop:
		assert(destination_tile_coords_list.size() > _bus_stops_count,
				"Destination for bus stop at index %s does not exist." % \
				_bus_stops_count)
		bus_stop.destination_tilemap_position = \
				destination_tile_coords_list[_bus_stops_count]
		_bus_stops_count += 1


func _on_building_unregistered(building: Building) -> void:
	var bus_stop := building as BusStop
	if bus_stop:
		_bus_stops_count -= 1
