extends HBoxContainer

var house_scene=load("res://src/structure/House.tscn")
var barracks_scene=load("res://src/structure/Barracks.tscn")
var magetower_scene=load("res://src/structure/MageTower.tscn")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_PatrolButton_pressed():
	pass # replace with function body


func _on_DisbandButton_pressed():
	pass # replace with function body

func _on_BuildUnitButton_pressed():
	Global.panel_input=true #dont trigger unit movement
	var buildings=get_tree().get_nodes_in_group("buildings")
	for i in buildings:
		if i.selected==true:
			if i.building_name==Global.BUILDING_NAME.BARRACKS:
				i.add_to_queue(Global.UNIT_NAME.WARRIOR)
			elif i.building_name==Global.BUILDING_NAME.HOUSE:
				i.add_to_queue(Global.UNIT_NAME.WORKER)
			elif i.building_name==Global.BUILDING_NAME.MAGETOWER:
				i.add_to_queue(Global.UNIT_NAME.MAGE)



func _on_ConstructHouse_pressed():
	construct_building(Global.BUILDING_NAME.HOUSE)
	

func _on_ConstructBarracks_pressed():
	construct_building(Global.BUILDING_NAME.BARRACKS)

func _on_ConstructMageTower_pressed():
	construct_building(Global.BUILDING_NAME.MAGETOWER)	
	
func construct_building(building_name):
	Global.panel_input=true #dont trigger unit movement
	
	var result=Global.can_build(Global.OBJECT_TYPE.BUILDING,building_name)
	if result["ok"]==true:
		var building
		if building_name==Global.BUILDING_NAME.HOUSE:
			building =house_scene.instance()
		elif building_name==Global.BUILDING_NAME.BARRACKS:
			building =  barracks_scene.instance()
		elif building_name==Global.BUILDING_NAME.MAGETOWER:
			building = magetower_scene.instance()
			
		var command_unit= get_tree().get_root().get_node("/root/GameScreen").command_object
		building.add_to_group("buildings")
		
		var unit_extent=command_unit.get_node("CollisionShape2D").shape.extents.y
		var building_extent=building.get_node("CollisionShape2D").shape.extents.y
		
		building.z_index=command_unit.z_index-1
		building.global_position=command_unit.global_position
		if building.building_name==Global.BUILDING_NAME.HOUSE:
			building.global_position.y=building.global_position.y+3
		elif building.building_name==Global.BUILDING_NAME.BARRACKS:
			building.global_position.y=building.global_position.y-(building_extent-unit_extent)+4
		elif building.building_name==Global.BUILDING_NAME.MAGETOWER:
			building.global_position.y=building.global_position.y-building_extent-(unit_extent/2)+8
			
		command_unit.get_parent().add_child(building)
		Global.console_log(result["message"])
	else:
		Global.console_log(result["message"]) 

func _on_BuildUnitButton_mouse_entered():
	var buildings=get_tree().get_nodes_in_group("buildings")
	for i in buildings:
		if i.selected==true:
			if i.building_name==Global.BUILDING_NAME.BARRACKS:
				Global.console_log("Warrior costs "+Global.create_cost_message(Global.warrior_cost))
			elif i.building_name==Global.BUILDING_NAME.HOUSE:
				Global.console_log("Worker costs "+Global.create_cost_message(Global.worker_cost))
			elif i.building_name==Global.BUILDING_NAME.MAGETOWER:
				Global.console_log("Mage costs "+Global.create_cost_message(Global.mage_cost))


func _on_BuildUnitButton_mouse_exited():
	pass


func _on_ConstructHouse_mouse_entered():
	Global.console_log("House costs "+Global.create_cost_message(Global.house_cost))


func _on_ConstructBarracks_mouse_entered():
	Global.console_log("Barracks cost "+Global.create_cost_message(Global.barracks_cost))


func _on_ConstructMageTower_mouse_entered():
	Global.console_log("Mage Tower costs "+Global.create_cost_message(Global.magetower_cost))
