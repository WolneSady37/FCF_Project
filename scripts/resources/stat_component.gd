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

## Lightweight object for passing or modifying player stats.
class_name StatComponent extends Resource

@export var education_level: int
@export var money: int
@export var health: int
@export var energy: int
@export_group("Advanced")
@export var bonus_health: int
@export var bonus_energy: int


## Combines two StatComponents into one, summing their values together
func combine(other: StatComponent) -> void:
	self.education_level += other.education_level
	self.money += other.money
	self.health += other.health
	self.energy += other.energy
	self.bonus_health += other.bonus_health
	self.bonus_energy += other.bonus_energy


func _to_string() -> String:
	var ss := "\n"
	if education_level != 0:
		ss += "Education Level " + ("+" if education_level > 0 else "") + \
			str(education_level) + "\n"
	if money != 0:
		ss += "Money " + ("+" if money > 0 else "") + str(money) + "\n"
	if health != 0:
		ss += "Health " + ("+" if health > 0 else "") + str(health) + "\n"
	if energy != 0:
		ss += "Energy " + ("+" if energy > 0 else "") + str(energy) + "\n"
	if bonus_health != 0:
		ss += "Bonus Health " + ("+" if bonus_health > 0 else "") \
				+ str(bonus_health) + "\n"
	if bonus_energy != 0:
		ss += "Bonus Energy " + ("+" if bonus_energy > 0 else "") \
				+ str(bonus_energy) + "\n"
	
	return ss
