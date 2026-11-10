extends Node

# sent from game manager
var guest_list: Array[Guest] = []
var rumor_manager
# generated when a POI is revealed.
var hints_queue = []
# the hints that the player has been given.
# determines how close they are to solving the POI
var hints_given = []


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
		var roll = randi()%100
		if roll < 40: # positive hint
			hint = {}
			var feature = poi_mask.keys().pick_random()
			hint[feature] = poi_mask[feature]
			hint = [hint, [], [], []]
		elif roll >= 40 and roll < 65: # negative hint
			for feat in poi_mask:
				if feat not in poi_mask.keys():
					hint = feat
			# a mask might have all five. this makes the 
			# other hints more useful
			if hint == null: continue
			hint = [{}, [hint], [], []]
		elif roll >= 65 and roll < 80: # similarity hint
			var guest: Guest
			var n
			for other in guest_list:
				if other.mask == poi_mask: continue
				n = guest_get_similar(other.mask, poi_mask)
				if n > 1: 
					guest = other
					break
				elif n == 1:
					guest = other
			# try for n>1 but settle for 1 or even 0
			if not guest: 
				n = 0
				guest = guest_list.pick_random()
			
			hint = [{}, [], [Vector2(guest_list.find(guest), n)], []]
			guest.rumors.append(rumor_manager.gen_rumor_similar(n))
		else: # roll >= 80:  # color match hint
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
	print(mask)
	print(other)
	print(so_far)
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
	# TODO: add hint type for which area of the ball the guest is in. 
	# east upper plaza, stairs, lower west plaza, et cetera
	
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
		
		# second, the features lacked...
		for feature in not_mask:
			if feature in guest.mask:
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
