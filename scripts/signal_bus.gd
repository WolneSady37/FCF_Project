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

extends Node

@warning_ignore_start("unused_signal")
#region BUILDING
signal building_registered(building: Building)
signal building_unregistered(building: Building)
signal building_entered(building: Building, can_use: bool)
signal building_used(building: Building)
#endregion
signal vote_start_requested
signal end_day_requested(full_reset: bool)
signal house_bought
