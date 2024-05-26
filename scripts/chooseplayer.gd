extends Button


@onready var manager = %Manager

func _on_pressed():
	loadscene(0)


func _on_button_2_pressed():
	loadscene(1)


func _on_button_3_pressed():
	loadscene(2)


func _on_button_4_pressed():
	loadscene(3)

func _on_host_pressed():
	loadscene(4)


func loadscene(player):
	manager.player = player
