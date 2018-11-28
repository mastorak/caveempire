extends TextureRect

var prost_font=load("res://resources/fonts/ProstFont16.res")
var yatra_font=load("res://resources/fonts/YatraOne16.res")

var objectives_container

func _ready():
	objectives_container = get_node("ObjectivesContainer")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func clear_objectives():
	if objectives_container!=null:
		for i in objectives_container.get_children():
			i.queue_free()


func update_objectives(objectives):
	
#	for child in objectives_container.get_children():
#		child.queue_free()
	
	if objectives_container.get_children().size()==0:
		for i in objectives:
			var label=Label.new()
			label.text=i[0]
			label.add_font_override("font",yatra_font)
			objectives_container.add_child(label)
	
	else:
		for i in range(0, objectives.size()):
			if objectives[i][1]==true:
				objectives_container.get_child(i).set("custom_colors/font_color",Color(0,1,0))
			
				
		

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
