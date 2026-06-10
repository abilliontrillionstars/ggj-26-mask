extends Node

func gen_rumor_poi(poi_reason: String) -> String:
	"get some dialogue that details a guest's person of interest."
	var genned = mask_dialogue["describe_reason_prelude"].pick_random() + " "
	genned += mask_dialogue["poi_reasons"][poi_reason].pick_random()
	return genned

func gen_rumor_positive(feature: String, color: String) -> String:
	"get a rumor in the form 'has these features on their mask'."
	var genned = mask_dialogue["describe_mask_prelude"].pick_random() + " "
	genned += mask_dialogue["features"][feature].pick_random() + " "
	genned += color +" "+feature+"."
	return genned
func gen_rumor_negative(feature: String) -> String:
	"get a rumor in the form 'lacks this feature on their mask'."
	var genned = mask_dialogue["describe_mask_prelude"].pick_random() + " "
	genned += mask_dialogue["not_features"].pick_random() + " "
	genned += mask_dialogue["features"][feature].pick_random() + " "
	genned += feature + "."
	return genned
func gen_rumor_similar(n: int):
	"get a rumor in the form 'has n features in common with mine'."
	var genned = mask_dialogue["describe_mask_prelude"].pick_random() + " "
	genned += mask_dialogue["features_meta"]["similar_to_speaker"].pick_random()
	genned += " "+str(n)
	genned += mask_dialogue["features_meta"]["similar_to_speaker_post"].pick_random()
	return genned
func gen_rumor_unique():
	"get a rumour in the form 'had something unique to the whole party on their mask'."
	var genned = mask_dialogue["describe_mask_prelude"].pick_random() + " "
	genned += mask_dialogue["features_meta"]["unique"].pick_random()
	return genned
func gen_rumor_match(feature, feature2):
	"get a rumour in the form 'had two features matching color'."
	var genned = mask_dialogue["describe_mask_prelude"].pick_random() + " "
	genned += mask_dialogue["features"][feature].pick_random() + " "
	genned += feature + " "
	genned += mask_dialogue["features_meta"]["matching"].pick_random() + " "
	genned += feature2 + "."
	return genned

func gen_no_rumor():
	return mask_dialogue["no_rumors"].pick_random()

var mask_dialogue = {
	"describe_reason_prelude":[
		"A fellow at this party has",
		"Someone at this party has",
		"One of the partygoers has"
	],
	"poi_reasons":{
		"love":[
			"charmed me beyond what I'd usually admit. I simply must be reunited with them!",
			"given me the cold shoulder, and I must bid their heart once more!",
		],
		"thief":[
			"stolen my necklace! I'd like your help finding the culprit and getting it back.",
			"been stealing from the other guests. I've gotten permission to investigate, and you of course are the best person to help..."
		],
		"murder":[
			"committed the cold-blooded killing of another guest."
		]
	},
	"describe_mask_prelude":[
		"Their mask bore",
		"The mask they wore had",
		"On their mask, there was",
		"I remember their mask held"
	],
	"features":{
		"crest":[
			"an unmistakable",
			"a large",
			"a rather majestic"
		],
		"rhinestones":[
			"an array of brilliant",
			"a dazzling set of",
			"a shining line of"
		],
		"stitches":[
			"some eye-catching",
			"a sprinkle of",
			"a flourish of"
		],
		"centre":[
			"a",
		]
	},
	"not_features":[
		"an absence of",
		"a distinct lack of",
	],
	"features_meta":{
		"similar_to_speaker":[
			"some details which match my own mask.",
			"some similarities to this one.",
			"some bedazzlements that are also present on the one I'm wearing."
		],
		"similar_to_speaker_post":[
			", to be exact.",
			", if I recall..."
		],
		"unique":[
			"something worn by no other partygoer at the ball.",
			"a feature wholly unique to them. No other guests dared to copy them, it seems..."
		],
		"matching":[
			"matching its",
			"the same color of its"
		]
	},
	"rumor_leadin":[
		"Why, yes I do. Come, come...!",
		"As a matter of fact... this way - and check for followers, will you?"
	],
	"no_rumors":[
		"Sorry, friend. I've not anything for you.",
		"I haven't heard anything... though I wish you luck in your search.",
		"Oh, I'm not one to listen. You'll find someone else, I know it.",
		"Hmm... well, they certainly wore a mask. Does that help?"
	]
}
