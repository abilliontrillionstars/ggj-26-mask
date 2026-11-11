extends Camera2D

enum viewState { outer,ne,se,sw,nw,center }
var view = viewState.outer

func _ready() -> void:
	print(self.zoom, self.scale)
func _process(delta: float) -> void:
	# monkeypatch child nodes staying onscreen
	self.scale = Vector2(1.0,1.0)/self.zoom



func _on_ne_button_pressed() -> void:
	$CameraAnimator.play("to_ne")
	await $CameraAnimator.animation_finished
	view = viewState.ne
func _on_se_button_pressed() -> void:
	$CameraAnimator.play("to_se")
	await $CameraAnimator.animation_finished
	view = viewState.se
func _on_sw_button_pressed() -> void:
	$CameraAnimator.play("to_sw")
	await $CameraAnimator.animation_finished
	view = viewState.sw
func _on_nw_button_pressed() -> void:
	$CameraAnimator.play("to_nw")
	await $CameraAnimator.animation_finished
	view = viewState.nw
func _on_center_button_pressed() -> void:
	$CameraAnimator.play("to_center")
	await $CameraAnimator.animation_finished
	view = viewState.center

func _on_back_button_pressed() -> void:
	if view != viewState.outer:
		if view == viewState.ne:
			$CameraAnimator.play_backwards("to_ne")
		elif view == viewState.se:
			$CameraAnimator.play_backwards("to_se")
		elif view == viewState.sw:
			$CameraAnimator.play_backwards("to_sw")
		elif view == viewState.nw:
			$CameraAnimator.play_backwards("to_nw")
		elif view == viewState.center:
			$CameraAnimator.play_backwards("to_center")
