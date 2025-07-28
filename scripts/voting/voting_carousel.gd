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

## Displays vote options using a carousel.
## Swipe left or right to toggle between cards.
class_name VotingCarousel extends Panel

## Emitted after swipe.
## Used to handle vote effect preview.
signal card_swiped(old_data: VoteData, new_data: VoteData)

const _VOTE_CARD_SCENE: PackedScene =\
	preload("res://scenes/voting/carousel_vote_card.tscn")

## Threshold for a swipe gesture distance to be detected.
@export var swipe_threshold: float = 50
## How long does the card swipe animation lasts.
@export var duration: float = 0.25

## Reference to [VotingCard] present in the container
var cards := []

var _current_index := 0
var _start_pos := Vector2.ZERO
var _swiped := false

@onready var main_container := %CardContainer
@onready var width: float = size.x # Cache original width on ready.


func _input(event: InputEvent) -> void:
	if !visible:
		return
	
	if event is InputEventScreenTouch && event.pressed:
		_start_pos = event.position
		_swiped = false
	
	elif event is InputEventScreenDrag && !_swiped:
		var delta: Vector2 = event.get_position() - _start_pos
		if absf(delta.x) > swipe_threshold:
			if delta.x < 0:
				_next_card()
			else:
				_previous_card()
			_swiped = true


func setup_cards(vote_choices: Array[VoteData]) -> void:
	for i: int in vote_choices.size():
		var _card := _VOTE_CARD_SCENE.instantiate() as VoteCard
		if _card != null:
			_card.vote_data = vote_choices[i]
			main_container.add_child(_card)
			cards.append(_card)
	
	# Set main_container size to fit all cards side by side
	main_container.size.x = width * vote_choices.size()
	main_container.position.x = 0
	_current_index = 0
	update_card_position()


func clear_cards() -> void:
	for c in main_container.get_children():
		c.queue_free()
	
	cards.clear()


## Updates displayed card position
func update_card_position():
	var target_x = -size.x * _current_index
	var tween := get_tree().create_tween()
	tween.tween_property(
			main_container, 
			^"position:x", 
			target_x, 
			duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)


func _next_card() -> void:
	if _current_index < cards.size() - 1:
		_current_index += 1
		update_card_position()
		card_swiped.emit(
			main_container.get_child(0).vote_data,
			main_container.get_child(1).vote_data
		)


func _previous_card() -> void:
	if _current_index > 0:
		_current_index -= 1
		update_card_position()
		card_swiped.emit(
			main_container.get_child(1).vote_data,
			main_container.get_child(0).vote_data
		)
