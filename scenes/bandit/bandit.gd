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

@tool # needed to update sprites in editor dynamically
class_name Bandit extends BaseTileMapEntity

## Emitted when this Bandit requests a valid tile selection to move to.
@warning_ignore("unused_signal")
signal tile_requested(bandit: Bandit, current_tile: Vector2i)
## Emitted after this Bandit finishes moving.
@warning_ignore("unused_signal")
signal clear_requested
## Emitted after this Bandit has taken their turn.
signal turn_finished

@export var bandit_sprite: Texture2D = preload("uid://gh770gcr1xvf"):
	set(value):
		bandit_sprite = value
		if is_inside_tree():
			$Sprite2D.set_texture(bandit_sprite)

# duplicate() required or else something crashes on second bandit touch
@export var bandit_stats := preload("uid://pptddp22jgt8").duplicate() \
		as StatComponent:
	set(value):
		bandit_stats = value.duplicate() as StatComponent if value else null

## When set to true, this [Bandit] is no longer visible 
## and cannot interact with the [Player] anymore.
var disabled: bool = false
## The tile this [Bandit] will move to on their next turn.
var selected_tile: Vector2i

## Position to reset the bandit to on daily reset
var _initial_tilemap_position: Vector2i

## Reference to [StateMachine] responsible for movement.
@onready var state_machine := $MovementStateMachine as StateMachine


func _ready() -> void:
	if !Engine.is_editor_hint():
		return
	
	assert(bandit_stats, 
		"Bandit '%s' is missing StatComponent. Assing it via Inspector." % \
		self.name)
	
	if disabled:
		_set_active(false)
		return


## Attempts to move this [Bandit] to a valid nearby tile.
func move(_next_tile: Vector2i = Vector2i.ZERO) -> void:
	var tilemap := tilemap_wref.get_ref() as GameplayTileMap
	if tilemap == null:
		push_error("%s: Tilemap reference lost!" % self.name)
		return
	
	var tween := get_tree().create_tween()
	tween.tween_property(
		self,
		^"position",
		tilemap.map_to_local(_next_tile),
		tilemap.movement_duration
	)\
	.from_current()\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	tween.kill()
	
	tilemap_position = _next_tile


func take_turn() -> void:
	if state_machine.current_state.get_name() == &"Idle":
		tile_requested.emit(self, tilemap_position)
		state_machine.transition_to(^"BeforeMove",
			{&"selected_tile": selected_tile}
		)
	elif state_machine.current_state.get_name() == &"BeforeMove":
		state_machine.transition_to(^"Moving",
			{&"selected_tile": selected_tile}
		)


## Resets this [Bandit]'s position to their initial position.
func reset_position() -> void:
	state_machine.transition_to(^"Idle")
	
	var tilemap := tilemap_wref.get_ref() as GameplayTileMap
	if tilemap == null:
		push_error("%s: Tilemap reference lost!" % self.name)
		return
	
	tilemap_position = _initial_tilemap_position
	set_position(tilemap.map_to_local(tilemap_position))
	
	# Telegraph next move
	if state_machine.current_state.get_name() == &"Idle":
		take_turn()
	
	turn_finished.emit()


## Forces initial tilemap position to current position.
func refresh_initial_position() -> void:
	_initial_tilemap_position = tilemap_position


#region quick and dirty hack for "group call method" command
func enable() -> void:
	disabled = false
	_set_active(true)


func disable() -> void:
	_set_active(false)
	disabled = true
#endregion


func _set_active(new_state: bool) -> void:
	if new_state:
		set_deferred(&"process_mode", Node.PROCESS_MODE_INHERIT)
		self.show()
	else:
		self.hide()
		set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)
