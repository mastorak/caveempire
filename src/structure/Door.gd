extends Area2D

var spawn_timer
var spawn_timer_timeout

export(int) var spawn_rate=2
export(int) var target_x=-500

var orc_scene=load("res://src/unit/Orc.tscn")

func _ready():
	spawn_timer=false
	spawn_timer_timeout=spawn_rate
	spawn_timer=Timer.new()
	spawn_timer.set_wait_time(spawn_timer_timeout)
	spawn_timer.connect("timeout",self,"_on_spawn_timer_timeout")
	add_child(spawn_timer)
	spawn_timer.start()	


func _on_spawn_timer_timeout():
	var unit
	unit = orc_scene.instance()
	unit.position.x=self.position.x
	unit.position.y=self.position.y
	unit._setup_unit(Global.TEAM.ENEMY)
	unit.add_to_group("enemies")
	get_parent().add_child(unit)
	unit.move_to_position(Vector2(unit.global_position.x+ target_x,unit.global_position.y))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
