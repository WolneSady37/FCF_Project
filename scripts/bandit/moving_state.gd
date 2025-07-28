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

extends State

var _bandit: Bandit


func initialize(state_machine: StateMachine) -> void:
	super(state_machine)
	_bandit = target as Bandit
	assert(_bandit, "Target node '%s' is not a Bandit" % target.name)


func enter(_args: Dictionary = {}) -> void:
	await _bandit.move(_args.get(&"selected_tile", Vector2i.ZERO))
	_bandit.state_machine.transition_to(^"Idle")
	_bandit.turn_finished.emit()


func exit() -> void:
	_bandit.clear_requested.emit()
