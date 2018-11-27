extends Node2D

var game_screen_scene=load("res://src/screen/GameScreen.tscn")

func _ready():
	var time = OS.get_date()
	var year = time["year"]

	var copyright= get_node("About/CopyrightContainer/copyright")
	copyright.text="© Kostis Mastorakis "+str(year)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _input(event):
	if (event is InputEventKey ||  event is InputEventMouseButton ) && $Anykey.visible==true:
		if event.pressed:
			$Anykey.visible=false
			$MainMenu.visible=true


func _on_QuitButton_pressed():
	get_tree().quit()



func _on_StartButton_pressed():
	Global.go_to_game_screen()


func _on_AboutButton_pressed():
	$MainMenu.visible=false
	$About.visible=true


func _on_CloseAboutButton_pressed():
	$About.visible=false
	$MainMenu.visible=true
