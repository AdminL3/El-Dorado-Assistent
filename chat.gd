extends Node2D

@onready var host = $Host
@onready var join = $Join
@onready var send = $Send
@onready var message = $Message
@onready var int_display = $IntDisplay

var shared_int: int = 0

func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(1477)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("79.199.160.21", 1477)
	get_tree().set_multiplayer(SceneMultiplayer.new(), self.get_path())
	multiplayer.multiplayer_peer = peer
	joined()

func _on_send_pressed():
	var value = message.text
	value = int(value)
	print(str(value) + " sent")
	rpc("add_int_rpc", value)



@rpc("any_peer", "call_local")
func add_int_rpc(value: int):
	shared_int += value
	update_int_display()

func update_int_display():
	int_display.text = str(shared_int)

func joined():
	host.hide()
	join.hide()
	update_int_display()
