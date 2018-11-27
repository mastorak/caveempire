extends Node2D

var velocity=Vector2(0,-150)
var orig_position
var launch=false

var gold_icon = load("res://resources/ui/icons/gold-icon.png")
var rock_icon = load("res://resources/ui/icons/rock-icon.png")
var crystal_icon = load("res://resources/ui/icons/crystal-icon.png")
var icon

func _ready():
	pass

func setup(orig_pos,text,resource_name):
	orig_position=orig_pos
	global_position=orig_position
	launch=true
	$Label.text="+"+text
	if resource_name==Global.RESOURCE_NAME.GOLD:
		icon=gold_icon
	elif resource_name==Global.RESOURCE_NAME.ROCK:	
		icon=rock_icon
	elif resource_name==Global.RESOURCE_NAME.CRYSTAL:
		icon=crystal_icon
	
	$Sprite.texture=icon
		
func _process(delta):
	if launch:
		global_position=global_position+velocity*delta
		if global_position.y<orig_position.y-200:
			queue_free()
