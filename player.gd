extends Area2D
signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@onready var height_label = $HeightLabel
var screen_size # Size of the game window.
var height : float = 1.0 # The player's height in meters, starting at 1.0.

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	height_label.text = "高度:%.2f米" % height
	
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		height += randf_range(-0.1,0.1)
		height = clamp(height,0.0,3.0)
		height_label.text = "高度:%.2f米" % height
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
	# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0


func _on_body_entered(_body):
	# If the player collides with a mob, check the player's height.
	# If the player's height is less than 2.0, emit the hit signal.
	var sprite = $AnimatedSprite2D
	var shader_material = sprite.material
	# Enable the shader effect when the player collides with a mob.
	shader_material.set_shader_parameter("enable_tint", true) 
	if height < 2.0:
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		$CollisionShape2D.set_deferred("disabled", true)
		# Disable the player's movement.
		set_process(false)
		# Pause the game.
		get_tree().paused = true
	else :
		$CollisionShape2D.disabled = true
		# If the player collides with a mob and their height is 2.0 or more, disable the shader effect.
		shader_material.set_shader_parameter("enable_tint", false)	
	
func start(pos):
	position = pos
	var sprite = $AnimatedSprite2D
	var shader_material = sprite.material
	# Reset the shader effect when starting the player.
	shader_material.set_shader_parameter("enable_tint", false) 
	# Reset the player's height.
	height = 1.0
	height_label.text = "高度:%.2f米" % height
	show()
	$CollisionShape2D.disabled = false
	set_process(true)
	get_tree().paused = false
