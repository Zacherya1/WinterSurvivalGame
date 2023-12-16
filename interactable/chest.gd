extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

func player_interact(body: Node3D) -> void:
	toggle_inventory.emit(self)
