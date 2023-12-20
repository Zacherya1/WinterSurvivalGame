extends InventoryData
class_name InventoryDataFeetEquip

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataFeetEquip:
		return grabbed_slot_data
	
	return super.drop_slot_data(grabbed_slot_data, index)

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataFeetEquip:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)
