extends CharacterBody3D

# Movement parameters
var movement_speed: float = 5.0
var movement_target_position: Vector3 = Vector3(0.0, 0.0, 0.0)
#time is toe ticking
var timer_food = 0.0
var timer_hunger = 0.1
# Hamster 
var food = 100
var idle = true
var moving = false

# Seed targeting
var closest_seed = null
var min_distance = INF

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# Adjust these values according to actor speed and navigation layout
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Setup actor after physics frame to ensure navigation is ready
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame
	set_movement_target(movement_target_position)

func set_movement_target(target_position: Vector3):
	navigation_agent.set_target_position(target_position)

func _physics_process(delta):
#Food Timer
	timer_food += delta
	if timer_food >= timer_hunger:
		food -= 1
		timer_food = 0
		print("log")
# Check hunger and find the closest seed if needed
	if food <= 50 and closest_seed == null:
		closest_seed = null
		min_distance = INF

		for seed in get_tree().get_nodes_in_group("Seeds"):
			if seed:
				var distance_to_seed = global_position.distance_to(seed.global_position)
				if distance_to_seed < min_distance:
					min_distance = distance_to_seed
					closest_seed = seed

		# Set movement target to the closest seed
		if closest_seed:
			movement_target_position = closest_seed.global_position
			idle = false
			moving = true
	if closest_seed and global_position.distance_to(closest_seed.global_position) < 1.5:
		closest_seed.queue_free()
		food += 10
		print("seed eaten ")
	# Move along the navigation path
	var current_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	# Look at the next path point 
	if current_position.distance_to(next_path_position) > 0.01:
		look_at(next_path_position, Vector3.UP)

	# Calculate velocity and move
	velocity = current_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

	# Update idle/moving states when destination is reached
	if navigation_agent.is_navigation_finished():
		idle = true
		moving = false
		closest_seed = null
		min_distance = INF
