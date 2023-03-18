extends Control
class_name MainMenu

func _on_mm_start_btn_button_down():
	print("[!] MainMenu: Start Btn clicked")
	EventHandler.connect("transition_black", start_new)
	EventHandler.emit_signal("start_transition")
	
func _on_mm_load_btn_button_down():
	print("[!] MainMenu: Load Btn clicked")
	EventHandler.connect("transition_black", load_new)
	EventHandler.emit_signal("start_transition")

func _on_mm_option_btn_button_down():
	print("[!] MainMenu: Option Btn clicked")

func _on_mm_exit_btn_button_down():
	print("[!] MainMenu: Exit Btn clicked")
	get_tree().quit()

func start_new():
	EventHandler.disconnect("transition_black", start_new)
	GameManager.game.start_new_game()

func load_new():
	EventHandler.disconnect("transition_black", load_new)
	GameManager.game.load_game()
