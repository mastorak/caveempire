extends Area2D


export(preload("res://src/util/Global.gd").RESOURCE_NAME) var resource_name

var gold_full_texture = load("res://resources/items/gold-full.png")
var gold_empty_texture = load("res://resources/items/gold-empty.png")

var rocks_full_texture = load("res://resources/items/rock-full.png")
var rocks_empty_texture = load("res://resources/items/rock-empty.png")

var crystals_full_texture = load("res://resources/items/crystal-full.png")
var crystals_empty_texture = load("res://resources/items/crystal-empty.png")

var full_texture
var empty_texture

export(int) var init_value=50
var value
var value_step=5

var changed_texture=false

var gather_timer
var gather_timer_timeout=2
var resource_counter

var chiching_scene=load("res://src/gui/ChiChing.tscn")

var construction_workers=[]

func _ready():
	connect("body_entered" , self, "_area_entered")
	connect("body_exited" , self, "_area_exited")
	
	connect("mouse_entered" , self, "_mouse_entered")
	connect("mouse_exited" , self, "_mouse_exited")
	
	value=init_value
	if resource_name==Global.RESOURCE_NAME.GOLD:
		full_texture=gold_full_texture
		empty_texture=gold_empty_texture
		resource_counter=get_tree().get_root().get_node("/root/GameScreen/Level").gold
	elif resource_name==Global.RESOURCE_NAME.ROCK:
		full_texture=rocks_full_texture
		empty_texture=rocks_empty_texture
		resource_counter=get_tree().get_root().get_node("/root/GameScreen/Level").rocks
	elif resource_name==Global.RESOURCE_NAME.CRYSTAL:
		full_texture=crystals_full_texture
		empty_texture=crystals_empty_texture
		resource_counter=get_tree().get_root().get_node("/root/GameScreen/Level").crystals
	
	$Sprite.texture=full_texture
	
	gather_timer=Timer.new()
	gather_timer.set_wait_time(gather_timer_timeout)
	gather_timer.connect("timeout",self,"_on_gather_timer_timeout")
	add_child(gather_timer)
	$Label.visible=false
		

func _mouse_entered():
	$Label.visible=true
	
func _mouse_exited():
	$Label.visible=false
	
	
func _area_entered(object):
	if !object.is_class("TileMap") && object.is_unit() && object.is_worker():
		construction_workers.append(object)
		gather_timer.start()

func _area_exited(object):
	if !object.is_class("TileMap") && object.is_unit() && object.is_worker():
		construction_workers.erase(object)
		object.gather_resource(false)
		gather_timer.stop()	


func check_gathering():
	if construction_workers.size()>0:
		for i in construction_workers:
			i.gather_resource(true)
		if gather_timer.is_stopped():
			gather_timer.start()
	elif construction_workers.size()>0:
		for i in construction_workers:
			i.gather_resource(false)
		gather_timer.stop()
	else:
		gather_timer.stop()

func _process(delta):
	$Label.text=String(value)
	#if is less than half draw empty resource sprite
	if	value<=init_value/2 && changed_texture==false:
		$Sprite.texture=empty_texture
		changed_texture=true
	
	check_gathering()
		
func _on_gather_timer_timeout():
	if value>0:
		value-=value_step
		if resource_name==Global.RESOURCE_NAME.GOLD:
			get_tree().get_root().get_node("/root/GameScreen/Level").gold+=value_step
		elif resource_name==Global.RESOURCE_NAME.ROCK:
			get_tree().get_root().get_node("/root/GameScreen/Level").rocks+=value_step
		elif resource_name==Global.RESOURCE_NAME.CRYSTAL:
			get_tree().get_root().get_node("/root/GameScreen/Level").crystals+=value_step
		
		var chiching =chiching_scene.instance()
		chiching.setup(global_position,String(value_step),resource_name)
		get_parent().add_child(chiching)
		
	if value<=0:
		queue_free()	