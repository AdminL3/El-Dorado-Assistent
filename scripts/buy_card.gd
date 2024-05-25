extends Button


@export var player:int
@export var shopcard:int
@onready var manager = %Manager


func _on_pressed():
	manager.buycard(shopcard, player)
