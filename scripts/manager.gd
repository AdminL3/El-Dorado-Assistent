extends Node

var playerselected
var ishost = false

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


var store = []



@onready var intro_cam = $IntroCAM
@onready var player_cam = $PlayerCAM


@onready var newbox = $New
@onready var handbox = $Hand
@onready var oldbox = $Old



func setstore():
	#add store cards
	for i in 18:
		store.append(3)
	print(store)
	
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
			print("You have Reisende")
		elif x == 6:
			value += 2
			size -= 1
			print("You have Fotografin")
		elif x == 7:
			value += 4
			size -= 1
			print("You have Schatztruhe")
		elif x == 13:
			value += 3
			size -= 1
			print("You have Journalistin")
		elif x == 14:
			value += 4
			size -= 1
			print("You have Millionärin")
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
			
			#how many cards
			var amount = store[shopcard]
			
			#enough cards?
			if amount != 0:
				#buycard
				print(str(amount) + " available")
				store[shopcard] = store[shopcard]-1
				old.append(shopcard)
				
				#update everything
				handbox.text = str(hand)
				newbox.text = str(new)
				oldbox.text = str(old)
				
				#send store around
				modify_people()
			else:
				print("No more left")
	








func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		ishost = true
		become_host()
		setstore()
	else:
		print("Starting client side...")
		become_client()

func joinas1():
	loadscene(0)

func joinas2():
	loadscene(1)
	
func joinas3():
	loadscene(2)

func joinas4():
	loadscene(3)

func loadscene(player):
	intro_cam.enabled = false
	playerselected = player
	register_player()
	print("Player " + str(playerselected) + " joined room")

var peer = ENetMultiplayerPeer.new()

@onready var display = $Display

func become_host():
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
func _on_peer_connected(id):
	print("Client connected with ID: %d" % id)
	rpc_id(id, "broadcast_people", store)  # Send the store array to the newly connected client
	_update_text()

func _on_peer_disconnected(id):
	print("Client disconnected with ID: %d" % id)

func become_client():
	peer.create_client("localhost", 8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_connected)

func _on_connected(id):
	if id == multiplayer.get_unique_id():
		print("Connected to server with ID: %d" % id)
		_update_text()

# Linked button
func modify_people():
	rpc("broadcast_people", store)
	print("New: ", store)
	_update_text()

@rpc("any_peer")
func broadcast_people(updated_store):
	store = updated_store
	print("People received and updated by client: ", store)
	_update_text()

func _update_text():
	display.text = str(store)

	
