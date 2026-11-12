extends Camera2D

enum viewState { outer,ne,se,sw,nw,center }
var view = viewState.outer

func _ready() -> void: pass
func _process(_delta: float) -> void:
	# monkeypatch child nodes staying onscreen
	self.scale = Vector2(1.0,1.0)/self.zoom

func _on_ne_button_pressed() -> void:
	$CameraAnimator.play("to_ne")
	await $CameraAnimator.animation_finished
	view = viewState.ne
	$"../GuestManager/NEButton".disabled = view==viewState.outer
	$BackButton.disabled = false
func _on_se_button_pressed() -> void:
	$CameraAnimator.play("to_se")
	await $CameraAnimator.animation_finished
	view = viewState.se
	$"../GuestManager/SEButton".disabled = view!=viewState.outer
	$BackButton.disabled = false
func _on_sw_button_pressed() -> void:
	$CameraAnimator.play("to_sw")
	await $CameraAnimator.animation_finished
	view = viewState.sw
	$"../GuestManager/SWButton".disabled = view!=viewState.outer
	$BackButton.disabled = false
func _on_nw_button_pressed() -> void:
	$CameraAnimator.play("to_nw")
	await $CameraAnimator.animation_finished
	view = viewState.nw
	$"../GuestManager/NWButton".disabled = view!=viewState.outer
	$BackButton.disabled = false
func _on_center_button_pressed() -> void:
	$CameraAnimator.play("to_center")
	await $CameraAnimator.animation_finished
	view = viewState.center
	$"../GuestManager/CenterButton".disabled = view!=viewState.outer
	$BackButton.disabled = false

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
		await $CameraAnimator.animation_finished
		view = viewState.outer
		$"../GuestManager/NEButton".disabled = view!=viewState.outer
		$"../GuestManager/SEButton".disabled = view!=viewState.outer
		$"../GuestManager/SWButton".disabled = view!=viewState.outer
		$"../GuestManager/NWButton".disabled = view!=viewState.outer
		$"../GuestManager/CenterButton".disabled = view!=viewState.outer
		$BackButton.disabled = true
