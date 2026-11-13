extends Node2D
# demo, practice, or time attack
var MODE = "demo"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list: Array[Guest] = []
var cur_POI: Guest

### TODO NOTE
## add subsections of the screen to zoom into
## - make a hint type to tell which zone the POI is in
## - means more guests, hints are more valuable
## - also means more viable similarity hints
## rework rumor screen
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
	if MODE == "demo": gen_demo_rumors(cur_POI)
	elif MODE == "practice": $HintManager.gen_all_hints(cur_POI.mask)
func _process(_delta: float) -> void:
	# run game manager
	if Input.is_action_just_pressed("toggle guest moving"):
			toggle_guest_moving()
	# run dialog that explains first POI	
		# many masks to choose from
		# Masks move around ambiently (like Find Luigi)
	# Pick a new mask
		# Choose “get rumor” or “accuse!”
		# “What have you heard?” vs “It’s you!”
		# “Any gossip?” vs “I’ve been looking for you”
	# Get next rumor (alternatively, accuse the POI)
 
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
func gen_demo_rumors(guest: Guest) -> void:
	guest.rumors.append("Rumors? Hmm...")
	guest.rumors.append(rumors.gen_rumor_poi("thief"))
	
	guest.rumors.append(rumors.gen_rumor_positive("stitches", "emerald"))
	var num_desc = $HintManager.mask_describes({"stitches": "emerald"})
	guest.rumors.append("Emerald stitches... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		guest.rumors.append("Hm, wait, that's not right... my memory must have failed me.")
	
	guest.rumors.append(rumors.gen_rumor_negative("centre"))
	num_desc = $HintManager.not_mask_describes(["centre"])
	guest.rumors.append("No centrepiece... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		guest.rumors.append("Hm, wait, that's not right... my memory must have failed me.")
	
	guest.rumors.append(rumors.gen_rumor_similar(2))
	num_desc = $HintManager.similar_describes(cur_POI.mask, 2.0)
	guest.rumors.append("Two similarities to mine... that describes "+str(num_desc)+" guests.")
	if num_desc == 0:
		guest.rumors.append("Hm, wait, that's not right... my memory must have failed me.")

func on_guest_pressed(guest: Guest) -> void:
	print("this is the server! a guest got pressed.")
	$Camera2D/BackButton.disabled = true
	# gamevar-dependent handling of approach animation
	for other in guest_list:
		# disable the guest's on-click behavior
		other.get_child(-1).disabled = true
	guest.z_index = 1
# called by their respective event functions in guest.gd
# these aren't connected by signal because guests are instanced
# and so that they can happen sequentially in time (one calls other)
func on_guest_approached(source: Guest):
	$Camera2D/DialogueBox.speaker = source
	$Camera2D/DialogueBox/NextButton.disabled = false
	# queue the dialogue
	dialogue_box.speaker = source
	if source.rumors != []:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.roll_text(source.rumors.pop_front())
	else:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.queue_text(rumors.gen_no_rumor())
func on_guest_left(source: Guest):
	source.z_index = 0
	$Camera2D/DialogueBox.speaker = null
	$Camera2D/DialogueBox/NextButton.disabled = true
	$Camera2D/BackButton.disabled = false
	for guest in guest_list:
		# re-enable guest clicking
		guest.get_child(-1).disabled = false

func _on_camera_animator_animation_finished(_anim_name: StringName) -> void:
	var oldState = $Camera2D.view
	if oldState == $Camera2D.viewState.outer:
		print("moving into guest view")
	for guest in guest_list:
		guest.get_child(-1).disabled = oldState != $Camera2D.viewState.outer
