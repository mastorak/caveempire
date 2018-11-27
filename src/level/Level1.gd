extends Node2D

var objectives=[]

func _ready():
	Global.reset_camera()
	objectives.push_back(["-Build 3 houses",false])
	objectives.push_back(["-Build barracks",false])
	objectives.push_back(["-Have 5 warriors",false])
	
	var intro_text="My lord, the Orcs have pushed further into our caverns. We do not know what drives them yet. The emperor commands you to prepare our forces for war. \n \n Strengthen our garrison by building barracks to train new recruits and increase our food production to support the troops coming to the front.\n \nThe empire depends on us to succeed in our mission."
	var intro_button_text="To war!"
	
	var end_text="Excellent work my Lord, \n You have managed to strengthen our position. No time to celebrate though. Troubling reports are coming in. \n \n It seems that the orcs have build a strange construction. We need to investigate immediately."
	var end_button_text="Proceed"
	
	get_parent().load_intro_text(intro_text,intro_button_text)
	get_parent().load_end_text(end_text,end_button_text)
	
	print("Loading level")
	
func _process(delta):
	check_victory_conditions()

func check_victory_conditions():
	var houses=get_tree().get_nodes_in_group("houses")
	var barracks=get_tree().get_nodes_in_group("barracks")
	var warriors=get_tree().get_nodes_in_group("warriors")
	
#	if (houses.size()>2 && barracks.size()>0 && warriors.size()>3):
#		get_parent().victory()

	if houses.size()>2:
		objectives[0][1]=true
	else:
		objectives[0][1]=false

	if barracks.size()>0:
		objectives[1][1]=true
	else:
		objectives[1][1]=false
		
	if warriors.size()>4:
		objectives[2][1]=true
	else:
		objectives[2][1]=false
		
		
	if objectives[0][1]==true && objectives[1][1]==true && objectives[2][1]==true:
		get_parent().victory()
		
func get_objectives():
		
	return objectives