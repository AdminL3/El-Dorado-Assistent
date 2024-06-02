extends Node2D

@onready var host = $Host
@onready var join = $Join
@onready var username = $Username
@onready var send = $Send
@onready var message = $Message
@onready var messages = $Messages

var usrn : String
var msg : String


func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1477)
	get_tree().set_multiplayer(SceneMultiplayer.new(),self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("79.199.160.21",1477)
	print("Attempting to connect to server...")
	get_tree().set_multiplayer(SceneMultiplayer.new(),self.get_path())
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		print("Connection successful")
	else:
		print("Connection failed")
	joined()
	

func _on_send_pressed():
	if multiplayer.multiplayer_peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		rpc("msg_rpc", usrn , message.text)
		print("sent")
	else:
		print("Peer is not connected")

	
@rpc ("any_peer","call_local")
func msg_rpc(usrnm, data):
	messages.text += str(usrnm, ": ", data, "\n")
	
func joined():
	host.hide()
	join.hide()
	username.hide()
	usrn=username.text
