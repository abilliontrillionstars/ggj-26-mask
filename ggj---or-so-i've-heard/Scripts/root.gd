extends Node2D
# demo, practice, or time attack
var MODE = "practice"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list = []

func _ready() -> void:
	# start game manager
	# generate list of masks.
	for i in range(10):
		var guest = guest_scene.instantiate()
		$ScreenFoyer/Room.add_child(guest)
		#print("guest mask data: ", guest.mask_features)
	
	# pick some n to be POIs
	# pick some m > 2n to have rumors
	# WHEN MAKING RUMORS:
		# consider how many guests a rumor refers to
			# if that's 1, it gives it away
			# if it's too high, it's not very helpful

	# configure timer if using time attack

func _process(delta: float) -> void:
	# run game manager
	
	pass



func gen_rumor():
	# pick from existing POIs
	# gather info about their masks
	pass
