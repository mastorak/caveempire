extends Area2D

var mouse_over = false

var selected =false

export(int) var life=0
var max_life=100

var house_complete_texture = load("res://resources/structures/house.png")
var house_under_construction_texture = load("res://resources/structures/house-under-construction.png")

var barracks_complete_texture = load("res://resources/structures/castle.png")
var barracks_under_construction_texture = load("res://resources/structures/castle-under-construction.png")

var magetower_complete_texture = load("res://resources/structures/magetower.png")
var magetower_under_construction_texture = load("res://resources/structures/magetower-under-construction.png")

export(preload("res://src/util/Global.gd").TEAM) var team
export(preload("res://src/util/Global.gd").BUILDING_NAME) var building_name

var training_timer
var training_timer_timeout=30

var build_timer
var build_timer_timeout=2
var build_step=5

var training_queue=[]

var is_training=false

var object_under_training

signal training_started
signal training_ended
signal queue_changed

var completed_texture
var under_construction_texture
var changed_texture=false

var construction_workers=[]

var warrior_scene=load("res://src/unit/Warrior.tscn")
var mage_scene=load("res://src/unit/Mage.tscn")
var worker_scene=load("res://src/unit/Worker.tscn")

func _ready():
	add_to_group("buildings")
	selected=false
	connect("body_entered" , self, "_area_entered")
	connect("body_exited" , self, "_area_exited")
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited",  self, "_mouse_over", [false])
	
	
	if building_name==Global.BUILDING_NAME.HOUSE:
		completed_texture=house_complete_texture
		under_construction_texture=house_under_construction_texture
	elif building_name==Global.BUILDING_NAME.BARRACKS:
		completed_texture=barracks_complete_texture
		under_construction_texture=barracks_under_construction_texture
	elif building_name==Global.BUILDING_NAME.MAGETOWER:
		completed_texture=magetower_complete_texture
		under_construction_texture=magetower_under_construction_texture
		
	if(life<max_life):
		$UnselectedSprite.texture=under_construction_texture
		$ProgressBar.visible=true
	else:
		$UnselectedSprite.texture=completed_texture
		$ProgressBar.visible=false
		
	training_timer=Timer.new()
	training_timer.set_wait_time(training_timer_timeout)
	training_timer.connect("timeout",self,"_on_training_timer_timeout")
	add_child(training_timer)
	
	build_timer=Timer.new()
	build_timer.set_wait_time(build_timer_timeout)
	build_timer.connect("timeout",self,"_on_build_timer_timeout")
	add_child(build_timer)

	if life==max_life && building_name==Global.BUILDING_NAME.HOUSE:
		add_to_group("houses")

func _process(delta):
	check_selected()
	
	if is_training==false && training_queue.size()>0:
		train_unit(training_queue.pop_front())

	if changed_texture==false && life>=max_life:
		$UnselectedSprite.texture=completed_texture
		life=max_life
		changed_texture=true
		$ProgressBar.visible=false
		
		if building_name==Global.BUILDING_NAME.HOUSE:
			add_to_group("houses")
		elif building_name==Global.BUILDING_NAME.BARRACKS:
			add_to_group("barracks")
		elif building_name==Global.BUILDING_NAME.MAGETOWER:
			add_to_group("magetowers")
	else:
		$ProgressBar.value=life

	check_construction()
#set mouse_over from connected event
func _mouse_over(over):
	mouse_over = over
		
func _area_entered(object):
	if life<max_life && !object.is_class("TileMap") && object.is_unit() && object.is_worker():
		construction_workers.append(object)
		
	

func _area_exited(object):
	if !object.is_class("TileMap") && object.is_unit() && object.is_worker():
		construction_workers.erase(object)
		object.construct_building(false)

func check_construction():
	if life<max_life && construction_workers.size()>0:
		for i in construction_workers:
			i.construct_building(true)
		if build_timer.is_stopped():
			build_timer.start()
	elif life>=max_life && construction_workers.size()>0:
		for i in construction_workers:
			i.construct_building(false)
		build_timer.stop()
	else:
		build_timer.stop()
		
func _on_build_timer_timeout():
	life+=build_step

func check_selected():
	if selected:
		$UnselectedSprite.visible=false
		$SelectedSprite.visible=true
	else:
		$UnselectedSprite.visible=true
		$SelectedSprite.visible=false

func train_unit(object):
	object_under_training=object
	training_timer.start()
	is_training=true
	emit_signal("training_started")
	
	

func _on_training_timer_timeout():
	is_training=false
	training_timer.stop()
	
	var unit
	var unit_name
	if building_name ==Global.BUILDING_NAME.BARRACKS:
		unit = warrior_scene.instance()
		unit.position.x=self.position.x
		unit.position.y=self.position.y+50
		unit_name="Warrior"
	elif building_name ==Global.BUILDING_NAME.HOUSE:
		unit=worker_scene.instance()
		unit.position.x=self.position.x
		unit.position.y=self.position.y
		unit_name="Worker"
	elif building_name ==Global.BUILDING_NAME.MAGETOWER:
		unit=mage_scene.instance()
		unit.position.x=self.position.x
		unit.position.y=self.position.y+100
		unit_name="Mage"
		
	
	unit._setup_unit(Global.TEAM.PLAYER)
	unit.add_to_group("selectables")
	unit.add_to_group("friendlies")
	get_parent().add_child(unit)
	unit.move_to_position(Vector2(unit.global_position.x+100,unit.global_position.y))
	emit_signal("training_ended")
	Global.console_log(unit_name+" is ready")
	Global.global_queue_size-=1 # remove one from queue size for food check
	
func is_unit():
	return false

func is_building():
	return true
	
func can_be_selected():
	if life<max_life:
		return false
	else:
		return true

func get_training_progress():
	var time_passed=training_timer.wait_time-training_timer.time_left
	return time_passed*100/training_timer.wait_time

func add_to_queue(object):
	if Global.get_level().food-Global.global_queue_size>0 : # check that we have enough food to construct everything currently queued
		if training_queue.size()<2:
			var result=Global.can_build(Global.OBJECT_TYPE.UNIT,object)
			if result["ok"]==true:
				training_queue.push_back(object)
				Global.global_queue_size+=1  ##add to global queue size to check for food later
				emit_signal("queue_changed")
				Global.console_log(result["message"])
			else:
				Global.console_log(result["message"])
		else:
			Global.console_log("Queue limit reached") 
	else:
		Global.console_log("Food limit reached. Build more houses") 