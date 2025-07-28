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

## Represents a vote option that consists of multiple [VoteEffect]s.
class_name VoteData extends Resource

## Vote title shown on top of vote card
@export var title: String

## Unique party ID. Two votes with the same ID 
## cannot be offered as an option in one voting.
@export var party_id: int = 0

## Portrait displayed alongside vote description in [VoteCard]
@export var portrait: Texture2D = preload("res://icon.svg")

## Background color of the vote card
@export_color_no_alpha var background_color := Color.ROYAL_BLUE

## Vote description displayed inside vote card. BBCode is supported
@export_multiline var description: String

## [VoteEffects] that will trigger when this vote option is selected by player.
@export var vote_effects: Array[VoteEffect]
