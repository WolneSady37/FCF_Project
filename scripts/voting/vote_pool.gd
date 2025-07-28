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

## A pool of [VoteData]s that can be picked at the start of a voting process.
class_name VotePool extends Resource

## An [Array] of [VoteData]s present in the pool
@export var options: Array[VoteData]
## Amount of unique choices to select.
@export_range(1, 1, 1, "or_greater") var choices_count: int = 3


## Returns an [Array] containing at most [member choice_count] 
## unique [VoteData]s from the pool.
## Cannot select two [VoteData]s with the same party ID.
func get_random_choices() -> Array[VoteData]:
	var used_party_ids: Dictionary = {}
	var available: Array[VoteData] = options.duplicate(true)
	available.shuffle()
	
	var ret: Array[VoteData]
	
	for vote_data: VoteData in available:
		if used_party_ids.has(vote_data.party_id):
			continue
		
		ret.append(vote_data)
		used_party_ids[vote_data.party_id] = true
		if ret.size() >= choices_count:
			break
	
	return ret
