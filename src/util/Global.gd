extends Node


enum TEAM{PLAYER,ENEMY}
enum UNIT_NAME{WORKER,WARRIOR,ORC,MAGE,GOBLIN,NECROMANCER}
enum UNIT_TYPE{MELEE,RANGED}
enum BUILDING_NAME{BARRACKS,MAGETOWER,HOUSE}
enum RESOURCE_NAME{GOLD,ROCK,CRYSTAL}
enum OBJECT_TYPE{UNIT,BUILDING}
enum DIRECTION{UP,DOWN,RIGHT,LEFT,CENTER}

var panel_input=false

var console_node
var description_node
var console_timer
var console_timer_timeout=3

var worker_cost={"gold":20,"rock":0,"crystal":0,"food":1}
var warrior_cost={"gold":50,"rock":0,"crystal":0,"food":1}
var mage_cost={"gold":30,"rock":0,"crystal":50,"food":1}

var barracks_cost={"gold":50,"rock":100,"crystal":0,"food":0}
var house_cost={"gold":30,"rock":30,"crystal":0,"food":0}
var magetower_cost={"gold":100,"rock":50,"crystal":100,"food":0}

var global_queue_size=0

var camera_limits


const properties_path="res://properties.cfg"
var properties_file= ConfigFile.new()
var properties = {
	"campaign": {
		"level":"level1"
	}
}	

func _ready():
	#console_node= get_tree().get_root().get_node("/root/GameScreen/CanvasLayer/BottomPanel/HSplitContainer/ConsolePanel/Label")
	#description_node = get_tree().get_root().get_node("/root/GameScreen/CanvasLayer/BottomPanel/Description")
	console_timer=Timer.new()
	console_timer.set_wait_time(console_timer_timeout)
	console_timer.connect("timeout",self,"_on_console_timer_timeout")
	add_child(console_timer)
	load_properties()

func console_log(text):
	console_timer.stop()
	console_set_text(text)
	console_timer.start()

func console_set_text(text):
	if console_node==null:
		console_node= get_tree().get_root().get_node("/root/GameScreen/CanvasLayer/BottomPanel/HSplitContainer/ConsolePanel/Label")
	console_node.text=text

func clear_building_info():
	var building_info= get_tree().get_root().get_node("/root/GameScreen/CanvasLayer/BottomPanel/HSplitContainer/InfoContainer/BuildingInfo")
	building_info.current_building=null
	
func update_description(text):
	if description_node==null:
		 description_node = get_tree().get_root().get_node("/root/GameScreen/CanvasLayer/BottomPanel/Description")
	description_node.text=text
	
func _on_console_timer_timeout():
	console_timer.stop()
	if get_tree().get_current_scene().get_name()=="GameScreen":
		console_set_text("")
		

func reset_camera():
	var camera =get_tree().get_root().get_node("/root/GameScreen/LevelViewport")	
	camera.position=Vector2(0,0)
	
func get_level():
	return	get_tree().get_root().get_node("/root/GameScreen/Level")
	
func can_build(type, object):
	var cost_to_check
	var object_name
	var result={"ok":false,"message":"this is the build check message"}
	if type==OBJECT_TYPE.UNIT:
		if object==UNIT_NAME.WARRIOR:
			cost_to_check=warrior_cost
			object_name="Warrior"
		elif object==UNIT_NAME.WORKER:
			cost_to_check=worker_cost
			object_name="Worker"
		elif object==UNIT_NAME.MAGE:
			cost_to_check=mage_cost
			object_name="Mage"
	elif type==OBJECT_TYPE.BUILDING:
		if object==BUILDING_NAME.HOUSE:
			cost_to_check=house_cost
			object_name="House"
		elif object==BUILDING_NAME.BARRACKS:
			cost_to_check=barracks_cost
			object_name="Barracks"
		elif object==BUILDING_NAME.MAGETOWER:
			cost_to_check=magetower_cost
			object_name="Mage Tower"
	
	if get_level().gold>=cost_to_check["gold"] && get_level().rocks>=cost_to_check["rock"] && get_level().crystals>=cost_to_check["crystal"] && get_level().food>=cost_to_check["food"]:
		result["ok"]=true
		result["message"]=object_name+" added in queue"
		get_level().gold-=cost_to_check["gold"]
		get_level().rocks-=cost_to_check["rock"]
		get_level().crystals-=cost_to_check["crystal"]
	else:	
		result["ok"]=false
		result["message"]=object_name+" requires "+create_cost_message(cost_to_check)
	
	return result

func create_cost_message(cost_to_check):
	var cost_message=""
	if cost_to_check["gold"]>0:
		cost_message+=" Gold:"+String(cost_to_check["gold"])
	if cost_to_check["rock"]>0:
		cost_message+=" Rocks:"+String(cost_to_check["rock"])
	if cost_to_check["crystal"]>0:
		cost_message+=" Crystals:"+String(cost_to_check["crystal"])
	if cost_to_check["food"]>0:
		cost_message+=" Food:"+String(cost_to_check["food"])
	return cost_message		

func go_to_game_screen():
	get_tree().change_scene("res://src/screen/GameScreen.tscn")
		
	

func go_to_main_menu():
	get_tree().change_scene("res://src/screen/MainMenuScreen.tscn")
	get_tree().paused = false

func save_properties():
	for section in properties.keys():
		for key in properties[section]:
			properties_file.set_value(section,key,properties[section][key])
	properties_file.save(properties_path)

func load_properties():
	var result = properties_file.load(properties_path)	
	if result!=OK:
		print("failed loading properties file")
		
func get_next_level():
	return properties["campaign"]["level"]
	
func load_level():
	get_level().load_level()