extends Control
class_name MainMenu

func _on_mm_start_btn_button_down():
	print("[!] MainMenu: Start Btn clicked")
	GameManager.game.start_new_game()

func _on_mm_load_btn_button_down():
	print("[!] MainMenu: Load Btn clicked")
	GameManager.game.load_game()
	
	
func _on_mm_option_btn_button_down():
	print("[!] MainMenu: Option Btn clicked")

	pass # Replace with function body.


func _on_mm_exit_btn_button_down():
	print("[!] MainMenu: Exit Btn clicked")

	get_tree().quit()
