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

## A [VoteEffect] that directly alters [Player]'s stats.
class_name PlayerStatEffect extends VoteEffect

## [StatComponent] used to alter [Player]'s stats.
@export var new_stats: StatComponent
## Stats to take into consideration when altering stats.
@export_flags(
	"Education Level",
	"Money",
	"Health",
	"Energy",
	"Bonus Health",
	"Bonus Energy",
) var stats_to_apply: int
## Whether to combine (sum) or override stats of the [Player].
@export_enum("Override", "Combine") var operation_type: int = 0


func execute(_context: Object) -> void:
	var _player := _context.get_player() as Player
	assert(_player)
	
	if stats_to_apply & (1 << 0):
		_player.education_level = \
			new_stats.education_level if operation_type == 0 \
			else _player.education_level + new_stats.education_level
	if stats_to_apply & (1 << 1):
		_player.money = \
			new_stats.money if operation_type == 0 \
			else _player.money + new_stats.money
	if stats_to_apply & (1 << 2):
		_player.health = \
			new_stats.health if operation_type == 0 \
			else _player.health + new_stats.health
	if stats_to_apply & (1 << 3):
		_player.energy = \
			new_stats.energy if operation_type == 0 \
			else _player.energy + new_stats.energy
	if stats_to_apply & (1 << 4):
		_player.bonus_health = \
			new_stats.bonus_health if operation_type == 0 \
			else _player.bonus_health + new_stats.bonus_health
	if stats_to_apply & (1 << 5):
		_player.bonus_energy = \
			new_stats.bonus_energy if operation_type == 0 \
			else _player.bonus_energy + new_stats.bonus_energy
