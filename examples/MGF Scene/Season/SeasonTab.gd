extends Control



@onready var manager: = $SeasonManager
@onready var nextMatch: = $NextMatch
@onready var league: = $League
@onready var market: = $Market/PanelPlayerData
@onready var settings: = $Settings

func load_setup() -> void:
	manager.load_setup()
	nextMatch.load_setup()
	league.load_setup()
	market.load_setup()
	settings.load_setup()

#func _on_SeasonTab_tab_changed(tab) -> void:
#	yield(get_tree().create_timer(Global.btntime), "timeout")
#	SeasonData.TabManager = tab

func _exit_tree():
	queue_free()
