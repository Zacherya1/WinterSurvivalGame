extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

var display_type: String = "\n[E] Open"
@export var display_text: String
@export var inventory_data: InventoryData

func player_interact(body: Node3D) -> void:
	toggle_inventory.emit(self)
