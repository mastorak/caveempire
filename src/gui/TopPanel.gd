extends TextureRect

var prost_font=load("res://resources/fonts/ProstFont16.res")
var yatra_font=load("res://resources/fonts/YatraOne16.res")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func update_objectives(objectives):
	var objectives_container=get_node("ObjectivesContainer")
	for child in objectives_container.get_children():
		objectives_container.remove_child(child)
	
	for i in objectives:
		var label=Label.new()
		label.text=i[0]
		label.add_font_override("font",yatra_font)
		
		if i[1]==true:
			label.set("custom_colors/font_color",Color(0,1,0))
		objectives_container.add_child(label)
			
	

func _on_MenuButton_pressed():
	if $Menu.visible==false:
		$Menu.visible=true
		get_tree().paused = true
	else:
		$Menu.visible=false
		get_tree().paused = false


func _on_CloseButton_pressed():
	$Menu.visible=false
	get_tree().paused = false


func _on_QuitButton_pressed():
	Global.go_to_main_menu()


func _on_RestartButton_pressed():
	Global.load_level()
	$Menu.visible=false
	
	var game_screen=get_tree().get_root().get_node("/root/GameScreen")
	game_screen.clear_bottom_panel()
