extends TabContainer

var thread

@onready var manager = $SeasonManager
@onready var nextMatch = $NextMatch
@onready var league = $League
@onready var market = $Market/PanelPlayerData
@onready var settings = $Settings
@onready var disable = get_parent().get_parent().disable


func load_setup():
#	thread = Thread.new()
#	thread.start(Callable(self,"_thread_load_setup"))
#
#func _thread_load_setup():
	manager.load_setup()
	nextMatch.load_setup()
	league.load_setup()
	market.load_setup()
	settings.load_setup()

func _on_SeasonTab_tab_changed(tab):
	SeasonData.TabManager = tab
