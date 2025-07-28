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

## A [RichTextLabel] that pops up and disappears with a subtle animation.
class_name PopupLabel extends RichTextLabel

## Show this [PopupLabel], making it fly upwards and disappear after a while.
## Depending on [param is_positive], tints the text
## green for positive messages and red for negative ones.
func popup(message: String, is_positive: bool = false) -> void:
	if is_positive:
		append_text("[color=green]" + message + "[/color]")
	else:
		append_text("[color=red]" + message + "[/color]")
	
	if !is_inside_tree(): # Delay tweens until added to the tree
		await ready
	
	var _tween := get_tree().create_tween()
	_tween.tween_property(
		self,
		^"position",
		position + Vector2.UP * 80.0,
		0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	_tween.tween_interval(0.9)
	_tween.tween_property(
		self,
		^"modulate",
		Color(1.0, 1.0, 1.0, 0.0), 
		0.3)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)
	
	await _tween.finished
	queue_free()
