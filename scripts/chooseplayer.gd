extends Node2D


@onready var manager = %Manager
@onready var intro_cam = $"../IntroCAM"
@onready var player_1cam = $"../Player1CAM"
@onready var player_2cam = $"../Player2CAM"
@onready var player_3cam = $"../Player3CAM"
@onready var player_4cam = $"../Player4CAM"
@onready var host_cam = $"../HostCAM"


func _on_button_pressed():
	loadscene(0)
	player_1cam.enabled = true
	manager.joinroom()

func _on_button_2_pressed():
	loadscene(1)
	player_2cam.enabled = true
	manager.joinroom()
	
func _on_button_3_pressed():
	loadscene(2)
	player_3cam.enabled = true
	manager.joinroom()

func _on_button_4_pressed():
	loadscene(3)
	player_4cam.enabled = true
	manager.joinroom()

func _on_host_pressed():
	loadscene(4)
	host_cam.enabled = true
	manager.create_host()


func loadscene(player):
	intro_cam.enabled = false
	manager.player = player
	print("Player: " + str(manager.player))
