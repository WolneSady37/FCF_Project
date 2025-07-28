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

## A [VoteEffect] that changes a [StatComponent] 
## of all [Building]s with a selected name.
class_name BuildingStatEffect extends VoteEffect

## New [StatComponent] that will be applied on effect execution.
@export var new_stats: StatComponent
## Name of [Building] to change stats.
## "Building Group" is the exact same as a [Building] name.
@export var building_group: StringName
## Whether to combine (sum) or override stats of a [Building].
@export_enum("Override", "Combine") var operation_type: int = 0

func execute(_context: GameplayManager) -> void:
	assert(_context, "Context for BuildingStatEffect cannot be null.")
	var buildings := _context.get_tree().get_nodes_in_group(
				building_group.to_snake_case())
	for b in buildings:
		var building := b as Building
		if building == null:
			continue
		
		if operation_type == 1:
			building.building_stats.combine(new_stats)
		else:
			building.building_stats = new_stats
