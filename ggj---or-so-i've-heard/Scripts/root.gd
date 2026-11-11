extends Node2D
# demo, practice, or time attack
var MODE = "none"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list: Array[Guest] = []
var cur_POI: Guest
var cur_room = "rumor"

### TODO NOTE
## add subsections of the screen to zoom into
## - make a hint type to tell which zone the POI is in
## - means more guests, hints are more valuable
## - also means more viable similarity hints
## rework rumor screen
## - animate mask approaching, moving to center of screen
## - dialogue box instead fades in, position is constant
## - maybe guest ends with a hint as to where to find the next rumor

@onready var dialogue_box = $Camera2D/DialogueBox
@onready var rumors = $RumorManager

func _ready() -> void:
	## start game manager
	# generate list of masks.
	populate_guest_list()
	# send that to the hint manager
	$HintManager.guest_list = guest_list
	$HintManager.rumor_manager = rumors
	
	# pick a POI
	cur_POI = guest_list.pick_random()
	cur_POI.is_poi = true
	print("POI IS: ", cur_POI.mask)
	# generate a list of rumors that together describe the POI 
	if MODE == "demo": roll_demo_rumors()
	elif MODE == "practice": $HintManager.gen_all_hints(cur_POI.mask)
func _process(_delta: float) -> void:
	# run game manager
	if Input.is_action_just_pressed("toggle guest moving"):
			toggle_guest_moving()
	# run dialog that explains first POI
	# after dialogue is empty, prompt "or so I hear..."
	# and show button to move to foyer
	
		# many masks to choose from
		# Masks move around ambiently (like Find Luigi)
	# Pick a new mask
		# Choose “get rumor” or “accuse!”
		# “What have you heard?” vs “It’s you!”
		# “Any gossip?” vs “I’ve been looking for you”
	# Get next rumor (alternatively, accuse the POI)

	pass
 
func populate_guest_list() -> void:
	for zone in range(5):
		for i in range(25):
			var guest: Guest
			while true:
				# make sure guests have unique masks overall
				var unique = true
				guest = guest_scene.instantiate()
				for other in guest_list:
					if other.mask == guest.mask:
						unique = false
				if not unique: continue
				else: break
			$GuestManager.get_child(zone*2 + 1).add_child(guest)
			guest_list.append(guest)
			guest.position += Vector2(randi_range(-400,400),randi_range(-200, 200))
			guest.scale *= 0.15
func toggle_guest_moving() -> void:
	for guest: Guest in guest_list:
		guest.moving = not guest.moving
func roll_demo_rumors() -> void:
	dialogue_box.queue_text("Rumors? Hmm...")
	dialogue_box.queue_text(rumors.gen_rumor_poi("thief"))
	
	dialogue_box.queue_text(rumors.gen_rumor_positive("stitches", "emerald"))
	var num_desc = $HintManager.omni_describes({"stitches": "emerald"}, [], [], [])
	dialogue_box.queue_text("Emerald stitches... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		dialogue_box.queue_text("Hm, wait, that's not right... my memory must have failed me.")
	
	dialogue_box.queue_text(rumors.gen_rumor_negative("centre"))
	num_desc = $HintManager.omni_describes({}, ["centre"], [], [])
	dialogue_box.queue_text("No centrepiece... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		dialogue_box.queue_text("Hm, wait, that's not right... my memory must have failed me.")
	
	dialogue_box.queue_text(rumors.gen_rumor_similar(2))
	num_desc = $HintManager.omni_describes({}, [], [ Vector2(guest_list.find(cur_POI), 2.0) ], [])
	dialogue_box.queue_text("Two similarities to mine... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		dialogue_box.queue_text("Hm, wait, that's not right... my memory must have failed me.")

# called by their respective event functions in guest.gd
# these aren't connected by signal because guests are instanced
# and so that they can happen sequentially timed (one calls other)
func on_guest_pressed(guest: Guest) -> void:
	print("this is the server! a guest got pressed.")
	# gamevar-dependent handling of approach animation
	for other in guest_list:
		# disable the guest's on-click behavior
		other.get_child(-1).disabled = true
	guest.z_index = 1
	# animate the appearance of the dialogue box
	
	# then queue the dialogue
	dialogue_box.speaker = guest
	if guest.rumors != []:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.roll_text(guest.rumors.pop_front())
	else:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.queue_text(rumors.gen_no_rumor())
func on_guest_left(source: Guest):
	source.z_index = 0
	for guest in guest_list:
		# re-enable guest clicking
		guest.get_child(-1).disabled = false
