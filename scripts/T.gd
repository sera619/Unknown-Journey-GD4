extends Node

const CITIZEN_DIALOGS = [
	"Guten Morgen! Wie geht es dir heute?",
	"Das Wetter heute ist wunderbar, oder? Die Sonne scheint so hell!",
	"Hast du gehört, dass es heute Abend ein Fest geben wird? Ich freue mich schon darauf!",
	"Ich wünschte, es würde endlich regnen. Die Pflanzen brauchen Wasser.",
	"Ich habe gehört, dass es in der Nähe einen versteckten Schatz geben soll. Bist du auf der Suche danach?",
	"Pass auf, wenn du in den Wald gehst. Es gibt gefährliche Tiere dort draußen.",
	"Ich habe gerade einige frische Kräuter gepflückt. Möchtest du einige haben?",
	"Ich liebe es, wenn die Blätter im Herbst ihre Farbe wechseln. Es ist so schön anzusehen.",
	"Hast du schon gehört, dass sich eine Gruppe von Räubern in der Nähe herumtreibt? Sei vorsichtig!",
	"Ich habe gehört, dass es eine geheime Höhle gibt, die von einem alten Magier bewacht wird. Hast du sie schon gefunden?",
	"Es ist so schwer, gute Schmiedewerkzeuge zu finden. Ich würde alles dafür tun, um ein gutes Schwert zu bekommen.",
	"Ich habe gestern Nacht ein seltsames Geräusch gehört. Ich frage mich, was das gewesen sein könnte.",
	"Pass auf, wenn du die Straße entlang gehst. Es gibt Banditen, die Reisende überfallen.",
	"Ich habe das Gefühl, dass sich in der Luft eine große Veränderung anbahnt. Was denkst du?",
	"Das Essen im Gasthaus ist wirklich gut. Du solltest es unbedingt einmal ausprobieren!",
	"Ich wünschte, es gäbe hier mehr Läden. Es ist schwer, alles zu finden, was man braucht.",
	"Der Winter kann so kalt sein. Hoffentlich haben wir genug Vorräte, um durchzukommen.",
	"Hast du schon von der alten Legende des Drachen gehört, der in den Bergen lebt?",
	"Ich würde alles dafür tun, um das Schwert meines Vaters zurückzubekommen. Es wurde vor Jahren gestohlen.",
	"Ich habe gehört, dass es eine magische Quelle gibt, die unendliche Kraft verleiht. Hast du sie schon gefunden?",
	"Es ist so schön, dass die Blumen im Frühling wieder blühen. Es erinnert mich daran, dass alles wieder von vorne beginnt.",
	"Hast du das alte Herrenhaus auf dem Hügel gesehen? Es soll dort spuken.",
	"Ich habe gehört, dass es eine Stadt gibt, die von einem Fluch befallen ist. Niemand, der hineingeht, kommt jemals wieder heraus.",
	"Ich vermisse meine Familie. Sie sind in einem anderen Teil des Landes und ich habe sie schon so lange nicht mehr gesehen.",
	"Hast du schon einmal die Sternschnuppen im Sommer beobachtet? Es ist wunderschön.",
	"Ich habe gehört, dass es eine geheime Bibliothek gibt, die verbotene Bücher enthält. Bist du mutig genug, sie zu finden?"
]

const GREET_DIALOGS =[
	"Hallo! Wie geht's?",
	"Guten Morgen! Schön dich zu sehen.",
	"Hi! Wie war dein Tag?",
	"Hey! Wie läuft's?",
	"Moin! Alles klar?",
	"Guten Tag! Wie geht es dir heute?",
	"Servus! Wie war deine Nacht?",
	"Hallo zusammen! Wie geht's euch allen?",
	"Hola! Wie geht es dir?",
	"Grüß dich! Wie geht's?",
	"Guten Abend! Schön, dass du da bist.",
	"Aloha! Wie geht es dir heute?",
	"Salut! Wie war dein Tag bisher?",
	"Hiho! Wie geht's?",
	"Namaste! Schön dich zu sehen.",
	"Bonjour! Wie geht es dir?",
	"Ciao! Wie läuft's bei dir?",
]

func get_random_dialog() ->String:
	var ri = randi_range(0, CITIZEN_DIALOGS.size() -1)
	return CITIZEN_DIALOGS[ri]

func get_random_greeting() -> String:
	var ri = randi_range(0, GREET_DIALOGS.size() -1)
	return GREET_DIALOGS[ri]

const NPC_NAMES = {
	"male": [
		"Marty",
		"Aiden",
		"Orion",
		"Eldon",
		"Caelan",
		"Malakai",
		"Thorne",
		"Alaric",
		"Bran",
		"Eamon",
		"Ashe",
	],
		
	"female": [
		"Sarah",
		"Fee",
		"Elara",
		"Seraphine",
		"Lyra",
		"Isadora",
		"Danika",
		"Eirwen",
		"Aeloria",
		"Thalassa",
		"Amara",
		"Lirien",
	]
}

const INGAME_MAP_NAMES = [
	"Arkairos",
	"Düstermark",
	"Sonnenglanz",
	"Elfenhain",
	"kleiner Wald",
	"Hotel Keller",
	"Arkairos Hotel",
	"Marty's Laden",
	"Grüner Hain",
	"Schwert Grube",
	"Dunkler Wald",
	"Schattenwald",
	"Kristallturm",
	"Drachenfels",
	"Feuersee",
	"Silbermond",
	"Eisklippen",
	"Schlangengrube",
	"Phantomtiefen",
	"Sumpf des Verderbens",
	"Himmelsfeste",
	"Eisenzitadelle",
	"Blutmondhöhle",
	"Verlorenes Tal",
	"Schwarzwasserbucht",
	"Ruinenstadt",
	"Froststeppe",
]

const ACCEPT_DIALOG_TEXT: Dictionary = {
	"AUDIO_RESET": "Wenn du fortfährst werden ALLE Audio-Optionen auf die Standart-Einstellungen zurück gesetzt!\nMöchtest du die Audio-Optionen wirklich zurücksetzten?",
	"VIDEO_RESET": "Wenn du fortfährst werden ALLE Video-Optionen auf die Standart-Einstellungen zurück gesetzt!\nMöchtest du die Video-Optionen wirklich zurücksetzten?",
	"SAVE_RESET":  "Dieser Vorang wird ALLE Spielstände/Profile löschen!\nDieser Vorgang wird nur empfohlen wenn du eine ältere Spielstandversion gespielt hast!\nBist du sicher das du ALLE Speicherstände löschen willst?",
	"NO_NAME_INPUT": "Du hast keinen Namen ausgewählt.\nWenn du fortfährst wird dein Character\n\'Held\'\nheißen!\nMöchstest du mit diesem Namen starten?",
	"NAME_EXISTS": "Der eingegebene Name existiert bereits!\n\nBitte wähle eine neuen Namen für deinen Helden.",
	"VERSION_OUTDATED": "Deine aktuelle Spielversion ist veraltet du kannst eine neue Version downloaded wenn du okay klickst!",
	"HOTKEY_RESET": "Wenn du fortfährst werden ALLE Hotkey-Einstellungen auf Standart zurück gesetzt!\nMöchtest du die Hotkey-Einstellungen wirklich zurücksetzten?",
}
