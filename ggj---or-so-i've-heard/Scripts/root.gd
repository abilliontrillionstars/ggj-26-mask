extends Node2D
# demo, practice, or time attack
#var MODE = "demo"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list = []

var cur_room = "rumor"

func _ready() -> void:
	# start game manager
	var foyer_button = $ScreenRumor/FoyerButton
	foyer_button.pressed.connect(self.switch_room)
	var rumor_button = $ScreenFoyer/RumorButton
	rumor_button.pressed.connect(self.switch_room)
	# generate list of masks.
	for i in range(10):
		var guest = guest_scene.instantiate()
		$ScreenFoyer/Room.add_child(guest)
	for guest in guest_list:
		pass
	# pick some n to be POIs
	# pick some m > 2n to have rumors
	# WHEN MAKING RUMORS:
		# consider how many guests a rumor refers to
			# if that's 1, it gives it away
			# if it's too high, it's not very helpful
		# so then, the pattern becomes
			# make a func describes(mask_data) -> int:
			# returns how many guests are described by the info given
			# this should be one for all the rumors put together, BUT
			# any one rumor should return around 3-5

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
	if cur_room == "rumor":
		camera_anims.play("to_foyer")
		cur_room = "foyer"
	else:
		camera_anims.play_backwards("to_foyer")
		cur_room = "rumor"

func gen_rumor():
	# pick from existing POIs
	# gather info about their masks
	pass
