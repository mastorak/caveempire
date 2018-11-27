extends Area2D

var speed = 200
var speed_abs_val=200
var rotation_speed = 1.5

var velocity = Vector2()
var rotation_dir = 0

var rotation_dir_step=5
var rotation_dir_step_abs_val=5

var in_fight=false

enum DIRECTION{LEFT,RIGHT}
var direction =DIRECTION.RIGHT

var fire_timer
var can_shoot=false

export(int) var damage=10

var attacker_coords=Vector2()

var spellscene = load("res://src/item/Spell.tscn")

var clank_sound1=load("res://resources/sounds/Clank_1.ogg")
var clank_sound2=load("res://resources/sounds/Clank_10.ogg")
var clank_sound3=load("res://resources/sounds/Clank_5.ogg")
var spell_sound=load("res://resources/sounds/Explosion2.ogg")

func _ready():
	#fix position on parent
	if get_owner().is_melee():
		global_position.x=get_owner().global_position.x #+get_owner().get_node("CollisionShape2D").shape.extents.x
		global_position.y=get_owner().global_position.y-10
		pass
	elif get_owner().is_ranged():
		rotate(deg2rad(45))
		position.x=position.x+20
		position.y=position.y+10
		fire_timer=Timer.new()
		fire_timer.set_wait_time(2)
		fire_timer.connect("timeout",self,"_on_fire_timer_timeout")
		add_child(fire_timer)
		fire_timer.start() 
		
	#change texture depending on unit type
	if get_owner().unit_name==Global.UNIT_NAME.WARRIOR:
		$Sprite.texture=load("res://resources/items/weapon_regular_sword.png")
	elif get_owner().unit_name==Global.UNIT_NAME.ORC:
		$Sprite.texture=load("res://resources/items/weapon_baton_with_spikes.png")
	elif get_owner().unit_name==Global.UNIT_NAME.GOBLIN:
		$Sprite.texture=load("res://resources/items/weapon_baton_with_spikes.png")
	elif get_owner().unit_name==Global.UNIT_NAME.MAGE :
		$Sprite.texture=load("res://resources/items/weapon_green_magic_staff.png")
	elif get_owner().unit_name==Global.UNIT_NAME.NECROMANCER :
		$Sprite.texture=load("res://resources/items/weapon_red_magic_staff.png")	
	elif get_owner().unit_name==Global.UNIT_NAME.WORKER :
		$Sprite.texture=load("res://resources/items/weapon_hammer.png")			
		
	attacker_coords=Vector2(get_owner().global_position.x,get_owner().global_position.y)	
	connect("body_entered" , self, "_area_entered")

	if get_owner().unit_name==Global.UNIT_NAME.WARRIOR:
		$SoundPlayer.stream=clank_sound1
	elif get_owner().unit_name==Global.UNIT_NAME.WORKER:
		$SoundPlayer.stream=clank_sound2
	elif get_owner().unit_name==Global.UNIT_NAME.ORC || get_owner().unit_name==Global.UNIT_NAME.GOBLIN:
		$SoundPlayer.stream=clank_sound3
	elif get_owner().unit_name==Global.UNIT_NAME.MAGE || get_owner().unit_name==Global.UNIT_NAME.NECROMANCER:
		$SoundPlayer.stream=spell_sound
	
#depending on the direction the owner is facing change the weapon direction
func change_direction():
	
	if(get_owner().velocity.x>0):
		direction=DIRECTION.RIGHT
		if get_owner().is_melee():
			rotation_dir_step=rotation_dir_step_abs_val
			speed=speed_abs_val
		elif get_owner().is_ranged():
			rotation=(deg2rad(50))
			global_position.x=get_owner().global_position.x+20	
	elif(get_owner().velocity.x<0):
		direction=DIRECTION.LEFT	
		if get_owner().is_melee():
			rotation_dir_step=-rotation_dir_step_abs_val
			speed=-speed_abs_val
		elif get_owner().is_ranged():
			rotation=(deg2rad(-50))			
			global_position.x=get_owner().global_position.x-20

	
func _process(delta):
	if in_fight:
		visible=true
	else:
		visible=false
	
	#if it is melee weapon then we rotate
	if get_owner().is_melee():
		rotation_dir = 0
		velocity = Vector2()
		
		rotation_dir += rotation_dir_step
		velocity = Vector2(speed, 0).rotated(rotation)
		
		rotation += rotation_dir * rotation_speed * delta
		global_position = global_position + velocity * delta
		
	#if it is a ranged weapon to fire
	if get_owner().is_ranged() && in_fight:
		spawn_bullet()
	elif get_owner().is_ranged() && in_fight==false:
		$SoundPlayer.stop()	
		
	
	attacker_coords.x=get_owner().global_position.x
	attacker_coords.y=get_owner().global_position.y

	play_melee_sounds()

#spawn a new bullet if allowed by timer
func spawn_bullet():
	if can_shoot :
		var spell =spellscene.instance()
		spell.set_position(self.position)
		get_parent().add_child(spell)
		spell.spawn(get_owner().team,direction)
		can_shoot=false #reset spawning
		$SoundPlayer.play()

func _on_fire_timer_timeout():
	can_shoot=true
	
	
func _area_entered(object):
	if in_fight && get_owner().is_melee() && object.is_in_group("destructuble") && object!=get_owner():
		if(object.is_in_group("friendlies")&& get_owner().is_in_group("enemies")):
			object.is_hit(self)
		
		if(object.is_in_group("enemies")&& get_owner().is_in_group("friendlies")):
			object.is_hit(self)

func get_attacker_coords():
	return attacker_coords
	
func play_melee_sounds():
	if get_owner().is_melee() && in_fight:
		if !$SoundPlayer.is_playing():
			$SoundPlayer.play()
	elif get_owner().is_melee() && in_fight==false:
		$SoundPlayer.stop()
