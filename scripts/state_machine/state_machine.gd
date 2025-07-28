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

## Generic node-based state machine. 
## Initializes states and delegates callbacks to the active state.
class_name StateMachine extends Node

## Emitted after transitioning to another [State].
signal transition_finished(state_name: String)

## Path to the target node.
@export var target_node: NodePath
## Path to the initial active state.
@export var initial_state: NodePath

## When enabled, allows transitioning from current state to itself.
@export var allow_retransition: bool = true

## The current state machine target.
## Will fall back to state machine parent node if not set.
var target: Node = null

## The current active [State].
## Will fall back to first child node if not set.
var current_state: State


func _ready() -> void:
	target = get_node_or_null(target_node)
	if target == null:
		push_warning("No target set, using parent node as fallback")
		target = get_parent()
	
	current_state = get_node_or_null(initial_state)
	if current_state == null:
		push_warning("No initial state set, using first child node as fallback")
		current_state = get_child(0)
	
	await target.ready
	for state in get_children():
		assert(state is State, "Node %s is not a State!" % state.name)
		state.initialize(self)
	
	current_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func _process(delta: float) -> void:
	current_state.update(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)


## Transitions to another state.[br]
## Calls the current [method State.exit] function, 
## changes the active state, 
## then calls the new [method State.enter] function.
## [param _args] are optional and can be used to send 
## additional data to new state.
## Attempting to transition to a state outside of this [StateMachine]
## scene tree will result in an error and no transition will occur.[br]
## [b]Note:[/b] This function can transition to current state
## if (and only if) [member allow_retransition] is enabled.
## Such behavior WILL trigger [method State.exit] and [method State.enter]!
func transition_to(target_state: NodePath, _args: Dictionary = {}) -> void:
	# Check if this state machine can transition to a valid state.
	if !has_node(target_state):
		push_error(
			"Unable to transition to state %s
	(is it inside state machine scene tree?)" % target_state)
		return
	
	# Get the new state and check if it is different from current.
	var new_state := get_node(target_state) as State
	if current_state == new_state && !allow_retransition:
		return
	
	# Perform transition
	current_state.exit()
	current_state = new_state
	current_state.enter(_args)
	
	#print("[%s] CURRENT STATE: %s" % [self.name, current_state.name])
	print_verbose("[%s] CURRENT STATE: %s" % [self.name, current_state.name])
	transition_finished.emit(current_state.name)
