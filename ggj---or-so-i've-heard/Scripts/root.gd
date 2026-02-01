extends Node2D
# demo, practice, or time attack
#var MODE = "demo"
var guest_scene = preload("res://Scenes/guest.tscn")
var guest_list = []
var cur_POI
var cur_room = "rumor"

# generated when a POI is revealed.
var hints_queue = []
# the hints that the player has been given. 
# determines how close they are to solving the POI  
var hints_given = []


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
	# pick a POI
	cur_POI = guest_list.pick_random()
	print("POI IS: ", cur_POI.mask)
	# generate a list of rumors that together describe the POI 
	gen_all_hints(cur_POI.mask, 4)
	for hint in hints_queue:
		print(hint)
	
	
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
	$ScreenRumor/DialogueRumor/NextButton.disabled = false
	$ScreenFoyer/DialogueGuest/NextButton.disabled = false
	if cur_room == "rumor":
		camera_anims.play("to_foyer")
		cur_room = "foyer"
	else:
		camera_anims.play_backwards("to_foyer")
		cur_room = "rumor"

func gen_all_hints(poi_mask: Dictionary[String, String], steps: int):
	"pregenerates all the rumors to one POI."
	for i in range(5,0,-1):
		# generate a true statement about the POI.
		while true:
			# consider how many guests a rumor refers to
			var num_desc = 0
			var hint
			var type = randi()%100
			if type < 40: # positive hint
				hint = {}
				var feature = poi_mask.keys().pick_random()
				hint[feature] = poi_mask[feature]
				hint = [hint, [], [], []]
			elif type >= 40 and type < 65: # negative hint
				var feats = cur_POI.mask_data["decor"]
				for feat in feats:
					if feat not in cur_POI.mask.keys():
						hint = feat
				# a mask might have all five. this makes the 
				# other hints more useful
				if hint == null: continue
				hint = [{}, [hint], [], []]
			elif type >= 65 and type < 80: # similarity hint
				print("attempting similarity hint")
				var guest = guest_list.pick_random()
				var n = guest_get_similar(guest.mask, cur_POI.mask)
				for j in range(10000):
					guest = guest_list.pick_random()
					while guest == cur_POI:
						guest = guest_list.pick_random()
					n = guest_get_similar(guest.mask, cur_POI.mask)
					if n > 1: break
				# try for n>1 but settle for 1 or even 0
				hint = [{}, [], [Vector2(guest_list.find(guest), n)], []]
				guest.rumors.append(rumors.gen_rumor_similar(n))
			else: # type >= 80:  # color match hint
				var seen_colors = []
				for feat in cur_POI.mask:
					var color = cur_POI.mask[feat]
					for other in cur_POI.mask:
						if feat == other:
							continue
						if color == cur_POI.mask[other]:
							hint = [feat, other]
							break
				if hint == null: continue
				hint = [{}, [], [], hint]
			# if that's 1, it gives it away
			if num_desc == 1: continue
			if hint in hints_queue: continue
			# if it's too high, it's not very helpful
			# with one hint, 7 is fine, then about 5, then 3, then 1
			var merged = merge_hints(hints_queue)
			#var merged_desc = omni_describes(merged[0], merged[1], merged[2],merged[3])
			print("MERGED HINTS: ", merged)
			#print("this describes ", merged_desc, " guests.")
			
			hints_queue.append(hint)
			break
	print("done")

func merge_hints(list):
	var merged = [{}, [], [], []]
	for hint in list:
		var mask = hint[0]
		var not_mask = hint[1]
		var similar = hint[2]
		var matches = hint[3]
		for feat in mask:
			merged[0][feat] = mask[feat]
		for missing in not_mask:
			merged[1].append(missing)
		for sim in similar:
			merged[2].append(sim)
		for feat in matches:
			merged[3].append(feat)
	return merged

func guest_get_similar(mask, other) -> int:
	"returns how many mask features two guests have in common. includes color"
	var so_far = 0
	for feature in mask:
		var unique = true
		if feature in other:
			if mask[feature] == other[feature]:
				so_far += 1
				unique = false
	return so_far

func mask_describes(mask) -> int:
	var so_far = 0
	for guest in guest_list:
		var does_describe = true
		for key in mask:
			# every detail present in the mask must be present in a 
			# given guest for them to be counted as described by it
			if not (key in guest.mask and mask[key] == guest.mask[key]):
				does_describe = false
		if does_describe:
			so_far += 1
	return so_far
func not_mask_describes(feature: String) -> int:	
	var so_far = 0
	for guest in guest_list:
		if feature not in guest.mask:
			so_far += 1
	return so_far
func similar_describes(mask, n) -> int:
	var so_far = 0
	for guest in guest_list:
		if guest_get_similar(mask, guest.mask) == n:
			so_far += 1
	return so_far
func match_describes(feature1, feature2) -> int:
	var so_far = 0
	for guest in guest_list:
		if guest.mask[feature1] == guest.mask[feature2]:
			so_far += 1
	return so_far
func unique_describes() -> int:
	var so_far = 0
	for guest in guest_list:
		var does_describe = true
		for other in guest_list:
			if guest == other:
				continue
			if guest_get_similar(guest.mask, other.mask) != 0:
				does_describe = false
				break
			else:
				so_far += 1
	return so_far
func omni_describes(mask, not_mask: Array[String], similar_guests: Array[Vector2], color_matches: Array[String]) -> int:
	"given any set of hints, returns how many guests they could refer to."
	# each element of similar_guests is a Vec2(guest_num, amount_similar)
	var so_far = 0
	for guest in guest_list:
		var does_describe = false
		# first, the raw mask details
		for key in mask:
			does_describe = true
			# every detail present in the mask must be present in a 
			# given guest for them to be counted as described by it
			if not (key in guest.mask and mask[key] == guest.mask[key]):
				does_describe = false
				break
		if not does_describe:
			continue
		# next, the similar guests
		for sim in similar_guests:
			var other = guest_list[sim[0]].mask
			if guest_get_similar(guest.mask, other) != sim[1]:
				does_describe = false
				break
		if not does_describe:
			continue
		# then, the features lacked...
		for feature in not_mask:
			if feature in guest.mask:
				does_describe = false
				break
		if not does_describe:
			continue
		# next... color matches
		#if len(color_matches) > 1:
		#	var color = guest.mask[color_matches[0]]
		#	color_matches.pop_front()
		#	for feature in color_matches:
		#		
			
			
		# finally, uniqueness
		#for other in guest_list:
		#	if guest_get_similar(guest.mask, other.mask) != 0:
		#		does_describe = false
		#		break
		#if not does_describe:
		#	continue
		so_far += 1
	return so_far
