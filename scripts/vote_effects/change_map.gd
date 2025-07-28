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

## @experimental
## A [VoteEffect] that changes the current map.
class_name ChangeMap extends VoteEffect

## A [PackedScene] containing the new [GameMap].
@export var new_map: PackedScene

func execute(_context: GameplayManager) -> void:
	assert(_context, "Context for ChangeMap cannot be null.")
	if new_map == null:
		push_error("No map provided for ChangeMap vote effect")
		return
	
	_context.change_map(new_map)
