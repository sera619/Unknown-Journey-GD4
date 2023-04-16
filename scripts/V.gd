extends Node

@export var accept_popup: PackedScene

var git_url = "https://raw.githubusercontent.com/sera619/Unknown-Journey-GD4/master/conf/base.cfg"
var path = "res://conf/base.cfg"
var temp_path = "user://temp_config.cfg"

func _version_check_routine():
	if not _check_internet_connection():
		print("[Versioncheck] No internet connection found.")
		return
	_get_github_file()

func _show_update_popup():
	var pop = accept_popup.instantiate()
	GameManager.interface.add_child(pop)
	pop.connect("popup_accept", _browse_github)
	pop.set_text(T.ACCEPT_DIALOG_TEXT.VERSION_OUTDATED)

func _browse_github():
	OS.shell_open("https://github.com/sera619/Unknown-Journey-GD4/releases")

func _check_internet_connection():
	var http = HTTPClient.new()
	var error = http.connect_to_host("https://www.google.de")
	return error == OK

func _check_versions():
	var current_conf = ConfigFile.new()
	current_conf.load(path)
	var loaded_conf = ConfigFile.new()
	loaded_conf.load(temp_path)
	var cur_version = current_conf.get_value("common", "version")
	var load_version = loaded_conf.get_value("common", "version")
	#print("Current Version: %s" % cur_version)
	#print("Avaiable Version: %s" % load_version)
	DirAccess.remove_absolute(temp_path)
	
	if cur_version != load_version:
		var t = "Deine aktuelle Spielversion:\n\"%s\"\nist veraltet.\nKlicke den \"Okay\"-Button um zum download der neuen Version:\n\"%s\"\nzu gelangen." % [cur_version, load_version]
		var pop = accept_popup.instantiate()
		GameManager.interface.add_child(pop)
		pop.connect("popup_accept", _browse_github)
		pop.set_text(t)

func _get_github_file():
	var http_request = HTTPRequest.new()
	self.add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	http_request.request(git_url)

func _on_request_completed(result, _response_code, _headers, body: PackedByteArray):
	if result != OK:
		print("Fehler beim Herunterladen der Datei:", result)
		return
	var error = FileAccess.open(temp_path, FileAccess.WRITE)
	var my_string = body.get_string_from_utf8()
	error.store_string(my_string)
	error.close()
	#print("Datei erfolgreich heruntergeladen und gespeichert.")
	_check_versions()

