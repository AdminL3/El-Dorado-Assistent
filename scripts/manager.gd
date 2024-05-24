extends Node2D

var startcards = []
var cards = {
	0 : "Reisende",
	1 : "Forscher",
	2 : "Matrose"
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

func _ready():
	for i in range(4):
		startcards = [0, 0, 0, 0, 1, 1, 1, 2]
		var player = players[i]
		var hand = player[0]
		for x in range(8):
			var card = startcards.pick_random()
			hand.append(card)
			startcards.erase(card)
	print(players)
