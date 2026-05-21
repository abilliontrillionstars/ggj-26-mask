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
	gen_all_hints(cur_POI.mask)
	
	#dialogue_box.queue_text("Rumors? Hmm...")
	#dialogue_box.queue_text(rumors.gen_rumor_poi("thief"))
	#
	#dialogue_box.queue_text(rumors.gen_rumor_positive("stitches", "emerald"))
	#var num_desc = omni_describes({"stitches": "emerald"}, [], [], [])
	#dialogue_box.queue_text("Emerald stitches... that describes "+str(num_desc)+" guests.")
	#
	#dialogue_box.queue_text(rumors.gen_rumor_negative("centre"))
	#num_desc = omni_describes({}, ["centre"], [], [])
	#dialogue_box.queue_text("No centrepiece... that describes "+str(num_desc)+" guests.")
	#
	#dialogue_box.queue_text(rumors.gen_rumor_similar(2))
	#num_desc = omni_describes({}, [], [ Vector2(guest_list.find(cur_POI), 2.0) ], [])
	#dialogue_box.queue_text("Two similarities to mine... that describes "+str(num_desc)+" guests.")
func _process(_delta: float) -> void:
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

func gen_all_hints(poi_mask: Dictionary[String, String]):
	"pregenerates all the rumors to one POI."
	for i in range(5,0,-1):
		# generate a true statement about the POI.
		var hint = gen_hint(poi_mask)
		hints_queue.append(hint)
		var merged = merge_hints(hints_queue)
		var merged_desc = omni_describes(merged[0], merged[1], merged[2],merged[3])
		print("MERGED HINTS: ", merged)
		print("this describes ", merged_desc, " guests.")
func gen_hint(poi_mask: Dictionary[String, String]):
	# consider how many guests a rumor refers to
	var num_desc = 0
	var hint
	while true:
		var type = randi()%100
		if type < 40: # positive hint
			hint = {}
			var feature = poi_mask.keys().pick_random()
			hint[feature] = poi_mask[feature]
			hint = [hint, [], [], []]
		elif type >= 40 and type < 65: # negative hint
			for feat in poi_mask:
				if feat not in poi_mask.keys():
					hint = feat
			# a mask might have all five. this makes the 
			# other hints more useful
			if hint == null: continue
			hint = [{}, [hint], [], []]
		elif type >= 65 and type < 80: # similarity hint
			var guest = guest_list.pick_random()
			var n = guest_get_similar(guest.mask, poi_mask)
			for j in range(10000):
				guest = guest_list.pick_random()
				while guest == cur_POI:
					guest = guest_list.pick_random()
				n = guest_get_similar(guest.mask, poi_mask)
				if n > 1: break
			# try for n>1 but settle for 1 or even 0
			hint = [{}, [], [Vector2(guest_list.find(guest), n)], []]
			guest.rumors.append(rumors.gen_rumor_similar(n))
		else: # type >= 80:  # color match hint
			var seen_colors = {}
			# count matching colors
			for feat in poi_mask:
				var color = poi_mask[feat]
				if not seen_colors.has(color):
					seen_colors[color] = []
				else:
					seen_colors[color].append(feat)
			# if there are multiple match sets, pick the largest
			hint = []
			for color in seen_colors:
				if seen_colors[color].size() > hint.size():
					hint = seen_colors[color]
			# invalid: no color matches at all
			if hint.size() < 2: continue
			hint = [{}, [], [], hint]
		
		# if that's 1, it gives it away
		if num_desc == 1: continue # try again
		# if that exact hint has already been given
		if hint in hints_queue: continue # try again
		# if it's too high, it's not very helpful
		# with one hint, 7 is fine, then about 5, then 3, then 1
		break
	return hint

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
		if feature in other:
			# check for a color match
			if mask[feature] == other[feature]:
				so_far += 1
	return so_far

func mask_describes(mask) -> int:
	return omni_describes(mask, [], [], [])
func not_mask_describes(feature: String) -> int:	
	return omni_describes({}, [feature], [], [])
func similar_describes(mask, n) -> int:
	# find the guest
	var g = null
	for guest in guest_list:
		if guest.mask == mask:
			g = guest
	var i = guest_list.find(g)
	return omni_describes({}, [], [Vector2(i, n)], [])
func match_describes(feats: Array[String]) -> int:
	return omni_describes({}, [], [], feats)
func omni_describes(mask, not_mask, similar_guests, color_matches) -> int:
	"given any set of hints, returns how many guests they could refer to."
	
	# each element of similar_guests is a Vec2(guest_num, amount_similar)
	var so_far = 0
	for guest in guest_list:
		var does_describe = false

		# first, the raw mask details
		for key in mask:
			does_describe = true
			# every detail present in the hint must be present in a 
			# given guest for them to be counted as described by it
			if not (key in guest.mask and mask[key] == guest.mask[key]):
				does_describe = false
				break
		# every part of the merged hint must apply
		if not does_describe: continue

		# next, the similar guests
		for sim in similar_guests:
			var other = guest_list[sim[0]].mask
			if guest_get_similar(guest.mask, other) != sim[1]:
				does_describe = false
				break
		# every part of the merged hint must apply
		if not does_describe: continue

		# then, the features lacked...
		for feature in not_mask:
			if feature in guest.mask:
				does_describe = false
				break
		# every part of the merged hint must apply
		if not does_describe: continue

		## next... color matches
		#if len(color_matches) > 1:
			#var color = guest.mask[color_matches[0]]
			#color_matches.pop_front()
			#for feature in color_matches:
		
		
		# finally, uniqueness
		#for other in guest_list:
		#	if guest_get_similar(guest.mask, other.mask) != 0:
		#		does_describe = false
		#		break
		#if not does_describe:
		#	continue
		so_far += 1
	return so_far

func on_guest_pressed(guest):
	switch_room()
	if guest.rumors != []:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.roll_text(guest.rumors.pop_front())
	else:
		dialogue_box.roll_text("Rumors?")
		dialogue_box.queue_text(rumors.gen_no_rumor())
