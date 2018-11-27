extends Area2D

var velocity =Vector2(0,0)
var abs_velocity=250

export(int) var damage=15

var attacker_coords=Vector2()

func _ready():
	connect("body_entered" , self, "_hit")
		
func _hit(body):
	if !body.is_class("TileMap"):
		body.is_hit(self)
		destroy()

func spawn(team,direction):
	position.y=position.y-10
	attacker_coords=Vector2(global_position.x,global_position.y)
	if direction==0: #weapon enum left
		velocity=Vector2(-abs_velocity,0)
	elif direction==1: #weapon enum right
		velocity=Vector2(abs_velocity,0)	
	
	if team==Global.TEAM.PLAYER: #unit enum team friendly 
		add_to_group("friendlies")
		set_collision_layer_bit(0,true)
		set_collision_layer_bit(1,false)
		set_collision_mask_bit(1,true)
		set_collision_mask_bit(0,false)
	elif team==Global.TEAM.ENEMY: #unit enum team enemy 
		add_to_group("enemies")
		set_collision_layer_bit(1,true)
		set_collision_layer_bit(0,false)
		set_collision_mask_bit(0,true)
		set_collision_mask_bit(1,false)
	
func _process(delta):
	position = position + velocity * delta	

func destroy():
	queue_free()

func get_attacker_coords():
	return attacker_coords