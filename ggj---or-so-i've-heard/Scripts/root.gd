extends Node2D
# demo, practice, or time attack
#var MODE = "demo"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list = []

var cur_room = "rumor"

func _ready() -> void:
	# start game manager
	$ScreenRumor/FoyerButton.pressed.connect(self.switch_room)
	$ScreenFoyer/RumorButton.pressed.connect(self.switch_room)
	# generate list of masks.
	for i in range(10):
		var guest = guest_scene.instantiate()
		$ScreenFoyer/Room.add_child(guest)
	# pick a POI
	
	# generate a list of rumors that together describe the POI 
	
	# WHEN MAKING RUMORS:
		# consider how many guests a rumor refers to
			# if that's 1, it gives it away
			# if it's too high, it's not very helpful
			
		# so then, the pattern becomes
			# make a func describes(mask_data) -> int:
			# returns how many guests are described by the info given
			# this should be one for all the rumors put together, BUT
			# any one rumor should return around 3-5
	var dialogue_box = $ScreenRumor/DialogueRumor
	var rumors = $ScreenRumor/DialogueRumor/RumorContainer
	dialogue_box.roll_text(rumors.gen_poi_dialogue("thief"))
	dialogue_box.queue_text(rumors.gen_hint_positive("crest", "ruby"))
	
	# configure timer if using time attack

func _process(delta: float) -> void:
	# run game manager
	
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
	if cur_room == "rumor":
		camera_anims.play("to_foyer")
		cur_room = "foyer"
	else:
		camera_anims.play_backwards("to_foyer")
		cur_room = "rumor"

func gen_all_hints(mask: Dictionary[String, String], steps: int):
	"pregenerates all the rumors to one POI."
	for i in range(steps):
		# generate a true statement about the POI.
		while true:
			var hint = gen_hint(mask)
			# make sure it doesn't give it away immediately
			
			break
		pass
func gen_hint(mask: Dictionary[String, String]):
	"returns a mask with a detail present in the original mask"
	# for now, just give one detail of the mask
	
func guest_get_similar(mask, other) -> int:
	"returns how many mask features two guests have in common."
	return 0
func guest_get_unique(mask):
	"returns a mask representing features it has that no other guest does."

func describes(mask: Dictionary[String, String], similar_guests: Array[Vector2]):
	"given some mask details, returns how many guests they could refer to."
	# each element of similar_guests is a Vec2(guest_num, amount_similar)
	for guest in guest_list:
		var does_describe = true
		# first, the raw mask details
		for key in mask:
			# every detail present in mask must be present in a given
			# guest for them to be counted as described by it
			if not (key in guest.mask_features and mask[key] == guest.mask_features[key]):
				continue
		# next, the similar guests
			# ... I'll do this in the morning
