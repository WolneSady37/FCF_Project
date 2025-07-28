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

## A singular entry for [TutorialData].
class_name TutorialEntry extends Resource

## Tutorial entry text. BBCode is allowed.
@export_multiline var tutorial_text: String
## An optional image for this tutorial entry.
@export var tutorial_image: Texture2D
