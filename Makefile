version = "TechAlpha-v0.2.8"

build: clean
	cls
	@C:\1Coding\GDScript\godot.exe --export-debug "Windows Desktop"

clean:
	@C:\1Coding\GDScript\godot.exe --version
	@if exist "./export/windows" del /s /q .\export\windows
	@if exist "./export/web" del /s /q .\export\web

pack: build
	cls
	@powershell write-host -fore Yellow "Start packaging process..."
	@if exist "./export/windows/UnknownJourney-TechAlpha.zip" del /s /q .\export\windows\UnknownJourney-TechAlpha.zip
	@move .\export\windows\UnknownJourney-TechAlpha.exe .
	@move .\export\windows\UnknownJourney-TechAlpha.console.exe .
	@tar.exe -a -c -f UnknownJourney-TechAlpha.zip UnknownJourney-TechAlpha.exe UnknownJourney-TechAlpha.console.exe
	@powershell write-host -fore Yellow "Package created, clean up files ..."
	@move .\UnknownJourney-TechAlpha.zip .\export\windows
	@del /s /q .\UnknownJourney-TechAlpha.exe
	@del /s /q .\UnknownJourney-TechAlpha.console.exe
	@powershell write-host -fore Yellow "Create new Github-Release for version: $(version)..."
	@gh release create $(version) -F .\changelog.md '.\export\windows\UnknownJourney-TechAlpha.zip#Windows'
	@powershell write-host -fore Green "Packaging successfully finished!"