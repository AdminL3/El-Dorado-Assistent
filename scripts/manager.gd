extends Node


var startcards = []
var cards = {
	0 : "Reisende",
	1 : "Forscher",
	2 : "Matrose",
	3 : "Kundschafter",
	4 : "Entdecker",
	5 : "Tausendsassa",
	6 : "Fotografin",
	7 : "Schatztruhe",
	8 : "Fernsprechgerät",
	9 : "Propellerflugzeug",
	10 : "Abenteurerin",
	11 : "Pionier",
	12 : "Mächtige Machete",
	13 : "Journalistin",
	14 : "Millionärin",
	15 : "Kartograph",
	16 : "Kompass",
	17 : "Wissenschaftlerin",
	18 : "Reisetagebuch",
	19 : "Ureinwohner",
	20 : "Kaptain"
}
var prices = {
	3 : 1,
	4 : 3,
	5 : 2,
	6 : 2,
	7 : 3,
	8 : 4,
	9 : 4,
	10 : 4,
	11 : 5,
	12 : 3,
	13 : 3,
	14 : 5,
	15 : 4,
	16 : 2,
	17 : 4,
	18 : 3,
	19 : 5,
	20 : 2

}

var hand = []
var new = []
var old = []


var vorne = []
var hinten = []
var store = []








func setstore():
	#add store cards
	for i in 3:
		store.append(0)
	for i in 18:
		store.append(3)	
	for i in 6:
		vorne.append(i+3)
	for i in 12:
		hinten.append(i+9)
	print(store)
	print(hinten)
	print(vorne)
	
func register_player():
	#shuffle starter cards into hands
	startcards = [0, 0, 0, 0, 1, 1, 1, 2]
	for x in 8:
		var card = startcards.pick_random()
		new.append(card)
		startcards.erase(card)
	for i in 4:
		draw()
	_update_text()




func draw():
	if hand.size() > 3:
		print("Watch out! Already have 4")
	
	if new.size() !=0:
		hand.append(new[0])
		new.remove_at(0)	
		print(hand)
	else:
		print("No cards left - Shuffle")
		print(old)
		for x in old.size():
			var card = old.pick_random()
			new.append(card)
			old.erase(card)
		print(old)
	_update_text()


@onready var line_2 = $line2

func testplay():
	playcard(int(line_2.text))


func playcard(card):	
	if hand.has(card):
		old.append(card)
		hand.erase(card)
		print("played: "+ str(cards[card]))
	else:
		print("Dont have card")
	
	_update_text()


func checkvalue():
	var value = 0
	var size = hand.size()
	for x in hand:
		if x == 0:
			value += 1
			size -= 1
		elif x == 6:
			value += 2
			size -= 1
		elif x == 7:
			value += 4
			size -= 1
		elif x == 13:
			value += 3
			size -= 1
		elif x == 14:
			value += 4
			size -= 1
	#add half value cards
	value = value + size*0.5
	
	#if 0.5 make full
	value = floor(value)
	
	return value




@onready var line = $line


func _on_buycard_0_pressed():
	buycard(int(line.text))


#shopcard is the buywant card in the shop
func buycard(shopcard):
	#is it a shopcard?
	if shopcard > 2:
		#its a card that can be bought
		
		#money
		var cardvalue = checkvalue()
		print("Card Value: " + str(cardvalue))
		
		#enough money?
		if cardvalue >= prices[shopcard]:
			
			#is card up front or is open
			if vorne.has(shopcard) or vorne.size() < 6:
				
				#how many cards
				var amount = store[shopcard]
				
				#enough cards?
				if amount != 0:
					
					# -1 for shop
					store[shopcard] = store[shopcard]-1
					#add to old
					old.append(shopcard)
					#check if empty now
					if amount - 1 == 0:
						#remove from vorne
						vorne.erase(shopcard)
						
					#if shop is open
					elif vorne.size() < 6:
						
						#check if already front
						if !vorne.has(shopcard):
						
							#move to front
							vorne.append(shopcard)
							hinten.erase(shopcard)
					
					#update everything
					_update_text()
					
					#send store around
					modify_people()
				else:
					print("No more cards left")
			else:
				print("Card not accesible")






func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		become_host()
		setstore()
	else:
		print("Starting client side...")
		become_client()
	





var peer = ENetMultiplayerPeer.new()


func become_host():
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
func _on_peer_connected(id):
	print("Client connected with ID: %d" % id)
	rpc_id(id, "broadcast_people", store, vorne, hinten)  # Send the store array to the newly connected client
	_update_text()

func _on_peer_disconnected(id):
	print("Client disconnected with ID: %d" % id)

func become_client():
	peer.create_client("localhost", 8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_connected)
	register_player()

func _on_connected(id):
	if id == multiplayer.get_unique_id():
		print("Connected to server with ID: %d" % id)
		_update_text()

# Linked button
func modify_people():
	rpc("broadcast_people", store, vorne, hinten)
	_update_text()

@rpc("any_peer")
func broadcast_people(updated_store, newvorne, newhinten):
	store = updated_store
	hinten = newhinten
	vorne = newvorne
	_update_text()




@onready var newbox = $New
@onready var handbox = $Hand
@onready var oldbox = $Old

@onready var vornebox = $Vorne
@onready var hintenbox = $Hinten

var text
func _update_text():
	text = ""
	for i in hinten:
		text = text + str(cards[i]) + ": "+ str(store[i]) + "\n"
	hintenbox.text = text
	
	text = ""
	for i in vorne:
		text = text + str(cards[i]) + ": "+ str(store[i]) + "\n"
	vornebox.text = text
	
	#show cards by name
	text = ""
	for i in hand:
		text = text + str(cards[i]) + "\n"
	handbox.text = text
	text = ""
	for i in new:
		text = text + str(cards[i]) + "\n"
	newbox.text = text
	text = ""
	for i in old:
		text = text + str(cards[i]) + "\n"
	oldbox.text = text



var paths = ["user://hand.save", "user://new.save", "user://old.save"]
var storepath = "user://store.save"
var vornepath = "user://storevorne.save"
var hintenpath = "user://storehinten.save"
func savedata():
	var loadvariables = [hand, new, old]
	print(store)
	for i in 6:
		if i < 3: 
			var file = FileAccess.open(paths[i], FileAccess.WRITE)
			file.store_var(loadvariables[i])
			print("Saved Data..."+ str(loadvariables[i]))
		elif i == 3:
			var file = FileAccess.open(storepath, FileAccess.WRITE)
			file.store_var(store)
		elif i==4:
			var file = FileAccess.open(vornepath, FileAccess.WRITE)
			file.store_var(vorne)
		elif i==5:
			var file = FileAccess.open(hintenpath, FileAccess.WRITE)
			file.store_var(hinten)
			
	
func loaddata():
	var file
	file = FileAccess.open(paths[0], FileAccess.READ)
	hand = file.get_var()
	file = FileAccess.open(paths[1], FileAccess.READ)
	new = file.get_var()
	file = FileAccess.open(paths[2], FileAccess.READ)
	old = file.get_var()
	file = FileAccess.open(storepath, FileAccess.READ)
	store = file.get_var()
	file = FileAccess.open(vornepath, FileAccess.READ)
	vorne = file.get_var()
	file = FileAccess.open(hintenpath, FileAccess.READ)
	hinten = file.get_var()
	_update_text()
	print("Data loaded...")





@onready var control = $Control
var control_size #site of control node for centering
var scene = preload("res://scenes/card.tscn")
var card_width = 128 # Width of each card
var num_cards = 5 # Total number of cards to spawn
var total_width = card_width * num_cards

var start_x = (control_size - total_width) / 2 # Centering the cards

var next_position = Vector2(start_x, 0) # Starting position for the first card
var offset = Vector2(card_width, 0) # Change this value to the width of your card
func _on_button_pressed():
	var instance = scene.instantiate()
	instance.position = next_position
	control.add_child(instance)
	next_position += offset # Update the position for the next card


