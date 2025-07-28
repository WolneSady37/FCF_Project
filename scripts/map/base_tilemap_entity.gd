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

## An abstract class for entities moving on the tilemap.
class_name BaseTileMapEntity extends Area2D

## Tile size.
static var tile_size: Vector2i

## Tilemap position
var tilemap_position: Vector2i
## A [WeakRef] to [GameplayTileMap]
var tilemap_wref: WeakRef


## Abstract method, override in derived classes
func move(_next_tile: Vector2i) -> void:
	pass


## Returns tile coordinates of a [BaseTileMapEntity]'s current tilemap position.
func get_tilemap_position() -> Vector2i:
	return tilemap_position
