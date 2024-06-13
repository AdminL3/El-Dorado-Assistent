extends Button

@export var index: int = -1

func _on_pressed():
	var node = get_tree().root.get_node("Game")
	node.call("card_pressed", index)
