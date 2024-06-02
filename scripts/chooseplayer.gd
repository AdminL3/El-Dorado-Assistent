extends Node2D

@onready var playerboss = $"."

@onready var manager = %Manager
@onready var intro_cam = $"../IntroCAM"
@onready var player_1cam = $"../PlayerCAM"
@onready var host_cam = $"../HostCAM"


func _on_button_pressed():
	loadscene(0)

func _on_button_2_pressed():
	loadscene(1)
	
func _on_button_3_pressed():
	loadscene(2)

func _on_button_4_pressed():
	loadscene(3)

func _on_host_pressed():
	intro_cam.enabled = false
	host_cam.enabled = true
	manager.create_host()


func loadscene(player):
	intro_cam.enabled = false
	manager.playerselected = player
	print("Player: " + str(manager.playerselected))
	manager.joinroom()
