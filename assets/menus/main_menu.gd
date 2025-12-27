extends Control
var volume_label : Label
var start_volume : float = 42.0
var music : AudioStreamPlayer

func _ready() -> void:
	music = $AudioStreamPlayer
	music.volume_db = -40+start_volume/2
	volume_label = $HBoxContainer/Left/MarginContainer2/VBoxContainer/HBoxContainer/Volume
	volume_label.text = str(int(start_volume))


func _on_demo_level_start_button_up() -> void:
	GameManager.load_level(0)
	$DemoLevelStart.visible = false
	$HBoxContainer/TextureRect.visible = false



func _on_h_slider_value_changed(value: float) -> void:
	music.volume_db = -40+value/2
	volume_label.text = str(int(value))
	if value == 0:
		music.volume_db = -80
		

