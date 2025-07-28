## Displays a game over popup when player wins or loses the game.
class_name GameOverPopup extends PanelContainer

## Reason for game over state
enum EGameOverReason { 
	NO_MONEY, ## Player ran out of money
	NO_HEALTH, ## Player's health dropped to 0
	FINAL_DAY, ## Player survived to the last day
	HOUSE_BOUGHT ## Player bought their own house
}

@export_group("Game Over Reason Texts")
## Text displayed when player ran out of money.
@export_multiline var no_money_text: String = \
		"You ran out of money!"
## Text displayed when player's health dropped to 0.
@export_multiline var no_health_text: String = \
		"Your health dropped to 0!"
## Text displayed when player survived all days.
@export_multiline var final_day_text: String = \
		"Final day reached!"
## Text displayed when player bought a house.
@export_multiline var house_bought_text: String = \
		 "You have purchased your own house!"

@onready var restart_button := %RestartButton as Button
@onready var main_menu_button := %MainMenuButton as Button
@onready var _title_label := $VBoxContainer/Label as Label
@onready var _reason_label := $VBoxContainer/ReasonLabel as Label


func set_reason(reason: EGameOverReason) -> void:
	match reason:
		EGameOverReason.NO_MONEY:
			_reason_label.set_text(no_money_text)
			_title_label.set_text("Game Over!")
		EGameOverReason.NO_HEALTH:
			_reason_label.set_text(no_health_text)
			_title_label.set_text("Game Over!")
		EGameOverReason.FINAL_DAY:
			_reason_label.set_text(final_day_text)
			_title_label.set_text("You Win!")
		EGameOverReason.HOUSE_BOUGHT:
			_reason_label.set_text(house_bought_text)
			_title_label.set_text("You Win!")
		_:
			push_warning("Unknown reason!")
			_reason_label.set_text("No reason provided.")
			_title_label.set_text("Game Over!")
