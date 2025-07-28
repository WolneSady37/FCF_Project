## Main game UI controller.
class_name GameplayUI extends Control

## Emitted when players press "Play" on main menu screen.
signal game_started
## Emitted when restarting the game.
signal restart_requested
## Emitted when returning to main menu.
signal game_ended
## Emitted when player selects "Yes" to enter a building.
signal building_enter_requested
## Emitted when player selects "No" to cancel building entry.
signal building_enter_cancelled

@export_group("Node References")
## Reference to [VotingCarousel] used to display vote options.
@export var voting_panel: VotingCarousel
@export var _game_over_popup: PanelContainer
## Reference to [TutorialPopup] used to display tutorials in game.
@export var tutorial_popup: TutorialPopup
@export var _enter_building_popup: EnterBuildingPopup

## Reference to money counter label.
@onready var money_counter := %MoneyCounter as Label
## Reference to health counter label.
@onready var health_counter := %HealthCounter as Label
## Reference to energy counter label.
@onready var energy_counter := %EnergyCounter as Label
## Reference to day counter label.
@onready var day_counter := %DayCounter as Label
## Reference to max health counter label.
@onready var max_health_counter := %MaxHealthCounter as Label
## Reference to max energy counter label.
@onready var max_energy_counter := %MaxEnergyCounter as Label
## Reference to education level counter label.
@onready var education_level_counter := %EducationLevelCounter as Label

@onready var _edulevel_container := %EducationLevelContainer as HBoxContainer
@onready var _main_menu_ui := $MainMenu as Control
@onready var _in_game_ui := $InGame as Control

@onready var _start_button := %StartGameButton as Button


func _ready() -> void:
	toggle_main_menu(true)
	_game_over_popup.restart_button.pressed.connect(
			_on_restart_button_pressed)
	_game_over_popup.main_menu_button.pressed.connect(
			_on_main_menu_button_pressed)
	_enter_building_popup.yes_button.pressed.connect(
		func() -> void: building_enter_requested.emit()
	)
	_enter_building_popup.no_button.pressed.connect(
		func() -> void: building_enter_cancelled.emit()
	)
	_start_button.pressed.connect(
		func() -> void: game_started.emit()
	)
	# Hide quit button on mobile
	$QuitButton.visible = !(OS.get_name() in ["Android", "iOS"])
	$ToggleDebugButton.visible = OS.is_debug_build()


## Toggles visibily of the main menu.
func toggle_main_menu(menu_visible: bool) -> void:
	_main_menu_ui.set_visible(menu_visible)
	_in_game_ui.set_visible(!menu_visible)


## Displays the game over popup when player wins or loses the game.
func show_game_over_prompt(reason: GameOverPopup.EGameOverReason) -> void:
	_game_over_popup.set_reason(reason)
	_game_over_popup.show()


## Displays a prompt to enter currently touched building.
func show_enter_building_prompt(building_name: String, 
		building_stats: StatComponent,
		can_use: bool) -> void:
	_enter_building_popup.setup(
			building_name, 
			building_stats.to_string(), 
			can_use
	)
	_enter_building_popup.show()


## Displays a tutorial popup.
## Requires a [TutorialData] resource to populate tutorial popup pages.
func show_tutorial_popup(tutorial_data: TutorialData) -> void:
	if tutorial_data:
		tutorial_popup.show()
		tutorial_popup.setup_tutorial(tutorial_data)


## Displays the voting panel.
## Requires an [Array] containing [VoteData] to populate vote cards.
func show_voting_panel(cards: Array[VoteData]) -> void:
	voting_panel.setup_cards(cards)
	voting_panel.show()


## Hides the [VotingCarousel].
func hide_voting_panel() -> void:
	voting_panel.hide()
	voting_panel.clear_cards()


## Returns true if a building enter prompt is currently visible.
func is_enter_building_popup_visible() -> bool:
	return _enter_building_popup.is_visible()


func _on_money_changed(new_money: int) -> void:
	money_counter.set_text(str(new_money))


func _on_health_changed(new_health: int) -> void:
	health_counter.set_text(str(new_health))


func _on_energy_changed(new_energy: int) -> void:
	energy_counter.set_text(str(new_energy))


func _on_education_level_changed(new_education_level: int) -> void:
	education_level_counter.set_text(str(new_education_level))
	_edulevel_container.set_visible(new_education_level > 0)


func _on_max_health_changed(new_max_health: int) -> void:
	max_health_counter.set_text("/" + str(new_max_health))


func _on_max_energy_changed(new_max_energy: int) -> void:
	max_energy_counter.set_text("/" + str(new_max_energy))


func _on_start_game_button_pressed() -> void:
	game_started.emit()


func _on_restart_button_pressed() -> void:
	_game_over_popup.hide()
	restart_requested.emit()


func _on_main_menu_button_pressed() -> void:
	_game_over_popup.hide()
	game_ended.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


#region DEBUG
func _on_end_day_pressed() -> void:
	SignalBus.end_day_requested.emit()


func _on_lose_money_pressed() -> void:
	show_game_over_prompt(GameOverPopup.EGameOverReason.NO_MONEY)


func _on_lose_health_pressed() -> void:
	show_game_over_prompt(GameOverPopup.EGameOverReason.NO_HEALTH)


func _on_win_day_pressed() -> void:
	show_game_over_prompt(GameOverPopup.EGameOverReason.FINAL_DAY)


func _on_win_house_pressed() -> void:
	show_game_over_prompt(GameOverPopup.EGameOverReason.HOUSE_BOUGHT)


func _on_toggle_debug_button_pressed():
	var dbg := $DEBUG as Control
	dbg.visible = !dbg.visible
#endregion
