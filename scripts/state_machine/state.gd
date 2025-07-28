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

## Virtual base class for all [State]s used in [StateMachine]s.
class_name State extends Node

## Target for this [State].
var target: Node = null

# Reference to the owning StateMachine.
# Set by the state machine node.
var _state_machine: StateMachine = null


## Called by the owning [StateMachine].
func initialize(state_machine: StateMachine) -> void:
	_state_machine = state_machine
	target = state_machine.target


## Receives events from the [method Node._unhandled_input] callback.
func handle_input(_event: InputEvent) -> void:
	pass


## Corresponds to the [method Node._process] callback.
func update(_delta: float) -> void:
	pass


## Corresponds to the [method Node._physics_process] callback.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine when entering this [State].
## [param _args] can be optionally provided by state for self initalization.
func enter(_args: Dictionary = {}) -> void:
	pass


## Called by the [StateMachine] when exiting this [State].
## Used for cleanup.
func exit() -> void:
	pass
