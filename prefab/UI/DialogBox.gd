extends Control
class_name DialogBox

@onready var speakername_label: Label = $BG/M/v/NameBox/M/NameLabel
@onready var dialog_label:Label = $BG/M/v/TextBox/M/DialogTextLabel
@onready var option_a_label:Label = $BG/M/v/H/DialogOptionABtn/Label
@onready var option_b_label:Label = $BG/M/v/H/DialogOptionBBtn/Label
@onready var option_a_btn: TextureButton= $BG/M/v/H/DialogOptionABtn
@onready var option_b_btn: TextureButton= $BG/M/v/H/DialogOptionBBtn

var tween: Tween = null

func _ready():
	GameManager.register_node(self)
	reset_dialog()
	self.visible = false

func show_dialog():
	self.visible = true
	GameManager.player.set_process_input(false)
	start_dialog_writing()

func reset_dialog():
	dialog_label.visible_ratio = 0.0
	dialog_label.text = ""
	speakername_label.text = ""
	option_a_label.text = "Okay"
	option_b_label.text = "Zurück"
	if tween != null and tween.is_running():
		tween.stop()
		tween.kill()

func set_dialog_text(text: String):
	dialog_label.text = text

func set_speaker_name(speakername: String):
	speakername_label.text = speakername

func set_options_text(optionA: String, optionB: String):
	option_a_label.text = optionA
	option_b_label.text = optionB

func start_dialog_writing():
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(dialog_label, "visible_ratio", 1.0, 3)
	tween.tween_callback(tween.kill)

func hide_dialog():
	GameManager.player.set_process_input(true)
	self.hide()

func _on_dialog_option_b_btn_button_down():
	print("[!] DialogBox: Option B: \"%s\" choosed!" % option_b_label.text)
	reset_dialog()
	hide_dialog()

func _on_dialog_option_a_btn_button_down():
	print("[!] DialogBox: Option A: \"%s\" choosed!" % option_a_label.text)
	reset_dialog()
	hide_dialog()
	
