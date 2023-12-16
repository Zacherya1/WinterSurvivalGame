extends ItemData
class_name ItemDataConsumable

@export var hunger_value: int

func use(target) -> void:
	if hunger_value != 0:
		target.eat(hunger_value)
