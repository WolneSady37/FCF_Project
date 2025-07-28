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

## Main gameplay loop manager.
class_name GameplayManager extends Node

## Emitted after player selects a vote option
## and voting UI has finished cleanup.
signal vote_finished

## This map will be loaded on game start.
@export var first_map: PackedScene = \
		preload("res://scenes/maps/school_map.tscn")

## Default camera zoom
@export var default_camera_zoom := Vector2(0.4, 0.4)

@export_group("Node References")
@export var _ui: GameplayUI
@export var _camera: CameraController

## Current day.
var current_day: int = 1
## Reference to last touched building.
## Used to defer interaction until player finishes moving.
var last_touched_building: Building = null
## An [Array] for selected votes to reapply their effects on map change.
var selected_votes: Array[VoteData] = []

## Whether a vote should start on next day or not.
var should_start_vote: bool = false

# Reference to current VotePool
var _cached_vote_pool_ref: VotePool = null

# A guard to prevent ending the day twice in edge cases.
var _day_ended: bool = false

# Reference to current Player.
var _player: Player
# Reference to current Map.
var _map: GameMap

# Reference to map 'container'
@onready var _map_container := $MapContainer as Node2D


func _ready() -> void:
	assert(first_map, "Starting map not set. Cannot start game.")
	assert(_camera)
	
	_ui.game_started.connect(start_game)
	_camera.make_current()


func _unhandled_input(_event: InputEvent) -> void:
	if OS.is_debug_build():
		if Input.is_action_pressed(&"debug_change_map"):
			change_map(preload("res://scenes/maps/university_map.tscn"))


## Instantiates first map and begins the game.
func start_game() -> void:
	current_day = 1
	await change_map(first_map)
	_connect_ui_signals()
	
	_ui._on_education_level_changed(0) # quick hack to hide edulevel counter
	
	SignalBus.building_entered.connect(_on_building_entered)
	SignalBus.vote_start_requested.connect(_begin_vote)
	SignalBus.end_day_requested.connect(end_day)
	SignalBus.house_bought.connect(
		_game_over.bind(GameOverPopup.EGameOverReason.HOUSE_BOUGHT)
	)
	
	_refresh_ui()


## Activates the effect of last touched building.
func enter_building() -> void:
	last_touched_building.use_building(_player)
	last_touched_building = null
	_enable_player_movement()
	_map.move_bandits()


## Ends day, restoring energy.
func end_day() -> void:
	if _day_ended:
		return
	
	print("Day ended!")
	_day_ended = true
	_player.can_move = false
	
	await get_tree().create_timer(1.0).timeout
	
	_player.money += _map.stats_daily_reset.money
	_player.health += _map.stats_daily_reset.health
	_player.energy += _player.max_energy
	
	if _player.money == 0 && _map.can_lose:
		_game_over(GameOverPopup.EGameOverReason.NO_MONEY)
		return
	
	current_day += 1
	_ui.day_counter.set_text(str(current_day))
	_map.on_next_day(current_day)
	_map.reset_bandits()
	
	# Wait for voting to finish.
	if _map.vote_schedule.has(current_day) && should_start_vote:
		start_vote(_map.vote_schedule.get(current_day))
		await vote_finished
		should_start_vote = false
	
	# Move to next map or end game on final day.
	if current_day == _map.final_day:
		if _map.next_map:
			change_map(_map.next_map)
		else:
			_game_over(GameOverPopup.EGameOverReason.FINAL_DAY)
	
	_player.can_move = true
	_day_ended = false


## Starts the voting process.
## Randomly selects options from pool and initializes voting UI.
func start_vote(vote_pool: VotePool) -> void:
	_cached_vote_pool_ref = vote_pool
	var votes := vote_pool.get_random_choices()
	
	_ui.voting_panel.card_swiped.connect(_handle_preview)
	_ui.show_voting_panel(votes)
	
	for c in _ui.voting_panel.main_container.get_children():
		var _card := c as VoteCard
		if _card != null:
			_card.voted.connect(_handle_vote)


## Changes the current map to provided one.
func change_map(new_map: PackedScene, preserve_player: bool = true) -> void:
	assert(new_map.can_instantiate(), "Cannot create a map instance!")
	
	# Save player data
	var _is_player_valid := is_instance_valid(_player)
	if _is_player_valid:
		_disconnect_player_signals()
	
	var _player_data: PlayerData = _save_player_data() \
			if _is_player_valid && preserve_player else null
	
	# Clear previous map
	if is_instance_valid(_map):
		_map.queue_free()
	
	# Add new map
	_map = new_map.instantiate()
	_map.request_ready()
	_map_container.add_child(_map)
	_map_container.move_child(_map, 0)
	
	# Update player and reconnect signals
	_player = _map.player
	if _player_data && preserve_player:
		@warning_ignore("narrowing_conversion")
		_player_data.money *= _map.money_multiplier
		_player_data.base_health = _map.starting_health
		_player_data.base_energy = _map.starting_energy
		_load_player_data(_player_data)
	
	_connect_player_signals()
	_player.force_ui_refresh()
	_ui.toggle_main_menu(false)
	_camera.setup(_player, _map.tilemap, default_camera_zoom)
	
	# Delay execution until map is ready
	await _wait_for_map()
	
	# Show map tutorial
	show_tutorial(_map.tutorial_data)
	
	# Apply vote effects
	print(_map.get_name())
	if !selected_votes.is_empty():
		for vd: VoteData in selected_votes:
			for ve: VoteEffect in vd.vote_effects:
				ve.execute(self)


## Returns a reference to currently active [Player] instance.
func get_player() -> Player:
	return _player


## Returns a reference to currently active [GameMap] instance.
func get_map() -> GameMap:
	return _map


## Displays a tutorial popup for provided [TutorialData].
func show_tutorial(tutorial_data: TutorialData) -> void:
	_player.can_move = false
	_ui.show_tutorial_popup(tutorial_data)


func _wait_for_map() -> void:
	while !_map.is_node_ready():
		await get_tree().process_frame


func _handle_preview(old_data: VoteData, new_data: VoteData) -> void:
	for ve: VoteEffect in old_data.vote_effects:
		ve.hide_preview(_map)
	
	for ve: VoteEffect in new_data.vote_effects:
		ve.show_preview(_map)


func _handle_vote(vote: VoteData) -> void:
	_ui.voting_panel.card_swiped.disconnect(_handle_preview)
	
	if vote.vote_effects.is_empty():
		push_warning("Selected vote has no effects set.")
		return
	
	for ve in vote.vote_effects:
		ve.execute(self)
	
	selected_votes.push_back(vote)
	_cached_vote_pool_ref.options.erase(vote)
	_cached_vote_pool_ref = null
	
	for c in _ui.voting_panel.main_container.get_children():
		var _card := c as VoteCard
		if _card != null && _card.voted.is_connected(_handle_vote):
			_card.voted.disconnect(_handle_vote)
	
	vote_finished.emit()
	_ui.hide_voting_panel()


#region PLAYER DATA PERSISTENCE
func _save_player_data() -> PlayerData:
	var pd := PlayerData.new()
	pd.money = _player.money
	pd.base_health = _player.base_health
	pd.base_energy = _player.base_energy
	pd.bonus_health = _player.bonus_health
	pd.bonus_energy = _player.bonus_energy
	return pd


func _load_player_data(pd: PlayerData) -> void:
	if pd == null:
		push_warning("No valid PlayerData provided.")
		return
	
	_player.money = pd.money
	_player.base_health = pd.base_health
	_player.base_energy = pd.base_energy
	_player.bonus_health = pd.bonus_health
	_player.bonus_energy = pd.bonus_energy
	_player.health = pd.base_health + pd.bonus_health
	_player.energy = pd.base_energy + pd.bonus_energy
#endregion


func _connect_player_signals() -> void:
	_player.money_changed.connect(_ui._on_money_changed)
	_player.health_changed.connect(self._on_health_changed)
	_player.health_changed.connect(_ui._on_health_changed)
	_player.max_health_changed.connect(_ui._on_max_health_changed)
	_player.energy_changed.connect(self._on_energy_changed)
	_player.energy_changed.connect(_ui._on_energy_changed)
	_player.max_energy_changed.connect(_ui._on_max_energy_changed)
	_player.education_level_changed.connect(self._on_education_level_changed)
	_player.education_level_changed.connect(_ui._on_education_level_changed)
	


func _disconnect_player_signals() -> void:
	_player.money_changed.disconnect(_ui._on_money_changed)
	_player.health_changed.disconnect(self._on_health_changed)
	_player.health_changed.disconnect(_ui._on_health_changed)
	_player.max_health_changed.disconnect(_ui._on_max_health_changed)
	_player.energy_changed.disconnect(self._on_energy_changed)
	_player.energy_changed.disconnect(_ui._on_energy_changed)
	_player.max_energy_changed.disconnect(_ui._on_max_energy_changed)
	_player.education_level_changed.disconnect(_ui._on_education_level_changed)


func _begin_vote() -> void:
	should_start_vote = true


func _connect_ui_signals() -> void:
	_ui.building_enter_requested.connect(enter_building)
	_ui.building_enter_cancelled.connect(_enable_player_movement)
	_ui.restart_requested.connect(_restart_game)
	_ui.game_ended.connect(_back_to_main_menu)
	_ui.tutorial_popup.tutorial_closed.connect(_on_tutorial_closed)


func _on_tutorial_closed() -> void:
	_map.toggle_vote_popup(current_day + 1)
	_enable_player_movement()


func _enable_player_movement() -> void:
	_player.can_move = true


func _refresh_ui() -> void:
	_ui.money_counter.set_text(str(_player.money))
	_ui.health_counter.set_text(str(_player.health))
	_ui.energy_counter.set_text(str(_player.energy))
	_ui.day_counter.set_text(str(current_day))


func _game_over(reason: GameOverPopup.EGameOverReason) -> void:
	_player.set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)
	_player.hide()
	_ui.show_game_over_prompt(reason)


func _restart_game():
	selected_votes.clear()
	current_day = 1
	change_map(preload("res://scenes/maps/school_map.tscn"), false)


func _back_to_main_menu():
	_map.queue_free()
	SoundHandler.stop_music()
	_ui.toggle_main_menu(true)


func _on_health_changed(health: int) -> void:
	if health == 0:
		await _wait_until_popup_closed()
		if _player.health == 0:
			_game_over(GameOverPopup.EGameOverReason.NO_HEALTH)


func _on_energy_changed(energy: int) -> void:
	if energy == 0:
		await _wait_until_popup_closed()
		if _player.energy == 0:
			end_day()


func _on_education_level_changed(education_level: int) -> void:
	if education_level == _map.required_education_level:
		_player.education_level_changed.disconnect(_on_education_level_changed)
		var endgame_effect: VoteData = \
				preload("res://resources/vote_data/education_endgame.tres")
		for ve: VoteEffect in endgame_effect.vote_effects:
			ve.execute(self)


func _on_building_entered(building: Building, can_use: bool) -> void:
	last_touched_building = building
	_player.can_move = false
	_ui.show_enter_building_prompt(building.name, 
			building.building_stats, can_use)


func _wait_until_popup_closed() -> void:
	await get_tree().process_frame
	while _ui.is_enter_building_popup_visible():
		await get_tree().process_frame
