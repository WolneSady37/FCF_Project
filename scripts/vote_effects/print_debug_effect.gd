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

## Displays a debug message, useful in testing.
## Does nothing in release builds.
class_name PrintDebugVoteEffect extends VoteEffect

## Message to display. Supports BBCode.
@export_multiline var message: String

func execute(_context = null) -> void:
	# Print message only in debug builds or when playing in editor.
	if OS.is_debug_build() || OS.has_feature("editor"):
		print_rich(message)
