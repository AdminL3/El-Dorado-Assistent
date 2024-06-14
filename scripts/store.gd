extends Node2D


var store = []
var vorne = []
var hinten = []
func _ready():
	print("Starting store...")
	start_store()
	


#multiplayer

var peer = ENetMultiplayerPeer.new()

func _on_peer_disconnected(id):
	print("Client disconnected with ID: %d" % id)

func start_store():
	peer.create_client("localhost", 8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_connected)

func _on_connected(id):
	if id == multiplayer.get_unique_id():
		print("Connected to server with ID: %d" % id)

# Linked button
func modify_store():
	rpc("broadcast_store", store, vorne, hinten)

@rpc("any_peer")
func broadcast_store(updated_store, newvorne, newhinten):
	store = updated_store
	hinten = newhinten
	vorne = newvorne




#visual representation

@onready var control = $Control
var basicpath = "res://assets/images/"
var scene = preload("res://scenes/card.tscn")

func spawn_hand():
	#spawning
	for i in vorne.size():
		var instance = scene.instantiate()
		control.add_child(instance)
	set_hand_cards()
		
func delete_hand():
	var children = control.get_children()
	for i in children.size():
		var instance = children[i]
		instance.queue_free()

func set_hand_cards():
	var node_width = 270
	var viewport_size = get_viewport().size.x
	var screen_center = viewport_size / 2
	var children = control.get_children()
	var amount = children.size()
	var stack_width = node_width * amount
	var start_x = screen_center - stack_width / 2
	for i in range(amount):
		var card_1 = children[i]
		#set position
		card_1.global_position.x = start_x + i * node_width - viewport_size/5



		#set image
		var sprite2d = card_1.get_node("Sprite2D")
		var path = basicpath + str(vorne[i])  + ".jpg"
		sprite2d.texture = load(path)
		
		#set index
		card_1.set("index", i)


func update_display():
		delete_hand()
		#wait
		await get_tree().create_timer(0.0001).timeout
		spawn_hand()
	