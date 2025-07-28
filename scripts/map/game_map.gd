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

## Defines a game level.
## Consists of a [GameplayTileMap] that makes up the level layout,
## a [Player] and any number of [Bandit]s that roam the map.
class_name GameMap extends Node2D

@export_group("General Settings")
## ID of the map.
@export var map_id: int = -1
## Background music that plays on this map.
@export var map_music: AudioStreamOggVorbis

@export_group("Gameplay Data")
## Vote schedule.
## Associates [VotePool]s with in-game days.
@export var vote_schedule: Dictionary[int, VotePool] = {}
## Tutorial data for this map.
## Can be left null for no tutorial.
@export var tutorial_data: TutorialData

@export_group("Stats")
## Amount of stats that will be restored on daily reset.
@export var stats_daily_reset: StatComponent
## Starting health
@export var starting_health: int = 100
## Starting energy
@export var starting_energy: int = 100
## Multiplier for player's money when starting this map.
@export var money_multiplier: float = 1.0

@export_group("Win & Lose Conditions")
## Day on which new map will be loaded
## (or game ends in victory if no [member next_map] is defined.
@export var final_day: int = -1
## When enabled, the player can get a game over on this map.
@export var can_lose: bool = true
## Required education level to trigger special bank event.
@export var required_education_level: int = 5

@export_group("Next Map")
## A [PackedScene] containing the next map.
@export var next_map: PackedScene

var _building_tiles: Dictionary[Vector2i, Building] = {}
var _bandits_count: int = 0

## Reference to [Player] present in this map.
@onready var player := $Player as Player
## Reference to [GameplayTileMap] of this map.
@onready var tilemap := $GameplayTileMap as GameplayTileMap
## Reference to [BanditManager].
@onready var bandits := $Bandits as BanditManager

func _ready() -> void:
	assert(map_id >= 0, "Incorrect map ID.")
	assert(player, 
			"Player not found! Check if map '%s' contains the player scene." % \
			self.name)
	assert(tilemap, "Tilemap not found!")
	
	player.base_energy = starting_energy
	player.base_health = starting_health
	
	player.movement_finished.connect(on_player_movement_finished)
	SignalBus.building_registered.connect(_on_building_registered)
	
	# Initialize bandit manager and tilemap with correct bandit references.
	var _bandits := get_bandits()
	bandits.initialize(_bandits)
	tilemap.initialize(_bandits)
	
	# Let bandits telegraph their first move.
	move_bandits()

	if map_music:
		SoundHandler.play_music(map_music)


func _exit_tree() -> void:
	SignalBus.building_registered.disconnect(_on_building_registered)
	if player.movement_finished.is_connected(move_bandits):
		player.movement_finished.disconnect(move_bandits)


## Callback for when an in-game day ends.
func on_next_day(day: int) -> void:
	player.teleport(tilemap.house_tile_position)
	toggle_vote_popup(day + 1)


## Toggles "VOTE" popup over schools depending on next day in vote schedule.
func toggle_vote_popup(next_day: int) -> void:
	var _schools := get_tree().get_nodes_in_group(&"school")
	for s in _schools:
		var _is_next_day_vote_day: bool = is_vote_day(next_day)
		s.toggle_vote_popup(_is_next_day_vote_day)


## Callback for [signal Player.movement_finished] signal.
func on_player_movement_finished() -> void:
	# While bandits move AFTER the player, 
	# the encounter is checked AFTER bandits move,
	# so the player can still dodge them when they move.
	move_bandits()
	
	# Check if the player has entered a building.
	if player.get_tilemap_position() in _building_tiles.keys():
		var _building = _building_tiles[player.get_tilemap_position()]
		if player.can_interact:
			print("%s entered!" % _building.name)
			var _can_use_building: bool = _building.check_player_stats(player)
			SignalBus.building_entered.emit(_building, _can_use_building)


## Returns an [Array] containing all [Bandit] nodes.
func get_bandits() -> Array[Bandit]:
	var _bandits: Array[Bandit] = []
	for b in bandits.get_children():
		var _bandit := b as Bandit
		if _bandit == null:
			push_warning(
				"Node '%s' was added to Bandits node, but is not a Bandit." % \
				b.name)
			continue
		
		_bandits.push_back(_bandit)
	
	return _bandits


## Returns a reference to [GameplayTileMap] present in this map.
func get_tilemap() -> GameplayTileMap:
	return tilemap


## Attempts to move all bandits on map.[br]
## This does not instantly move them, instead it causes all bandits
## to pick a tile on odd turns, then move to that tile on even turns.
func move_bandits() -> void:
	for _bandit: Bandit in get_bandits():
		if !_bandit.turn_finished.is_connected(_on_bandit_turn_finished):
			_bandit.turn_finished.connect(_on_bandit_turn_finished, 
					CONNECT_ONE_SHOT)
		
		_bandits_count += 1
		_bandit.take_turn()


## Reset all bandits position to the initial one.
func reset_bandits() -> void:
	for _bandit: Bandit in get_bandits():
		_bandit.reset_position()


## Returns true if voting happens on given day.
func is_vote_day(day: int) -> bool:
	return vote_schedule.keys().has(day)


func _on_bandit_turn_finished() -> void:
	_bandits_count -= 1
	if _bandits_count == 0:
		_check_bandit_encounter()


func _check_bandit_encounter() -> void:
	for b in bandits.get_children():
		var _bandit := b as Bandit
		if _bandit == null:
			push_warning(
				"Node '%s' was added to Bandits node, but is not a Bandit." % \
				b.name)
			continue
		
		if player.get_tilemap_position() == _bandit.get_tilemap_position():
			player.on_bandit_touched(_bandit)


func _on_building_registered(building: Building) -> void:
	var building_tilemap_pos := Vector2i(
		building.position / Vector2(tilemap.TILE_SIZE) * tilemap.scale
	)
	_building_tiles[building_tilemap_pos] = building
	bandits.add_excluded_tile(building_tilemap_pos)
