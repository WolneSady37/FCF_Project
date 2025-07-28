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

## Base player entity.
## Can move around the map and interact with objects present in level.
class_name Player extends BaseTileMapEntity

## Emitted when player has finished moving.
@warning_ignore("unused_signal") # Used in GameplayTileMap
signal movement_finished

## Emitted when player's money has changed.
signal money_changed(money: int)
## Emitted when player's health has changed.
signal health_changed(health: int)
## Emitted when player's energy has changed.
signal energy_changed(energy: int)
## Emitted when player's education level has changed.
signal education_level_changed(education_level: int)
## Emitted when player's max health has changed.
signal max_health_changed(max_health: int)
## Emitted when player's max energy has changed.
signal max_energy_changed(max_energy: int)


const _INPUTS: Dictionary[StringName, Vector2i] = {
	&"move_right": Vector2i.RIGHT,
	&"move_left": Vector2i.LEFT,
	&"move_up": Vector2i.UP,
	&"move_down": Vector2i.DOWN
}

const _POPUP_LABEL := preload("uid://1rk7r8gthct4")

@export_group("Input")
## Swipe tolerance 
## How many units the input event must have to be considered a swipe.
@export var swipe_tolerance: int = 20
## Maximum delay between taps for them to be considered a double tap.
@export var double_tap_delay: float = 0.25

@export_group("Movement")
## Amount of Energy that will be consumed 
## when player double taps to skip their turn.
@export var skip_movement_energy_cost: int = 5

@export_group("Player Stats")
## Player money
@export var money: int = 35:
	set(value):
		var old_money := money
		money = maxi(0, value) # Money can't be negative
		_queue_popup(money - old_money, "money")
		money_changed.emit(money)

## Player health
## When health drops to 0, the game ends.
@export var health: int = 100:
	set(value):
		var old_health := health
		health = clampi(value, 0, max_health)
		_queue_popup(health - old_health, "health")
		health_changed.emit(health)

## Player energy
## When energy drops to 0, the day ends and a new one begins.
@export var energy: int = 100:
	set(value):
		var old_energy := energy
		energy = clampi(value, 0, max_energy)
		_queue_popup(energy - old_energy, "energy")
		energy_changed.emit(energy)


## Base health available for the player.
## Can change depending on the map.
@export var base_health: int = 100:
	set(value):
		base_health = value
		max_health = base_health + bonus_health
		max_health_changed.emit(max_health)

## Base energy available for the player.
## Can change depending on the map.
@export var base_energy: int = 100:
	set(value):
		base_energy = value
		max_energy = base_energy + bonus_energy
		max_energy_changed.emit(max_energy)


@export_group("Sounds")
## Sound played when the player moves.
## If empty, no sound will play.
@export var move_sound: AudioStreamOggVorbis
## Sound played when the player touches a [Bandit].
## If empty, no sound will play.
@export var bandit_collision_sound: AudioStreamOggVorbis


## Player education level.
var education_level: int = 0:
	set(value):
		education_level = value
		education_level_changed.emit(education_level)


## Bonus health. Permanently increases max energy for the game session.
var bonus_health: int:
	set(value):
		bonus_health = value
		max_health = base_health + bonus_health
		max_health_changed.emit(max_health)

## Bonus energy. Permanently increases max energy for the game session.
var bonus_energy: int:
	set(value):
		bonus_energy = value
		max_energy = base_energy + bonus_energy
		max_energy_changed.emit(max_energy)

## Total maximum health, including bonus health gained from upgrades.
var max_health: int = base_health + bonus_health

## Total maximum health, including bonus health gained from upgrades.
var max_energy: int = base_energy + bonus_energy

## Is the player currently moving?
var is_moving: bool = false
## Can the player move?
var can_move: bool = true
## Can the player interact with buildings?
## Set to false after teleporting, set to true after movement.
var can_interact: bool = false

var _swipe_handled: bool = false
var _last_tap_time: float = 0.0
var _popup_queue: Array[Dictionary] = []

@onready var _popup_timer := $PopupTimer as Timer


func _ready() -> void:
	_popup_timer.timeout.connect(_flush_popup_queue)


func _exit_tree() -> void:
	_popup_timer.timeout.disconnect(_flush_popup_queue)


# for PC - keyboard input
func _input(_event: InputEvent) -> void:
	if !can_move || is_moving:
		return
	
	for dir: StringName in _INPUTS.keys():
		if _event.is_action_pressed(dir):
			try_move(tilemap_position + _INPUTS[dir])


# for mobile - touch input (swipes)
func _unhandled_input(_event: InputEvent) -> void:
	if !can_move || is_moving:
		return
	
	if _event is InputEventScreenTouch and _event.is_pressed():
		var current_time := Time.get_ticks_msec() / 1000.0
		if current_time - _last_tap_time <= double_tap_delay:
			if !is_moving:
				can_interact = true
				energy -= skip_movement_energy_cost
				movement_finished.emit()
			
			_last_tap_time = 0.0
			_swipe_handled = true
			return
		
		else:
			_last_tap_time = current_time
			_swipe_handled = false
	
	if _event is InputEventScreenDrag && !_swipe_handled:
		var direction := _get_swipe_direction(
			(_event as InputEventScreenDrag).screen_relative)
		if direction != Vector2i.ZERO:
			try_move(tilemap_position + direction)
			_swipe_handled = true 


## Attempts to move the player to a tile of given coords.
func try_move(tile_pos: Vector2i) -> void:
	var tilemap := tilemap_wref.get_ref() as GameplayTileMap
	if tilemap == null:
		push_error("Player: Tilemap reference lost!")
		return
		
	if tilemap.is_tile_passable(tile_pos) && energy > 0:
		await move(tile_pos)


## Moves the player along provided path.
func move(_next_tile: Vector2i) -> void:
	if !can_move:
		return
	
	var tilemap := tilemap_wref.get_ref() as GameplayTileMap
	if tilemap == null:
		push_error("Player: Tilemap reference lost!")
		return
	
	is_moving = true
	
	var _previous_tile_pos = tilemap_position
	
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
	
	if move_sound:
		SoundHandler.play_sound(move_sound)
	
	await tween.finished
	tween.kill()
	
	var stat_component := tilemap.get_tile_stat_component(_next_tile)
	if stat_component != null:
		alter_stats(stat_component)
	
	tilemap_position = _next_tile
	
	# return player to previous position when out of bounds 
	# to avoid softlock
	if tilemap_position == Vector2i.ZERO:
		tilemap_position = _previous_tile_pos
	
	is_moving = false
	can_move = true
	can_interact = true
	movement_finished.emit()


## Teleports the player to a given tile coords
func teleport(tile_pos: Vector2i) -> void:
	var tilemap := tilemap_wref.get_ref() as GameplayTileMap
	if tilemap == null:
		push_error("Player: Tilemap reference lost!")
		return
	
	can_interact = false
	tilemap_position = tile_pos
	position = tilemap.map_to_local(tile_pos)


## Changes players stats by combining them with provided [StatComponent].
func alter_stats(sc: StatComponent) -> void:
	self.education_level += sc.education_level
	self.money += sc.money
	self.health += sc.health
	self.energy += sc.energy
	self.bonus_health += sc.bonus_health
	self.bonus_energy += sc.bonus_energy


## Forces UI update by re-emiting stat change signals.
func force_ui_refresh() -> void:
	money_changed.emit(money)
	health_changed.emit(health)
	energy_changed.emit(energy)
	max_health_changed.emit(max_health)
	max_energy_changed.emit(max_energy)


func _get_swipe_direction(relative: Vector2) -> Vector2i:
	if relative.length() < swipe_tolerance:
		return Vector2i.ZERO
	
	@warning_ignore_start("narrowing_conversion")
	if absi(relative.x) > absi(relative.y):
		return Vector2i(signi(relative.x), 0)
	
	return Vector2i(0, signi(relative.y))
	@warning_ignore_restore("narrowing_conversion")


func _queue_popup(value: int, msg: String) -> void:
	if value == 0:
		return
	
	_popup_queue.append({
		"value": value,
		"msg": msg
	})
	
	if _popup_timer && _popup_timer.is_stopped():
		_popup_timer.start()


func _flush_popup_queue() -> void:
	# Distance between labels
	var offset_step := Vector2(0, -50)
	for i: int in _popup_queue.size():
		var data: Dictionary = _popup_queue[i]
		var value: int = data.get("value", 0)
		
		if value == 0:
			continue
		
		var value_str := ("+" + str(value)) if value > 0 else str(value)
		var msg: String = value_str + " " + data.get("msg", "").to_upper()
		
		# Create label and offset it based on other labels
		var popup_label := _POPUP_LABEL.instantiate() as PopupLabel
		popup_label.position += get_position() + offset_step * i
		self.add_child(popup_label)
		popup_label.popup(msg, value > 0)
	
	_popup_queue.clear()


## Callback for entering tile occupied by a [Bandit].
func on_bandit_touched(bandit: Bandit) -> void:
	print("Bandit touched!")
	alter_stats(bandit.bandit_stats)
	if bandit_collision_sound:
		SoundHandler.play_sound(bandit_collision_sound)
