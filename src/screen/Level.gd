extends Node2D


var gold
var rocks
var crystals
var food


var rock_counter
var gold_counter
var crystal_counter
var food_counter

var current_level

var top_panel

var dialogs

var level1_scene=load("res://src/level/Level1.tscn")
var level2_scene=load("res://src/level/Level2.tscn")

func _ready():
	rock_counter=get_node("../CanvasLayer/TopPanel/RockCounter/NumberOfItems")
	crystal_counter=get_node("../CanvasLayer/TopPanel/CrystalCounter/NumberOfItems")
	gold_counter=get_node("../CanvasLayer/TopPanel/GoldCounter/NumberOfItems")
	food_counter=get_node("../CanvasLayer/TopPanel/FoodCounter/NumberOfItems")
	top_panel=get_node("../CanvasLayer/TopPanel")
	dialogs=get_node("../CanvasLayer/Dialogs")
	current_level=get_children()[0]
	reset_level()	
		
func reset_level():
	gold=0
	rocks=0
	crystals=0
	food=0
	load_level_properties()
	get_tree().paused = true
	top_panel.clear_objectives()
	

func victory():
	
	if(current_level.get_name()=='Level1'):
		Global.properties["campaign"]["level"]="level2"
		Global.save_properties()
	if(current_level.get_name()=='Level2'):
		Global.properties["campaign"]["level"]="level3"
		Global.save_properties()	
		
	get_tree().paused = true
	get_node("../CanvasLayer/Dialogs/LevelEnd").visible=true
	

func load_level_properties():
		
	print("load " +current_level.get_name())
	var level_size=calculate_tilemap_size(current_level.get_node("WallTileMap"))
	Global.camera_limits=level_size

func _process(delta):
	
	top_panel.update_objectives(current_level.get_objectives())
	
	rock_counter.text=String(rocks)
	gold_counter.text=String(gold)
	crystal_counter.text=String(crystals)
	
	var selectables=get_tree().get_nodes_in_group("selectables")
	var houses=get_tree().get_nodes_in_group("houses")
	food_counter.text=String(selectables.size())+"/"+ String(houses.size()*4)
	food=(houses.size()*4)-selectables.size()

func calculate_tilemap_size(tilemap):
    # Get list of all positions where there is a tile
    var used_cells = tilemap.get_used_cells()

    # If there are none, return null result
    if used_cells.size() == 0:
        return {x=0, y=0, width=0, height=0}

    # Take first cell as reference
    var min_x = used_cells[0].x
    var min_y = used_cells[0].y
    var max_x = min_x
    var max_y = min_y

    # Find bounds
    for i in range(1, used_cells.size()):

        var pos = used_cells[i]

        if pos.x < min_x:
            min_x = pos.x
        elif pos.x > max_x:
            max_x = pos.x

        if pos.y < min_y:
            min_y = pos.y
        elif pos.y > max_y:
            max_y = pos.y

    # Return resulting bounds
    return {
        x = min_x*32,
        y = min_y*32,
        width = (max_x - min_x + 1)*tilemap.cell_size.x,
        height = (max_y - min_y + 1)*tilemap.cell_size.y
    }	

func _on_OkButton_pressed():
	get_node("../CanvasLayer/Dialogs/LevelIntro").visible=false
	get_tree().paused = false

func load_intro_text(intro_text,button_text):
	dialogs=get_node("../CanvasLayer/Dialogs")
	dialogs.get_node("LevelIntro/IntroText").text=intro_text
	dialogs.get_node("LevelIntro/OkButton/Label").text= button_text

func load_end_text(end_text,button_text):
	dialogs=get_node("../CanvasLayer/Dialogs")
	dialogs.get_node("LevelEnd/EndText").text=end_text
	dialogs.get_node("LevelEnd/EndButton/Label").text= button_text	


func _on_EndButton_pressed():
	
	if current_level.get_name()=="Level2":
		Global.go_to_main_menu()
	else:	
		load_level()

func load_level():
	var new_level_number=Global.get_next_level()
	print("new level:"+new_level_number)
	var new_level
	if new_level_number=="level1":
		new_level=level1_scene.instance()
	elif new_level_number=="level2":
		new_level=level2_scene.instance()
	
	Global.clear_building_info()
	current_level.queue_free()
	add_child(new_level)
	current_level=new_level
	reset_level()

	dialogs=get_node("../CanvasLayer/Dialogs")
	dialogs.get_node("LevelEnd").visible=false
	dialogs.get_node("LevelIntro").visible=true