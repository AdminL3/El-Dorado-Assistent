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
var player = [hand, new, old]


var vorne = []
var hinten = []
var store = []





@onready var newbox = $New
@onready var handbox = $Hand
@onready var oldbox = $Old



func setstore():
	#add store cards
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
	
	print("Drawer:")
	print(new)
	print("Hand:")
	print(hand)
	
		
	handbox.text = str(hand)
	newbox.text = str(new)
	oldbox.text = str(old)


func showcards():
	print("Hand: " + hand)
	print("New: " + new)
	print("Old: " + old)


func draw():
	if hand.size() < 4:
		if new.size() !=0:
			hand.append(new[0])
			new.remove_at(0)	
			print(hand)
		else:
			print("No cards left - Shuffle")
			for x in old:
				var card = old.pick_random()
				new.append(card)
				old.erase(card)
	else:
		print("Already have 4 cards")
	handbox.text = str(hand)
	newbox.text = str(new)
	oldbox.text = str(old)


func playcard(card):
	if hand.has(card):
		old.append(card)
		hand.erase(card)
		print("played: "+ str(cards[card]))
	else:
		print("Dont have card")
	
	handbox.text = str(hand)
	newbox.text = str(new)
	oldbox.text = str(old)


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
					if vorne.size() < 6:
						vorne.append(shopcard)
						hinten.erase(shopcard)
					
					#update everything
					handbox.text = str(hand)
					newbox.text = str(new)
					oldbox.text = str(old)
					
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



@onready var display = $Display
@onready var vornebox = $Vorne
@onready var hintenbox = $Hinten

func _update_text():
	var text = ""
	for i in 18:
		text = text + str(cards[i]) + ": "+ str(store[i]) + "\n"
	display.text = text
	vornebox.text = str(vorne)
	hintenbox.text = str(hinten)
