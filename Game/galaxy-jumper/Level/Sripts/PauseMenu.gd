extends CanvasLayer

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var exit_button = $CenterContainer/VBoxContainer/ExitButton
@onready var settings_dialog = $SettingsDialog

func _ready():
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	visible = !visible
	get_tree().paused = visible

func _on_resume_pressed():
	toggle_pause()

func _on_settings_pressed():
	settings_dialog.popup_centered()

func _on_exit_pressed():
	toggle_pause() # Unpause before leaving
	get_tree().change_scene_to_file("res://Level/Scenes/Main_Menu.tscn")
