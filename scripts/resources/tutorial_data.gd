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

## Lightweight object for creating tutorials
class_name TutorialData extends Resource

## Name of this tutorial, displayed on top of the tutorial popup.
@export var tutorial_title: String

## An [Array] of all associated tutorial entries ([TutorialEntry]).
@export var tutorial_entries: Array[TutorialEntry]
