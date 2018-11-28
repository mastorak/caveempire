extends HBoxContainer

var barracks_icon=preload("res://resources/ui/icons/barracks-icon.png")
var house_icon=preload("res://resources/ui/icons/house-icon.png")
var magetower_icon=preload("res://resources/ui/icons/magetower-icon.png")

var warrior_icon=preload("res://resources/ui/icons/knight-icon.png")
var mage_icon=preload("res://resources/ui/icons/mage-icon.png")
var worker_icon=preload("res://resources/ui/icons/worker-icon.png")

var current_building
var unit_icon
var training_bar
var training_queue_container
var build_button

func _ready():
	load_nodes()
	
func _process(delta):
	if current_building!=null && current_building.is_training:
		training_bar.visible=true
		training_bar.value=current_building.get_training_progress()
	else:
		training_bar.visible=false

func load_nodes():
	unit_icon=get_node("ConstructionInfoContainer/CurrentConstructionContainer/UnitIcon")
	training_bar=get_node("ConstructionInfoContainer/CurrentConstructionContainer/ConstructionBar")
	training_queue_container=get_node("ConstructionInfoContainer/ConstructionQueueContainer")
	#build_button=get_node("BuildButton")
	
func load_building_info(building):
	load_nodes()
	current_building=building
	var building_icon=get_node("BasicInfoContainer/BuildingIcon")
	var name_label=get_node("BasicInfoContainer/Name")
		
	building.connect("training_started",self, "_on_training_started")
	building.connect("training_ended",self, "_on_training_ended")
	building.connect("queue_changed",self, "_on_queue_changed")
		
	if building.building_name==Global.BUILDING_NAME.HOUSE:
		name_label.text= "House"
		building_icon.texture=house_icon
		Global.update_description("Allows the training of workers. Each house produces 4 food")
	elif building.building_name==Global.BUILDING_NAME.BARRACKS:
		name_label.text= "Barracks"
		building_icon.texture=barracks_icon
		Global.update_description("Allows the training of warriors")
	elif building.building_name==Global.BUILDING_NAME.MAGETOWER:
		building_icon.texture=magetower_icon
		name_label.text= "Mage Tower"
		Global.update_description("Allows the training of mages")

	update_training_info()

func _on_training_started():
	update_training_info()

func _on_training_ended():
	update_training_info()

func _on_queue_changed():
	update_training_info()

func update_training_info():
		
	for child in training_queue_container.get_children():
		child.queue_free()
	
	if current_building.is_training:
		if current_building.object_under_training==Global.UNIT_NAME.WARRIOR:
			unit_icon.texture=warrior_icon
		elif current_building.object_under_training==Global.UNIT_NAME.WORKER:
			unit_icon.texture=worker_icon
		elif current_building.object_under_training==Global.UNIT_NAME.MAGE:
			unit_icon.texture=mage_icon
	else:
		unit_icon.texture=null
		
	if(current_building.training_queue.size()>0):
		for i in current_building.training_queue:
			var itemIcon=TextureRect.new()
			if i==Global.UNIT_NAME.WARRIOR:
				itemIcon.texture=warrior_icon
				itemIcon.margin_top=20
			elif i==Global.UNIT_NAME.WORKER:
				itemIcon.texture=worker_icon
				itemIcon.margin_top=28
			elif i==Global.UNIT_NAME.MAGE:
				itemIcon.texture=mage_icon
				itemIcon.margin_top=20
			training_queue_container.add_child(itemIcon)
			training_queue_container.margin_top=25
			