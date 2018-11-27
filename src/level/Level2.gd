extends Node2D

var objectives=[]

func _ready():
	Global.reset_camera()
	objectives.push_back(["-Build Mage Tower",false])
	objectives.push_back(["-Bring a Mage to Dark Portal",false])
	
	var intro_text="My lord, \n The strange construction apears to be some sort of portal. Build a Mage Tower and  bring a mage to the portal to destroy it. \n \n Be on alert. Reports have arrived that the orcs have found some old entrance near our base and may try to slip in a small force. "
	var intro_button_text="To battle!"

	var end_text="Victory! \n \n You have destroyed the Dark Portal. The Orcs will not be able to bring their armies through it. \n \n The empire is safe for now."
	var end_button_text="End"

	get_parent().load_intro_text(intro_text,intro_button_text)
	get_parent().load_end_text(end_text,end_button_text)

	print("Loading level")
	

func _process(delta):
	check_victory_conditions()

func check_victory_conditions():
	
	var towers=get_tree().get_nodes_in_group("magetowers")
	
	if towers.size()>0:
		objectives[0][1]=true
	else:
		objectives[0][1]=false

	if $DarkPortal.mage_in_portal==true:
		objectives[1][1]=true
	else:
		objectives[1][1]=false

	if objectives[0][1]==true && objectives[1][1]==true:
		get_parent().victory()

func get_objectives():

	return objectives