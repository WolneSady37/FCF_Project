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

## Main [Camera2D] controller.
class_name CameraController extends Camera2D

@export_group("Zoom")
## Amount of zoom applied to scale in one "step".
@export var zoom_speed := 0.05
## Minimum zoom scale.
@export var min_zoom := 0.2
## Maximum zoom scale.
@export var max_zoom := 2.0

# Node2D that the main camera will follow.
var _follow_target: Node2D


## Initializes this [CameraController].
func setup(_target: Node2D, _tilemap: GameplayTileMap, _zoom: Vector2) -> void:
	_follow_target = _target
	
	var map_rect: Rect2i = _tilemap.get_combined_bounds()
	var map_px_size: Vector2i = map_rect.size * GameplayTileMap.TILE_SIZE
	
	limit_left = map_rect.position.x * GameplayTileMap.TILE_SIZE.x
	limit_top = map_rect.position.y * GameplayTileMap.TILE_SIZE.y
	limit_right = limit_left + map_px_size.x
	limit_bottom = limit_top + map_px_size.y
	
	var new_zoom := _zoom
	new_zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)
	set_zoom(new_zoom)


func _process(_delta: float) -> void:
	if _follow_target:
		set_global_position(_follow_target.get_global_position())


func _input(_event: InputEvent) -> void:
	# Only for testing purposes - disable in release build
	if !OS.is_debug_build():
		return
	
	if Input.is_action_just_pressed(&"zoom_in"):
		var new_zoom := zoom + Vector2(0.1, 0.1)
		new_zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
		new_zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)
		set_zoom(new_zoom)
	if Input.is_action_just_pressed(&"zoom_out"):
		var new_zoom := zoom - Vector2(0.1, 0.1)
		new_zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
		new_zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)
		set_zoom(new_zoom)


func _unhandled_input(_event: InputEvent) -> void:
	var event := _event as InputEventMagnifyGesture
	if event:
		_handle_zoom(event.get_factor())


## Sets a target [Node2D] for the main [Camera2D] to follow.
func set_target(new_target: Node2D) -> void:
	_follow_target = new_target


func _handle_zoom(factor: float) -> void:
	if !is_instance_valid(get_viewport().get_camera_2d()):
		return
	
	var camera := get_viewport().get_camera_2d()
	var new_zoom := camera.zoom * (1.0 / factor)
	new_zoom.x = clampf(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clampf(new_zoom.y, min_zoom, max_zoom)
	camera.set_zoom(new_zoom)
