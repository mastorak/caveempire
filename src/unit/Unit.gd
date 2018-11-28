extends KinematicBody2D

enum ACTION{MOVE,IDLE}

export(preload("res://src/util/Global.gd").UNIT_TYPE) var unit_type
export(preload("res://src/util/Global.gd").UNIT_NAME) var unit_name
export(preload("res://src/util/Global.gd").TEAM) var team

export(int) var life=100

var fight_distance

var speed = 5000
var velocity =Vector2()

const GRAVITY=2000
const MAX_GRAVITY=20000
const FLOOR_UP_FORCE=Vector2(0,-1)

var selected=false

var action =ACTION.IDLE
var target_coords=Vector2()

var mouse_over = false

var on_top_of_resource=false
var on_top_of_construction=false

var override_timer
var override_timer_timeout=1

func _setup_unit(team):
	self.team=team

var override_fight=false	

func _ready():
	add_to_group("destructuble")	
	#set groups and collision bits for friendlies and enemies
	if team==Global.TEAM.PLAYER:
		add_to_group("selectables")
		add_to_group("friendlies")
		set_collision_layer_bit(0,true)
		set_collision_layer_bit(1,false)
		set_collision_mask_bit(1,true)
		set_collision_mask_bit(0,false)
	elif team==Global.TEAM.ENEMY:
		#add_to_group("selectables")
		add_to_group("enemies")
		set_collision_layer_bit(1,true)
		set_collision_layer_bit(0,false)
		set_collision_mask_bit(0,true)
		set_collision_mask_bit(1,false)
	
	set_collision_mask_bit(3,true)
	set_collision_mask_bit(4,false)
	
	
	#change distance that gets into the fight depending on the unit type
	if unit_type==Global.UNIT_TYPE.MELEE:
		fight_distance=200
	elif unit_type==Global.UNIT_TYPE.RANGED:
		fight_distance=250	
	
	if unit_name==Global.UNIT_NAME.WARRIOR:
		add_to_group("warriors")
	elif unit_name==Global.UNIT_NAME.WORKER:
		add_to_group("workers")
	elif unit_name==Global.UNIT_NAME.MAGE:
		add_to_group("mages")	
	
	
	$LifeBar.max_value=life
			
	#Check to see if the mouse cursor is on top of the shape of the object
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited",  self, "_mouse_over", [false])
	
	override_timer=false
	override_timer=Timer.new()
	override_timer.set_wait_time(override_timer_timeout)
	override_timer.connect("timeout",self,"_on_override_timer_timeout")
	add_child(override_timer)	
	
#set mouse_over from connected event
func _mouse_over(over):
	mouse_over = over
	print(mouse_over)


func _on_override_timer_timeout():
	override_fight=false
	override_timer.stop()
		
func _process(delta):
	draw_and_animate_human()
	check_fight()
	if unit_name==Global.UNIT_NAME.WORKER:
		check_working()
	$LifeBar.value=life	

func _physics_process(delta):
	if action==ACTION.MOVE:		
		move(delta)
	apply_gravity(delta)
	move_and_slide(velocity,FLOOR_UP_FORCE,5,4,1.0472)


func manage_collision_layers():
	#if we go higher all lower we use the slide
	if target_coords.y>global_position.y+100 || target_coords.y<global_position.y-100:
		set_collision_mask_bit(4,true)
	else:
		set_collision_mask_bit(4,false)


func apply_gravity(delta):
	if is_on_floor():
		velocity.y=0
	else:
		if velocity.y<MAX_GRAVITY:	
			velocity.y+=GRAVITY*delta #if we haven't reached max gravity then accelerate
		else:
			velocity.y=MAX_GRAVITY #fall in max gravity	

func move(delta):
	if(target_coords.x>global_position.x+1):
		velocity.x=speed * delta
		$Weapon.change_direction()
	elif(target_coords.x<global_position.x-1):
		velocity.x=-speed * delta
		$Weapon.change_direction()
	else:
		velocity.x=0
		action=ACTION.IDLE

func move_to_position(pos):
	target_coords=pos
	action=ACTION.MOVE

func check_fight():
	$Weapon.in_fight=false
	var units
	if team==Global.TEAM.PLAYER:
		units=get_tree().get_nodes_in_group("enemies")
	elif team==Global.TEAM.ENEMY:
		units=get_tree().get_nodes_in_group("friendlies")

	var unit_to_attack

	for i in units:
		#check distance to see if we can get in fight mode
		if i.global_position.distance_to(self.global_position)<fight_distance:
			#check direction we are facing. If we face enemy we can be in fight mode, else we cannot
			if i.global_position.x>self.global_position.x && $AnimatedSprite.flip_h==false:
				$Weapon.in_fight=true
				unit_to_attack=i
			elif i.global_position.x>self.global_position.x && $AnimatedSprite.flip_h==true:
				$Weapon.in_fight=true
				unit_to_attack=i
				if is_ranged(): # if it is ranged turn to face the enemy
					target_coords=Vector2(global_position.x+5,global_position.y)
					action=ACTION.MOVE
					$Weapon.in_fight=false
					override_fight(0.1)
			elif i.global_position.x<self.global_position.x && $AnimatedSprite.flip_h==true:		
				$Weapon.in_fight=true
				unit_to_attack=i
			elif i.global_position.x<self.global_position.x && $AnimatedSprite.flip_h==false:		
				$Weapon.in_fight=true
				unit_to_attack=i
				if is_ranged():#if it is ranged turn to face the enemy
					target_coords=Vector2(global_position.x-5,global_position.y)
					action=ACTION.MOVE
					$Weapon.in_fight=false
					override_fight(0.1)
			break
		else:
			$Weapon.in_fight=false
	
	#if it is ranged unit stop and fight at the furthest possible distance
	if is_ranged() && $Weapon.in_fight==true  && override_fight==false:
		target_coords=Vector2(global_position.x,global_position.y)
	#if it is mellee move towards the enemy
	if is_melee() && $Weapon.in_fight==true && override_fight==false:
		target_coords=Vector2(unit_to_attack.global_position.x,unit_to_attack.global_position.y)
		action=ACTION.MOVE

func draw_and_animate_human():
	$AnimatedSprite.draw_and_animate_human(action,velocity,selected)


#This will be called from the LevelScreen 
func handle_solo_input(object,position):
	if self==object:
		selected=true
		if mouse_over!=true:
			target_coords=Vector2(position.x,position.y)
			action=ACTION.MOVE
			override_fight(1)
	else:
		selected=false
	manage_collision_layers()
	

func handle_multi_input(position):
	if mouse_over!=true && selected:
		target_coords=Vector2(position.x,position.y)
		action=ACTION.MOVE
		override_fight(1)
	manage_collision_layers()

#allow the unit to move for a time before going back to fight mode	
func override_fight(timeout):
	override_fight=true
	if timeout==null:
		timeout=override_timer_timeout
	override_timer.set_wait_time(timeout)	
	override_timer.start()

func is_hit(object):
	life-=object.damage
	
	#if not fighting and hit then move towards attacker
	#if $Weapon.in_fight==false:
	target_coords=object.get_attacker_coords()
	action=ACTION.MOVE
	
	if life<=0:
		destroy()

func is_melee():
	if unit_type==Global.UNIT_TYPE.MELEE:
		return true
	else:
		return false

func is_ranged():
	if unit_type==Global.UNIT_TYPE.RANGED:
		return true
	else:
		return false

func destroy():
	#remove_from_group("enemies")
	queue_free()

func is_unit():
	return true

func is_building():
	return false

func is_worker():
	if unit_name==Global.UNIT_NAME.WORKER:
		return true
	else:
		return false

func is_mage():
	if unit_name==Global.UNIT_NAME.MAGE:
		return true
	else:
		return false
		
func check_working():
	if unit_name==Global.UNIT_NAME.WORKER && (on_top_of_resource || on_top_of_construction):
		$Weapon.in_fight=true
	
func gather_resource(on_top):
	on_top_of_resource=on_top

func construct_building(on_top):
	on_top_of_construction=on_top		