extends Node2D
# demo, practice, or time attack
var MODE = "demo"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list: Array[Guest] = []
var cur_POI
var cur_room = "rumor"


@onready var dialogue_box = $ScreenRumor/DialogueRumor
@onready var rumors = $ScreenRumor/DialogueRumor/RumorContainer

func _ready() -> void:
	# start game manager
	$ScreenRumor/FoyerButton.pressed.connect(self.switch_room)
	$ScreenFoyer/RumorButton.pressed.connect(self.switch_room)
	# generate list of masks.
	for i in range(25):
		var guest
		while true:
			# make sure guests have unique masks overall
			var unique = true
			guest = guest_scene.instantiate()
			for other in guest_list:
				if other.mask == guest.mask:
					unique = false
			if not unique: continue
			else: break
		$ScreenFoyer/Room.add_child(guest)
		guest_list.append(guest)
		guest.position += Vector2(randi_range(-400,400),randi_range(-200, 200))
		guest.scale *= 0.85
	# send that to the hint manager
	$HintManager.guest_list = guest_list
	$HintManager.rumor_manager = rumors
	
	# pick a POI
	cur_POI = guest_list.pick_random()
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
 
func switch_room() -> void:
	var camera_anims: AnimationPlayer = $Camera2D/CameraPivot
	$/root/root/RoomButtonPivot.play_backwards("appear")
	$ScreenRumor/DialogueRumor/NextButton.disabled = false
	$ScreenFoyer/DialogueGuest/NextButton.disabled = false
	if cur_room == "rumor":
		camera_anims.play("to_foyer")
		cur_room = "foyer"
	else:
		camera_anims.play_backwards("to_foyer")
		cur_room = "rumor"
func toggle_guest_moving() -> void:
	for guest in guest_list:
		guest.moving = not guest.moving

func roll_demo_rumors():
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

func on_guest_pressed(guest):
	switch_room()
	if guest.rumors != []:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.roll_text(guest.rumors.pop_front())
	else:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.queue_text(rumors.gen_no_rumor())
	# copy the guest's mask details to the rumor screen
	$Guest/centre.visible = guest.find_child("centre").visible
	$Guest/centre.modulate = guest.find_child("centre").modulate
	$Guest/tears.visible = guest.find_child("tears").visible
	$Guest/tears.modulate = guest.find_child("tears").modulate
	$Guest/crest.visible = guest.find_child("crest").visible
	$Guest/crest.modulate = guest.find_child("crest").modulate
	$Guest/rhinestones.visible = guest.find_child("rhinestones").visible
	$Guest/rhinestones.modulate = guest.find_child("rhinestones").modulate
	$Guest/stitches.visible = guest.find_child("stitches").visible
	$Guest/stitches.modulate = guest.find_child("stitches").modulate
