extends RigidBody3D

#@export var sound_type: 
@export_flags("Metal", "Soft") var sound_effect = 0

var display_type: String = "[E] Take"
@export var display_text: String
@export var slot_data: SlotData

func player_interact(body: Node3D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		match sound_effect:
			1:
				#Metal
				AudioManager.MetalPickUp()
			2: 
				#Cloth
				AudioManager.SoftPickUp()
		queue_free()
	
