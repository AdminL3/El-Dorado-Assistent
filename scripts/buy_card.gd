extends Button


@export var player:int
@export var card:int
@onready var manager = %Manager


func _on_pressed():
	manager.buycard(card, player)
