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

## @deprecated
## A [VoteEffect] that changes how player's stats are affected on daily reset.
class_name DailyResetStatEffect extends VoteEffect

## [StatComponent] defining new 
@export var new_stats: StatComponent
@export_enum("Override", "Combine") var operation_type: int = 1

func execute(_context: GameplayManager) -> void:
	assert(_context, "Context for BuildingStatEffect cannot be null.")
	var map := _context.get_map() as GameMap
		
	if operation_type == 1:
		map.stats_daily_reset.combine(new_stats)
	else:
		map.stats_daily_reset = new_stats
