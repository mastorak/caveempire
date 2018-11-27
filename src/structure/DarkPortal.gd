extends Area2D


var mage_in_portal=false


func _ready():
	connect("body_entered" , self, "_area_entered")
	connect("body_exited" , self, "_area_exited")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _area_entered(object):
	if !object.is_class("TileMap") && object.is_unit() && object.is_mage():
		mage_in_portal=true
		
	

func _area_exited(object):
	pass
