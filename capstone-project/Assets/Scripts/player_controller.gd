extends CharacterBody2D
var WalkSpeed = 200.0
var DashSpeed = 1300.0
var dashing = false
var DashWait = false
var dir = 1
var lerprate = 0.2
var can_dash = true
var can_doublejump = false
var doublejumped = false
var is_getup = false
const SPEED = 250.0
const JUMP_VELOCITY = -350.0

var bullet = preload("res://Assets/Scenes/bullet.tscn")
var shootsfx = preload("res://Assets/Sounds/shoot.mp3")
var jumpsfx = preload("res://Assets/Sounds/jump.mp3")
var dubjumpsfx = preload("res://Assets/Sounds/doublejump.mp3")
var fallsfx = preload("res://Assets/Sounds/fall.mp3")
var bgmusic = preload("res://Assets/Sounds/stillalive.mp3")
var boostsfx = preload("res://Assets/Sounds/boost.mp3")
var getupsfx = preload("res://Assets/Sounds/getup.mp3")

# Player character is temporarily named "tag"
@onready var tag: AnimatedSprite2D = $AgentAnimator/AnimatedSprite2D
@onready var muzzle: Marker2D = $AgentAnimator/AnimatedSprite2D/muzzle

func _ready() -> void:
	$bgmusic.stream = bgmusic
	$bgmusic.play()

func _process(_delta: float) -> void:
	# Player loses control when "fall"ing, so movement functions are disabled.
	# Functions such as gravity continue to work (below).
	if tag.animation == "fall" or tag.animation == "getup":
		return
	else:
		if Input.is_action_just_pressed("ui_left"):
			dir = -1
			if tag.animation != "newdj_1" and tag.animation != "newdj_2":
				muzzle.rotation_degrees = 180
		elif Input.is_action_just_pressed("ui_right"):
			dir = 1
			if tag.animation != "newdj_1" and tag.animation != "newdj_2":
				muzzle.rotation_degrees = 0
		if Input.is_action_just_pressed("shoot"):
			if tag.animation != "fall" and tag.animation != "newdj_2":
				shoot()
			else:
				pass
		while is_on_floor() and Input.is_action_pressed("run"):
			if tag.flip_h:
				velocity.x = SPEED * -1
			else:
				velocity.x = SPEED
		# Aerial boost, refreshes upon landing
		if Input.is_action_just_pressed("dash") and dashing == false and can_dash and !is_on_floor():
			dash()
		# Refreshes double jump and dash upon touching the ground
		if is_on_floor():
			doublejumped = false
		if is_on_floor() and !can_dash:
			can_dash = true
		if !is_on_floor() and !doublejumped:
			can_doublejump = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Called when player falls off map, respawns at a set location
	if (position.y >= 512):
		velocity = Vector2.ZERO
		$fall.stream = fallsfx
		$fall.play()
		tag.play("fall")
		position = Vector2(200, -700)

		
	# Player loses control when "fall"ing, so movement functions are disabled.
	# Functions such as gravity continue to work (below).
	if tag.animation == "fall" or tag.animation == "getup":
		if !is_on_floor():
			pass
		else:
			if tag.animation == "fall":
				set_process_input(false)
				$sfx.stream = getupsfx
				$sfx.play()
				tag.play("getup")
				is_getup = true
			pass
	else:
		var direction = Input.get_axis("ui_left", "ui_right")
		if tag.animation == "newdj_1" or tag.animation == "newdj_2":
			pass
		elif dir > 0:
			tag.flip_h = false
			muzzle.position.x = 18.0
			muzzle.rotation_degrees = 0
		elif dir < 0:
			tag.flip_h = true
			muzzle.position.x = -18.0
			muzzle.rotation_degrees = 180
		if is_on_floor():
			if tag.animation != "idle" and tag.animation != "walk" and tag.animation != "shoot" and tag.animation != "walkshoot" and tag.animation == "boost":
				tag.play("roll")
			elif direction == 0 and tag.animation != "shoot":
				tag.play("idle")
			elif tag.animation != "roll" and tag.animation != "shoot" and tag.animation != "walkshoot":
				tag.play("walk")
		else:
			if tag.animation == "newdj_1" or tag.animation == "newdj_2" or tag.animation == "boostshoot" or tag.animation == "boost" or tag.animation == "fall" or tag.animation == "doublejump" or tag.animation == "airshoot" or tag.animation == "djshoot":
				pass
			elif can_doublejump == false:
				tag.play("doublejump")
			else:
				tag.play("jump")
		# Handle jump.
		if Input.is_action_just_pressed("up") and is_on_floor():
			$sfx.stream = jumpsfx
			$sfx.play()
			can_doublejump = true
			if tag.animation == "roll":
				velocity.y = JUMP_VELOCITY
				if velocity.x > 0:
					velocity.x = SPEED * 8
				else:
					velocity.x = SPEED * -8
			else:
				velocity.y = JUMP_VELOCITY
		# Double jump function
		if Input.is_action_just_pressed("up") and can_doublejump and !is_on_floor():
				tag.play("newdj_1")
				muzzle.rotation_degrees = 90
				if dir == 1:
					muzzle.position.x = 2
				else:
					muzzle.position.x = -2
				muzzle.position.y = 17
		if dashing == false:
			if Input.is_action_pressed("ui_left") and !dashing == true:
				velocity.x = lerp(velocity.x, -WalkSpeed, lerprate)
			if Input.is_action_pressed("ui_right") and !dashing == true:
				velocity.x = lerp(velocity.x, WalkSpeed, lerprate)
			elif !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
				velocity.x = lerp(velocity.x, 0.0, 0.1)
	move_and_slide()

# Fires bullets from muzzle node
func shoot():
	if tag.animation != "newdj_1":
		if get_tree().get_node_count_in_group("bullets") > 3:
			pass
		else:
			$sfx.stream = shootsfx
			$sfx.play()
			var b = bullet.instantiate()
			b.transform = muzzle.global_transform
			owner.add_child(b)
			if tag.animation != "newdj_2":
				if !tag.flip_h:
					muzzle.rotation_degrees = 0
					muzzle.position = Vector2(18, 1)
				else:
					muzzle.rotation_degrees = 180
					muzzle.position = Vector2(-18, 1)
				if tag.animation == "jump" or tag.animation == "airshoot":
					tag.play("airshoot")
				elif tag.animation == "idle" or tag.animation == "shoot":
					tag.play("shoot")
				elif tag.animation == "doublejump" or tag.animation == "djshoot":
					tag.play("djshoot")
				elif tag.animation == "boost" or tag.animation == "boostshoot":
					tag.play("boostshoot")
				else:
					tag.play("walkshoot")
		

# Handles an aerial dash
func dash():
	if tag.animation != "fall":
		tag.play("boost")
		$boost.stream = boostsfx
		$boost.play()
		can_dash = false
		dashing = true
		velocity.x = DashSpeed * dir 
		velocity.x = lerp(velocity.x, 0.0, 0.001)
		dashing = false
		pass
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if !is_processing_input():
		set_process_input(true)
	if is_getup:
		tag.play("idle")
		is_getup = false
	if tag.animation == "shoot":
		tag.play("idle")
	if tag.animation == "roll":
		tag.play("walk")
	if tag.animation == "walkshoot":
		tag.play("walk")
	if tag.animation == "newdj_2":
		tag.play("doublejump")
	if tag.animation == "newdj_1":
		tag.play("newdj_2")
		$sfx.stream = dubjumpsfx
		$sfx.play()
		can_doublejump = false
		velocity.y = JUMP_VELOCITY / 1.5
		doublejumped = true
		shoot()
		if !tag.flip_h:
			muzzle.rotation_degrees = 0
			muzzle.position = Vector2(18, 1)
		else:
			muzzle.rotation_degrees = 180
			muzzle.position = Vector2(-18, 1)
	if tag.animation == "boostshoot":
		tag.play("boost")
	if tag.animation == "airshoot":
		tag.play("jump")
	if tag.animation == "djshoot":
		tag.play("doublejump")
	if tag.animation == "boost":
		if can_doublejump:
			tag.play("jump")
		else:
			tag.play("doublejump")
	pass
