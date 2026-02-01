extends RichTextLabel

#chars per second
var typing_speed = 50
var is_typing = false
var text_queue = []


func _ready() -> void:
	# note to self: this looks deceptive but is fine.
		# $ notation just can only see children, and 
		# the node must be loaded (which it is when
		# this _ready is called), making it safe here.
	$NextButton.pressed.connect(self.next_text)

	
func next_text():
	if not is_typing:
		if len(text_queue) > 0:
			roll_text(text_queue.pop_front())
		else:
			roll_text("Or so I hear...")
			$NextButton.disabled = true
			$/root/root/RoomButtonPivot.play("appear")
func queue_text(t: String) -> void:
	text_queue.append(t)
func roll_text(t: String) -> void:
	# concurrency lock
	is_typing = true
	# animate the text character by character
	self.visible_characters = 0
	self.text = t
	for char in t:
		self.visible_characters += 1
		# no typing sound, I think
		#AudioStreamPlayer
		# compact delay thing. looks jank but it's common I promise
		# if you don't believe me look at the docs for create_timer
		await get_tree().create_timer(1.0/typing_speed).timeout
	# release lock
	is_typing = false
