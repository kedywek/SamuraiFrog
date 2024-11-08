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


enum States {Idle, Run, Charge, Jump, Attack}
var state = States.Idle
var direction

var time_left = 0


func _process(_delta: float) -> void:
	flip_sprite()
	
	#	pokazywanie kółka cooldownu dasha
	if $jump_regen.value == 100:
		$jump_regen.visible = false
	else:
		$jump_regen.visible = true
		
	#	pokazywanie kółka charge'owania jumpa
	if $jump_timer.is_stopped() or $jump_charge.value == 0:
		$jump_charge.visible = false
	else:
		$jump_charge.visible = true
	
	#	zmiana wartości kółka dasha
	$jump_regen.set_value((1 - $dash_cooldown.time_left)*100)
	
	#	zmiana wartości charge'owania jumpa
	if $jump_timer.time_left > 1:
		$jump_charge.set_value(50)
	elif $jump_timer.time_left > 0.5:
		$jump_charge.set_value(100)
	else:
		$jump_charge.set_value(150)


func _physics_process(delta: float) -> void:

	if not is_on_floor(): #grawitacja
		velocity += get_gravity() * delta * 1.3

	handle_state_transitions()
	
	perform_state_actions(delta)
	
	move_and_slide()
	
func handle_state_transitions():
	
	direction = Input.get_axis("left","right")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = States.Charge
		$jump_timer.start()
		
		
	if state == States.Charge and Input.is_action_just_released("jump"):
		time_left=$jump_timer.time_left
		$jump_timer.stop()
		print(time_left)
		state = States.Jump
		if(1.5 > time_left and time_left >= 1.0):
			velocity.y = jump_height3
		elif (1.0 > time_left and time_left >= 0.5):
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
		#can_dash=false


func perform_state_actions(delta):
	$AttackEffectBehind.emitting = false
	
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
			velocity.x = 0
		
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
				dashing_effect_particles()
				
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
			
			
func flip_sprite():
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0:
		$Sprite2D.flip_h = false
		
func dashing_effect_particles():
	$AttackEffectBehind.emitting = true
	if velocity.x>0:
		$AttackEffectBehind.process_material.set_direction(Vector3(-1, 0, 0))
	elif velocity.x < 0:
		$AttackEffectBehind.process_material.set_direction(Vector3(1, 0, 0))


#czas dasha
func _on_dash_timer_timeout() -> void:
	state = States.Jump
	is_dashing = false
	

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
