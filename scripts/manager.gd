extends Node

var playerselected = 0

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

var h1 = []
var n1 = []
var o1 = []
var p1 = [h1, n1, o1]

var h2 = []
var n2 = []
var o2 = []
var p2 = [h2, n2, o2]

var h3 = []
var n3 = []
var o3 = []
var p3 = [h3, n3, o3]

var h4 = []
var n4 = []
var o4 = []
var p4 = [h4, n4, o4]

var players = [p1, p2, p3, p4]

var store = []


@onready var newbox = $PlayerCAM/New
@onready var handbox = $PlayerCAM/Hand
@onready var oldbox = $PlayerCAM/Old


func if_is_host():
	#shuffle starter cards into hands
	for i in range(4):
		startcards = [0, 0, 0, 0, 1, 1, 1, 2]
		var player = players[i]
		var new = player[1]
		var hand = player[0]
		for x in 8:
			var card = startcards.pick_random()
			new.append(card)
			startcards.erase(card)
		#put 4 cards in hand
		for x in range(4):
			hand.append(new[0])
			new.remove_at(0)
		
	print("Drawer:")
	print(n1,n2,n3,n4)
	print("Hands:")
	print(h1,h2,h3,h4)
	
	#add store cards
	for i in 18:
		store.append(3)
	if !playerselected==4:
		var playe = players[playerselected]
		var hand = playe[0]
		var new = playe[1]
		var old = playe[2]
		handbox.text = str(hand)
		newbox.text = str(new)
		oldbox.text = str(old)


func showcards(player):
	var playe = players[player]
	print("Hand: " + str(playe[0]))
	print("New: " + str(playe[1]))
	print("Old: " + str(playe[2]))


func draw(player):
	var playe = players[player]
	var hand = playe[0]
	var new = playe[1]
	var old = playe[2]
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
	print(hand)
	print(new)
	print(old)


func playcard(card, player):
	var playe = players[player]
	var hand = playe[0]
	var new = playe[1]
	var old = playe[2]
	if hand.has(card):
		old.append(card)
		hand.erase(card)
		print("played: "+ str(cards[card]))
	else:
		print("Dont have card")
	
	playe = players[playerselected]
	hand = playe[0]
	new = playe[1]
	old = playe[2]
	handbox.text = str(hand)
	newbox.text = str(new)
	oldbox.text = str(old)
	print(hand)
	print(new)
	print(old)


func checkvalue(player):
	var playe = players[player]
	var hand = playe[0]
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



	#shopcard means its the x card in the shop


func buycard(shopcard, player):
	var cardvalue = checkvalue(player)
	print("Card Value: " + str(cardvalue))
	#is card available?
	var amount = store[shopcard]
	print(amount)
	if amount == 0:
		print("No have")
	else:
		store[shopcard] = store[shopcard]-1
	print(store[shopcard])




@onready var intro_cam = $IntroCAM
@onready var player_cam = $PlayerCAM





func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		become_host()	
	else:
		become_client()
		print("Starting client side...")


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
	print("Player " + str(playerselected)+ " joined room")



var peer = ENetMultiplayerPeer.new()
var people = []
@onready var display = $Display



func become_host():
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
func _on_peer_connected(id):
	print("Client connected with ID: %d" % id)
	_update_text()

func _on_peer_disconnected(id):
	print("Client disconnected with ID: %d" % id)
	people.erase(id)
	print(people)



func become_client():
	peer.create_client("localhost", 8080)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_connected)

func _on_connected(id):
	if id == multiplayer.get_unique_id():
		_update_text()

func modify_people():
	# Example function to modify the people array
	people.append("0")
	rpc("broadcast_people", people)
	print("People modified and broadcasted: ", people)
	_update_text()

@rpc("any_peer")
func broadcast_people(updated_people):
	people = updated_people
	print("People received and updated by client: ", people)
	_update_text()


func _update_text():
	# Update the text edit with the current people array
	display.text = str(people)




func _on_showcards_pressed():
	showcards(0)
