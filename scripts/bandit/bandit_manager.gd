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

## Manages all [Bandit]s present in the level.
class_name BanditManager extends Node2D

## An [Array] with all four cardinal directions.
const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
]

## Reference to [GameplayTileMap] present in this map.
@export var tilemap: GameplayTileMap

## Tiles picked by [Bandit]s to move to during their movement phase.
var reserved_tiles: Dictionary[Vector2i, Bandit] = {}
## Tiles occupied by buildings (or invalid otherwise)
var excluded_tiles: Array[Vector2i]
## An [Array] containing references to all [Bandit]s.
var bandits: Array[Bandit]


## Initializes the [BanditManager].
func initialize(_bandits: Array[Bandit]) -> void:
	assert(tilemap, "Tilemap reference not set.")
	
	CARDINAL_DIRECTIONS.make_read_only()
	self.bandits = _bandits
	
	for bandit: Bandit in _bandits:
		bandit.tile_requested.connect(request_tile)
		bandit.clear_requested.connect(
			func() -> void: 
				reserved_tiles.clear()
		)


## Reserves a tile at [param tile_pos] for a given [param bandit] movement, 
## to ensure only one [Bandit] can enter a given tile.
func request_tile(bandit: Bandit, tile_pos: Vector2i) -> bool:
	var valid_tiles: Array[Vector2i]
	for t: Vector2i in CARDINAL_DIRECTIONS:
		var tile := tile_pos + t
		if !excluded_tiles.has(tile) && tilemap.is_tile_passable(tile):
			valid_tiles.append(tile)
	
	valid_tiles.shuffle()
	for tile: Vector2i in valid_tiles:
		if !reserved_tiles.has(tile):
			reserved_tiles[tile] = bandit
			bandit.selected_tile = tile
			return true
	
	bandit.selected_tile = bandit.tilemap_position
	return false


## Adds a [param tile] to the excluded pool. 
## Excluded tiles will not be considered a valid target for [Bandit] movement.
func add_excluded_tile(tile: Vector2i) -> void:
	excluded_tiles.push_back(tile)
