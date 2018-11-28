extends Node2D

var cursor_position_start
var cursor_position_end
var dragging=false
var draggin_event=false
var select_rectangle
var multi_select

var command_object

var cursor_normal = load("res://resources/ui/cursor/cursorHand_grey.png")
var cursor_sword = load("res://resources/ui/cursor/cursorSword_silver.png")
var cursor_arrow_right = load("res://resources/ui/cursor/arrowSilver_right.png")
var cursor_arrow_left = load("res://resources/ui/cursor/arrowSilver_left.png")
var cursor_arrow_up = load("res://resources/ui/cursor/arrowSilver_up.png")
var cursor_arrow_down = load("res://resources/ui/cursor/arrowSilver_down.png")
var cursor_arrow_top_right = load("res://resources/ui/cursor/arrowSilver_top-right.png")
var cursor_arrow_top_left = load("res://resources/ui/cursor/arrowSilver_top-left.png")
var cursor_arrow_bottom_right = load("res://resources/ui/cursor/arrowSilver_bottom-right.png")
var cursor_arrow_bottom_left = load("res://resources/ui/cursor/arrowSilver_bottom-left.png")


var command_container
var info_container

var unit_selected=false
var building_selected=false

var bottom_panel

var camera_velocity =Vector2(0,0)
var camera_speed=600
var camera_speed_normal=600
var camera_speed_fast=1000
var camera_extend_x
var camera_extend_y

func _ready():
	
	Input.set_custom_mouse_cursor(cursor_normal)
	get_viewport().warp_mouse(Vector2(get_viewport().size.x/2,get_viewport().size.y/2))
	
	camera_extend_x=$LevelViewport.get_viewport().size.x/2
	camera_extend_y=$LevelViewport.get_viewport().size.y/2
		
	command_container=get_node("CanvasLayer/BottomPanel/HSplitContainer/CommandContainer")
	info_container=get_node("CanvasLayer/BottomPanel/HSplitContainer/InfoContainer")

	bottom_panel = get_node("CanvasLayer/BottomPanel")
	

func _process(delta):
	handle_mouse_input()
	handle_keyboard_input()
	#update the canvas drawing
	update()
	$LevelViewport.position=$LevelViewport.position+camera_velocity*delta
	
func move_camera(direction):
	
		
	if direction==Global.DIRECTION.LEFT:
		camera_velocity.x=-camera_speed
	if direction==Global.DIRECTION.RIGHT:
		camera_velocity.x=camera_speed
	if direction==Global.DIRECTION.UP:
		camera_velocity.y=-camera_speed
	if direction==Global.DIRECTION.DOWN:
		camera_velocity.y=camera_speed
	if direction==Global.DIRECTION.CENTER:
		camera_velocity.x=0
		camera_velocity.y=0

func  left_limit():
	if	$LevelViewport.position.x>Global.camera_limits.x-200:
		return true
	else:
		return false	

func  right_limit():
	if	$LevelViewport.position.x<Global.camera_limits.x+Global.camera_limits.width-get_viewport().get_visible_rect().size.x:
		return true
	else:
		return false	

func  bottom_limit():
	if	$LevelViewport.position.y<Global.camera_limits.height-500:
		return true
	else:
		return false	

func  top_limit():
	if	$LevelViewport.position.y>Global.camera_limits.y-200:
		return true
	else:
		return false	

func handle_keyboard_input():
	
	if Input.is_action_pressed("ui_left") && left_limit():
		move_camera(Global.DIRECTION.LEFT)
		camera_speed=camera_speed_fast
	if Input.is_action_pressed("ui_right") && right_limit():
		move_camera(Global.DIRECTION.RIGHT)
		camera_speed=camera_speed_fast
	if Input.is_action_pressed("ui_up") && top_limit():
		move_camera(Global.DIRECTION.UP)
		camera_speed=camera_speed_fast
	if Input.is_action_pressed("ui_down") && bottom_limit():
		move_camera(Global.DIRECTION.DOWN)
		camera_speed=camera_speed_fast
	
	
func handle_mouse_input():
	
	var cursor_viewport_position=get_viewport().get_mouse_position()
	cursor_position_end=get_global_mouse_position()
			
	unit_selected=false
	building_selected=false
	
	if cursor_viewport_position.x<50 && left_limit():
		Input.set_custom_mouse_cursor(cursor_arrow_left)
		move_camera(Global.DIRECTION.LEFT)
		camera_speed=camera_speed_normal
	if cursor_viewport_position.x>get_viewport().get_visible_rect().size.x-50 && right_limit():
		Input.set_custom_mouse_cursor(cursor_arrow_right)
		move_camera(Global.DIRECTION.RIGHT)
		camera_speed=camera_speed_normal
	if cursor_viewport_position.y<50 && top_limit():	
		Input.set_custom_mouse_cursor(cursor_arrow_up)
		move_camera(Global.DIRECTION.UP)
		camera_speed=camera_speed_normal
	if cursor_viewport_position.y>get_viewport().get_visible_rect().size.y-50 && bottom_limit():
		Input.set_custom_mouse_cursor(cursor_arrow_down)
		move_camera(Global.DIRECTION.DOWN)
		camera_speed=camera_speed_normal
		
	if cursor_viewport_position.x<50 && cursor_viewport_position.y<50:
		Input.set_custom_mouse_cursor(cursor_arrow_top_left)
	if cursor_viewport_position.x<50 && cursor_viewport_position.y>get_viewport().get_visible_rect().size.y-50:
		Input.set_custom_mouse_cursor(cursor_arrow_bottom_left)
	if cursor_viewport_position.x>get_viewport().get_visible_rect().size.x-50 && cursor_viewport_position.y<50:
		Input.set_custom_mouse_cursor(cursor_arrow_top_right)
	if cursor_viewport_position.x>get_viewport().get_visible_rect().size.x-50 && cursor_viewport_position.y>get_viewport().get_visible_rect().size.y-50:
		Input.set_custom_mouse_cursor(cursor_arrow_bottom_right)
	
	if cursor_viewport_position.x>50 && cursor_viewport_position.x<get_viewport().get_visible_rect().size.x-50 && cursor_viewport_position.y>50 && cursor_viewport_position.y<get_viewport().get_visible_rect().size.y-50:
		Input.set_custom_mouse_cursor(cursor_normal)
		move_camera(Global.DIRECTION.CENTER)	
	
		
	#we start pressing the button and read the position
	if Input.is_action_just_pressed("ui_left_mouse_button"):
		#cursor_position_start=get_viewport().get_mouse_position()
		cursor_position_start=get_global_mouse_position()
		dragging=true
	#we release the button	
	if Input.is_action_just_released("ui_left_mouse_button"):
		var selectables=get_tree().get_nodes_in_group("selectables")
		var buildings=get_tree().get_nodes_in_group("buildings")
		#cursor_position_end=get_viewport().get_mouse_position()
		cursor_position_end=get_global_mouse_position()
		#hack assignment if we are coming from another scene and button press now is empty
		if cursor_position_start==null:
			cursor_position_start=cursor_position_end
		
		dragging=false
		#if we did not drag the cursor we count it as a click allowing for some small accidental cursor movement
		if cursor_position_end.x-cursor_position_start.x<10 && cursor_position_end.y-cursor_position_start.y<10:
			var selected_object
			#check if we have selected a unit
			for i in selectables:
				if i.mouse_over==true:#if cursor is on top it means we are selecteing only one
					deselect_objects(selectables)
					deselect_objects(buildings)
					i.selected=true
					multi_select=false
					selected_object=i
					command_object=i
					switch_command_panel(i)
					break
				else:#we have an already selected unit
					if i.selected==true:
						selected_object=i
						command_object=i
						unit_selected=true
						building_selected=false
						deselect_objects(buildings)
			#check if we have selected a building
			for i in buildings:
				if i.mouse_over==true && i.can_be_selected():
					deselect_objects(buildings)	
					i.selected=true
					unit_selected=false
					building_selected=true
					deselect_objects(selectables)
					switch_command_panel(i)
					break
			
			#apply handling for units
			if unit_selected==true && Global.panel_input==false:
				if multi_select==false:
					#call the selectables group to select a single object and possibly do something
					get_tree().call_group("selectables", "handle_solo_input",selected_object,cursor_position_end)
				else:
					get_tree().call_group("selectables", "handle_multi_input",cursor_position_end)
			
			Global.panel_input=false #reset input
			
		#the start and end are far away that we are actually doing drag-select
		else:
			var units=[]
			for i in selectables:
				i.selected=false
				#for every selectable we are checking create a rectangle
				var obj_width=i.get_node("CollisionShape2D").shape.extents.x*2
				var obj_height=i.get_node("CollisionShape2D").shape.extents.y*2
				var obj_rect= Rect2(i.get_node("CollisionShape2D").global_position,Vector2(obj_width,obj_height))
				#if object is enclosed by selection rectangle select it
				if select_rectangle.encloses(obj_rect):
					i.selected=true
					multi_select=true
					deselect_objects(buildings)
					units.push_back(i)
			if units.size()==1:
				command_object=units[0]
				switch_command_panel(units[0])
			elif units.size()>1:
				switch_panel_to_multi_unit(units)	
	

func _draw():
	#if we are dragging the mouse cursor draw calculate rectangle and draw it
	if dragging:
		var width=cursor_position_end.x-cursor_position_start.x
		var height=cursor_position_end.y-cursor_position_start.y
		select_rectangle=Rect2(cursor_position_start, Vector2(width,height))
		draw_rect(select_rectangle,Color(255,255,255,0.5),false)

func switch_panel_to_multi_unit(units):
	clear_bottom_panel()
	info_container.get_node("UnitInfo").load_multi_units(units)
	info_container.get_node("UnitInfo").visible=true

func switch_command_panel(object):
	clear_bottom_panel()
		
	if object.is_unit():
		if object.unit_name==Global.UNIT_NAME.WORKER:
			command_container.get_node("WorkerPanel").visible=true
		elif object.unit_name==Global.UNIT_NAME.WARRIOR:
			command_container.get_node("FighterPanel").visible=true
		elif object.unit_name==Global.UNIT_NAME.MAGE:
			command_container.get_node("MagePanel").visible=true
		info_container.get_node("UnitInfo").load_unit_info(object)
		info_container.get_node("UnitInfo").visible=true
	elif object.is_building():
		info_container.get_node("BuildingInfo").load_building_info(object)
		info_container.get_node("BuildingInfo").visible=true
		command_container.get_node("BuildingPanel").visible=true
		
		
func clear_bottom_panel():
	info_container.get_node("UnitInfo").clear_unit_info()
	for child in command_container.get_children():
		child.visible=false
	for child in info_container.get_children():
		child.visible=false

func deselect_objects(objects):
	for i in objects:
		i.selected=false
		
		
#func _input(event):
#
#	if event is InputEventMouseButton and event.pressed==false:
#		var objects=get_tree().get_nodes_in_group("selectables")
#		var selected_object
#		for i in objects:
#			if i.mouse_over==true:
#				i.selected=true
#				selected_object=i
#				break
#			else:
#				if i.selected==true:
#					selected_object=i
#
#		get_tree().call_group("selectables", "handle_input",selected_object,event.position)							
		