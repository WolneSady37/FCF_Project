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

## A graphical representation of a vote option.
class_name VoteCard extends PanelContainer

## Emitted after the player submits their vote by pressing the "Vote" button.
signal voted(vote: VoteData)

## [VoteData] associated with this vote option.
@export var vote_data: VoteData

@onready var _portrait := %Portrait as TextureRect
@onready var _title := %Title as Label
@onready var _description := %Description as RichTextLabel
@onready var _vote_button := %VoteButton as Button


func _ready() -> void:
	assert(vote_data, "No vote data set. Assign one in the Inspector.")
	
	set_vote_title(vote_data.title)
	set_vote_description(vote_data.description)
	set_vote_portrait(vote_data.portrait)
	set_background_color(vote_data.background_color)
	
	if !_vote_button.pressed.is_connected(_on_vote_button_pressed):
		_vote_button.pressed.connect(_on_vote_button_pressed)


## Sets the title of this [VoteCard].
func set_vote_title(title: String) -> void:
	_title.set_text(title)


## Sets description of this [VoteCard].
func set_vote_description(bbcode_text: String) -> void:
	_description.set_text(bbcode_text)


## Sets a portrait on this [VoteCard].
func set_vote_portrait(portrait: Texture2D) -> void:
	_portrait.set_texture(portrait)


## Sets the background color of this [VoteCard].
func set_background_color(color: Color) -> void:
	var _stylebox_bg := StyleBoxFlat.new()
	_stylebox_bg.bg_color = color
	add_theme_stylebox_override(&"panel", _stylebox_bg)


func _on_vote_button_pressed() -> void:
	voted.emit(vote_data)
