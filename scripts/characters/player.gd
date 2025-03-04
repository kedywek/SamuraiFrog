extends CharacterBody2D

var run_speed = 400.0
var acceleration = 0.08
var deceleration = 0.08
const jump_height1 = -800.0
const jump_height2 = -600.0
const jump_height3 = -400.0

var dash_speed = 1100
var dash_max_distance = 1000
@export var dash_curve: Curve


var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var can_dash = true


enum States {Idle, Run, Charge, Jump, Attack, Grab}
var state = States.Idle
var direction

var time_left = 0

#@onready var grabbable_tiles: TileMapLayer = $"../GrabbableTiles"
#var DetectedTiles: Array[Vector2i] = []
#var TargetTile:Vector2i = Vector2i(-1,-1)

@onready var grab_tile_group: Node2D = $"../GrabTileGroup"
var target_tile:Node2D = null
var CanGrab=false


func _process(_delta: float) -> void:
	flip_sprite()
	
	#	pokazywanie kółka cooldownu dasha
	if $DashRegenBar.value == 100:
		$DashRegenBar.visible = false
		$GreenDashCircle.visible = true
	else:
		$DashRegenBar.visible = true
		$GreenDashCircle.visible = false
		
	#	pokazywanie kółka charge'owania jumpa
	if $jump_timer.is_stopped():
		$"../UI".jump_charge_visibility(false)
		
	else:
		$"../UI".jump_charge_visibility(true)
	
	#	zmiana wartości kółka dasha
	$DashRegenBar.set_value((1 - $dash_cooldown.time_left)*100)
	$"../UI".dash_coolDownBar_set_value((1 - $dash_cooldown.time_left)*100)
	
	#	zmiana wartości charge'owania jumpa
	if $jump_timer.time_left > 0.66:
		$"../UI".jump_charve_set_value(50);

	elif $jump_timer.time_left > 0.33:
		$"../UI".jump_charve_set_value(100);
	
	else:
		$"../UI".jump_charve_set_value(150);


func _physics_process(delta: float) -> void:

	if not is_on_floor(): #grawitacja
		velocity += get_gravity() * delta * 1.3

	handle_state_transitions()
	
	perform_state_actions()
	
	move_and_slide()
	
func handle_state_transitions():
	
	direction = Input.get_axis("left","right")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = States.Charge
		$jump_timer.start()
		
	if state == States.Charge and Input.is_action_just_released("jump"):
		time_left=$jump_timer.time_left
		$jump_timer.stop()

		state = States.Jump
		if(1 > time_left and time_left >= 0.66):
			velocity.y = jump_height3
		elif (0.66 > time_left and time_left >= 0.33):
			velocity.y = jump_height2
		else:
			velocity.y = jump_height1
		
	if is_on_floor() and direction != 0 and state != States.Charge:
		state = States.Run
	
	elif is_on_floor() and state != States.Charge:
		state = States.Idle
		
	if !is_on_floor() and state != States.Attack:
		state = States.Jump
		
	if !is_on_floor() and state == States.Jump and not is_dashing and can_dash and Input.is_action_just_pressed("attack") and direction:
		state = States.Attack
		
	if Input.is_action_just_pressed("grab") and CanGrab:
		state = States.Grab

func perform_state_actions():
	shadow_appear()
	
	match state:
		States.Idle:
			$Label.text="Idle"
			$AnimationPlayer.play("idle")
			velocity.x = move_toward(velocity.x, 0, run_speed * deceleration)
					
		States.Run:
			$Label.text="Run"
			$AnimationPlayer.play("run")
			velocity.x = move_toward(velocity.x, run_speed * direction, run_speed * acceleration)
		
		States.Charge:
			$Label.text="Charge"
			$AnimationPlayer.play("charge")
			#velocity.x = 0
			velocity.x = move_toward(velocity.x, 0, run_speed * deceleration)
			#if(!is_on_floor()):
				#state = States.Jump
		
		States.Jump:
			$Label.text="Jump"
			if velocity.y > 0:
				$AnimationPlayer.play("fall")
			elif velocity.y <=0:
				$AnimationPlayer.play("jump")
				
			velocity.x = move_toward(velocity.x, run_speed * direction, run_speed * acceleration)
			
		States.Attack:
			if not is_dashing:
				if velocity.x>0:
					$attackR.play("default")
				elif velocity.x<0:
					$attackL.play("default")
				
				$Label.text="Attack"
				
				$dash_cooldown.start()
				dash_start_position = position.x
				dash_direction = direction
				can_dash = false
				is_dashing = true
				
				var current_distance = abs(position.x - dash_start_position)
				if current_distance >= dash_max_distance or is_on_wall():
					is_dashing = false
				else:
					velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
				
				$dash_timer.start()
		States.Grab:
			$Label.text="Grab"
			
			
func flip_sprite():
	if Input.is_action_pressed("left"):
		$Sprite2D.flip_h=true
	elif Input.is_action_pressed("right"):
		$Sprite2D.flip_h=false
		

func shadow_appear():
	if is_on_floor():
		$shadow.visible=true
	else:
		$shadow.visible=false

#czas dasha
func _on_dash_timer_timeout() -> void:
	state = States.Jump
	is_dashing = false
	
func _on_dash_cooldown_timeout() -> void:
	can_dash = true

#func _on_grabbing_range_body_entered(tile: TileMapLayer) -> void:
	#if tile.is_in_group("GrabbableTiles"):
		#print("GRAB")
		#CanGrab=true
		#tile.visible=true
		#
		#var world_pos = tile.global_position
		#var grid_pos = grabbable_tiles.map_to_local(world_pos)
		#print(grid_pos)
		
#func _on_grabbing_range_body_exited(tile: TileMapLayer) -> void:
	#if tile.is_in_group("GrabbableTiles"):
		#CanGrab=false
		#tile.visible=false
		


#func _on_grabbing_range_body_entered(GrabTile: Node2D) -> void:
	#print(GrabTile)
	##print("cos")
	##if GrabTile.is_in_group("GrabbableTiles"):
	##GrabTile.visible=true
	##print(grab_tile_group.get_children())
	#for points in grab_tile_group.get_children():
		#if GrabTile.position == points.position:
			#print(points.position)
		##print(target_tile.global_position)
		##print(grab_tile_group.get_all_points())
		##for points in grab_tile_group.get_all_points():
			##print(points)


func _on_grabbing_range_body_entered(body: Node2D) -> void:
	print(body)
