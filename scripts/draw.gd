extends Button


@export var player:int
@onready var manager = %Manager


func _on_pressed():
	manager.draw(player)
