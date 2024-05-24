extends Button


@export var player:int



func _on_pressed():
	Manager.draw(player)
