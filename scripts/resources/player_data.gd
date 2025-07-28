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

## Serializable player data.
class_name PlayerData extends Resource

## Player's money.
var money: int = 30

## Player's base health.
var base_health: int = 50

## Player's base energy.
var base_energy: int = 50

## Player's bonus health.
var bonus_health: int = 0

## Player's bonus energy
var bonus_energy: int = 0

# PLayer's education level is not serialized, 
# since as of right now it's only relevant in the final level,
# so there's no need to pass it between maps.


## Converts this object into a [Dictionary] ready for serialization.
func serialize() -> Dictionary:
	var data := {}
	data["money"] = money
	data["base_health"] = base_health
	data["base_energy"] = base_energy
	data["bonus_health"] = bonus_health
	data["bonus_energy"] = bonus_energy
	return data.duplicate(true) # return value, not reference


## Recovers the object state from a [Dictionary].
func restore(_data: Dictionary) -> void:
	if _data.is_empty():
		return
	
	money = _data.get("money", 30)
	base_health = _data.get("base_health", 50)
	base_energy = _data.get("base_energy", 50)
	bonus_health = _data.get("bonus_health", 0)
	bonus_energy = _data.get("bonus_energy", 0)
