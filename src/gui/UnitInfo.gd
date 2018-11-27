extends HBoxContainer

var warrior_icon=preload("res://resources/ui/icons/knight-icon.png")
var mage_icon=preload("res://resources/ui/icons/mage-icon.png")
var worker_icon=preload("res://resources/ui/icons/worker-icon.png")

var current_unit
var unit_icon


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func load_nodes():
	pass

func load_multi_units(units):
	
	clear_unit_info()
	
	if(units.size()>0):
		for i in units:
			var itemIcon=TextureRect.new()
			if i.unit_name==Global.UNIT_NAME.WARRIOR:
				itemIcon.texture=warrior_icon
				itemIcon.margin_top=20
			elif i.unit_name==Global.UNIT_NAME.WORKER:
				itemIcon.texture=worker_icon
				itemIcon.margin_top=28
			elif i.unit_name==Global.UNIT_NAME.MAGE:
				itemIcon.texture=mage_icon
				itemIcon.margin_top=20
			$MultiUnitContainer.add_child(itemIcon)
			$MultiUnitContainer.margin_top=25
	
func clear_unit_info():
	var unit_icon=get_node("BasicInfoContainer/UnitIcon")
	var name_label=get_node("BasicInfoContainer/Name")
	
	unit_icon.texture=null
	name_label.text=""
	Global.update_description("")
	for child in $MultiUnitContainer.get_children():
		$MultiUnitContainer.remove_child(child)
	
	
func load_unit_info(unit):
	current_unit=unit
	var unit_icon=get_node("BasicInfoContainer/UnitIcon")
	var name_label=get_node("BasicInfoContainer/Name")
		
	if current_unit.unit_name==Global.UNIT_NAME.WARRIOR:
		unit_icon.texture=warrior_icon
		name_label.text="Warrior"
		Global.update_description("Sword wielding melee unit ")
	elif current_unit.unit_name==Global.UNIT_NAME.MAGE:
		unit_icon.texture=mage_icon
		name_label.text="Mage"
		Global.update_description("A mage can cast offensive spells from a distance ")
	elif current_unit.unit_name==Global.UNIT_NAME.WORKER:
		unit_icon.texture=worker_icon
		name_label.text="Worker"
		Global.update_description("Can gather resources and construct house, barracks and mage tower")