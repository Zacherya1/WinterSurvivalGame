extends Node3D

#add this for every item that can be dropped in the game
#yes, this will end up being massive
const PickUpBeans = preload("res://item/pick_up/pick_up_beans.tscn")
const Beans = preload("res://item/items/Beans.tres")
const PickUpHide = preload("res://item/pick_up/pick_up_hide.tscn")
const HideScrap = preload("res://item/items/ScrapHide.tres")

@onready var inventory_interface = $UI/InventoryInterface
@onready var player = $Player


func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_chest_equip_inventory_data(player.chest_equip_inventory_data)
	inventory_interface.set_head_equip_inventory_data(player.head_equip_inventory_data)
	inventory_interface.set_feet_equip_inventory_data(player.feet_equip_inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data) -> void:
	var pick_up
	#again, add this for every item to be dropped
	match slot_data.item_data:
		Beans:
			AudioManager.MetalDrop()
			pick_up = PickUpBeans.instantiate()
		HideScrap:
			print("test")
			AudioManager.SoftDrop()
			pick_up = PickUpHide.instantiate()
	print(slot_data.item_data.name)
	#pick_up = PickUpHide.instantiate()
	print(pick_up)
	
	pick_up.position = player.get_drop_position()
	add_child(pick_up) 
	
	
