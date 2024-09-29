# Arkanoid

Arkanoid clone to practice godot

## To do

- [x] Game elements
  
  - [x] Player
  - [x] Ball
  - [x] Walls
    - Three difficulties. Difficulty == more hits to destroy
  - [x] "Goal"
  - [x] Level
    - [x] Level settings
      - [x] Difficulty
        - Depending on the difficulty more blocks of a higher level will appear
      - [x] Acceleration rate
        - The ball accelerates over time. the rate defines how much it will accelerate each time
      - [x] Size / nº of blocks
      - [x] Time limit
        - If the time limit is over => game finishes
    - [x] HUD
      - [x] score
      - [x] timer

- [x] UI
  
  - [x] Transitions
  - [x] Main menu
    - [x] Level selection
    - [x] Settings
      - [x] Sound settings
    - [x] High scores
      - [x] High score persistence
    - [x] Quit

- [x] Other feature
  
  - [x] Sound
  - [ ] particles
  - [ ] Shading
  - [ ] Shaders ?

## Code highlights

This section holds pieces of code that could be reused or have potential to be refined. They are not neccesarily good pieces of code (I'm currently just a begginer) just algorithms that could be useful in the future or that are unique to this project

### Difficulty algorithm

The level scene creates a group of blocks that has to be destroyed by the player.

For each block instantiated, the following algorithm was used to decide its type (the type defines how hard it is to break).

First we get a random float `rate` from 0 to 10, and define two `thresholds` for the medium and  hard types (medium has to be lower obviously). If a threshold is surpased by our random number, the next block to instantiate will be of the type of that threshold.

Now, we use the difficulty parameter to tweak those threshold, each one of them will decrease if the difficulty is higher, hence if the level is more difficult, harder blocks will spawn. The thresholds will decrease at different rates. Those rates are defined as `hardVarianceRate` and `mediumVarianceRate`

```gdscript
func decideBlockType(diff:float):
    var rate = randf_range(0,10)

    var easyThreshold = 6
    var mediumTheshold = 9

    const mediumVarianceRate = .5
    const hardVarianceRate = .4

    easyThreshold -= diff * mediumVarianceRate
    mediumTheshold -= diff * hardVarianceRate

    if rate <= easyThreshold:
        return  Block.blockType.easy
    elif rate <= mediumTheshold:
        return Block.blockType.medium
    else:
        return Block.blockType.hard
```

### High scores persistence

high scores need to be stored, but what's more, they also need to be sorted and stored in a comprehensive way, therefore, a custom resource is the way to go, as they can also store logic.

First we define what a high score is. It needs a name and a "score", so we first define a `HighScore` resource that serves as a model. This resource has its properties as exported. <mark>This is needed in order for the resource to be saved properly in disk</mark>

```gdscript
class_name HighScore extends Resource

@export var playerName:String
@export var score:int

func _init(n:String = "", s:int = 0) -> void:
    playerName = n
    score = s

func printHighScore():
    print("player name: " + playerName + " score: " + str(score))
```

Now we create the resource that will be saved, the `HighScores` resource. This resource will contain an array of exactly 10 highScores and will sort them each time a new one is added.

The rest is very easy, the `sort_high_scores()` uses the `sort_custom()`method of the Array class in gdscript to sort the array. Then the `add_high_score()` method receives a name and a score, create a new `HighScore`, appends it to the array, sorts the array and if the array is larger than `MAX_SIZE` cuts it out.

```gdscript
class_name HighScores extends Resource

const MAX_SIZE = 10

@export var _highScores:Array[HighScore] = []

func addHighScore(name:String, score:int)->HighScore:
    var hs = HighScore.new(name,score)
    _highScores.append(hs)
    sortHighScores()
    if _highScores.size() > MAX_SIZE:
        print_debug("entro")
        _highScores = _highScores.slice(0,MAX_SIZE)
    return hs

func getHighScores() -> Array[HighScore]:
    return _highScores


func clearHighScores() -> void:
    _highScores = []
    print_debug(_highScores)

func sortHighScores()->void:
    _highScores.sort_custom(func(a:HighScore,b:HighScore):
        if a.score > b.score:
            return true
        return false
    )
    pass
```

The last step is to be able to save and read from disk a resource of this type so that high scores persist between runs.

To achieve that, the `HighScoreManager` Class was created.

```gdscript
class_name HighScoreManager extends Node

const FILE_PATH = "user://high_scores.tres"

func createHighScoresResource() -> HighScores:
    var hs:HighScores = HighScores.new()
    var err = ResourceSaver.save(hs,FILE_PATH)
    if err:
        print_debug("Error creating new resource")
        return null

    else:
        return hs

func saveHighScore(playerName:String, score:int)->Array[HighScore]:
    if ResourceLoader.exists(FILE_PATH):
        var highScores:HighScores = ResourceLoader.load(FILE_PATH)
        highScores.addHighScore(playerName,score)
        var err = ResourceSaver.save(highScores, FILE_PATH)
        if err:
            print_debug("An error ocurred trying to save resource")
            return [null]

        return highScores.getHighScores()
    else:
        print_debug("Resource didn't exist. Creating one")
        var hs = createHighScoresResource()
        if hs != [null]:
            hs.addHighScore(playerName, score)
            var err = ResourceSaver.save(hs,FILE_PATH)
            if err:
                print_debug("An error ocurred trying to save resource")
                return [null]
            return hs

        return [null]

func getHighScores()->Array[HighScore]:
    if ResourceLoader.exists(FILE_PATH):
        var highScores:HighScores = ResourceLoader.load(FILE_PATH)
        return highScores.getHighScores()
    else:
        print_debug("There are no highScores")
        return []


func clearHighScores()->bool:
    var hs:HighScores = ResourceLoader.load(FILE_PATH)
    hs.clearHighScores()
    var err = ResourceSaver.save(hs,FILE_PATH)
    if err == null:
        print_debug("Error cleaning high scores")
        return false
    return true
```

It uses `ResourceSaver` and `ResourceLoader` as a means to load and store this resource persistently in the `FILE_PATH` route.

### Sound persistence

To manage Sound settings persistence, the `Audio Manager` class was created. It is fairly basic but can be used as a blueprint or proof of concept to further refine its behaviour. 

This class relies on the `AudioServer` class to manage the game's buses. This game has 4 audio busses: `Master`, `Effects`, `UI` and `Music` 

```gdscript
class_name AudioManager extends Node

signal bus_changed(b_name:String)

const CONFIG_FILE_PATH = "user://settings.cfg"
const SECTION_NAME = "Sound"

func _ready() -> void:
    load_volume_settings()

func set_bus_volume(b_name:String, n_vol:float)->bool:
    var b_idx := AudioServer.get_bus_index(b_name)
    if b_idx == -1: 
        print_debug("Error retrieving bus index: The bus does not exist")
        return false
    #AudioServer.set_bus_volume_db(3)
    AudioServer.set_bus_volume_db(b_idx,linear_to_db(n_vol))
    bus_changed.emit(b_name)
    return true

func get_bus_volume(b_name)->float:
    var b_idx := AudioServer.get_bus_index(b_name)
    if b_idx == -1: 
        print_debug("Error retrieving bus index: The bus does not exist")
        return false
    var volume := AudioServer.get_bus_volume_db(b_idx)
    return db_to_linear(volume)


func save_volume_settings():
    var config := ConfigFile.new()
    for b_idx in AudioServer.bus_count:
        var b_name := AudioServer.get_bus_name(b_idx)
        var b_volume := get_bus_volume(b_name)
        config.set_value(SECTION_NAME,b_name,b_volume)
    var err := config.save(CONFIG_FILE_PATH)
    if err:
        print_debug(err)
        return false
    return true


func load_volume_settings():
    var config := ConfigFile.new()
    var err := config.load(CONFIG_FILE_PATH)
    if err:
        print_debug("The file cannot be opened. Creating another one")
        save_volume_settings()
    for key in config.get_section_keys(SECTION_NAME):
        var volume = config.get_value(SECTION_NAME,key)
        set_bus_volume(key,volume)
```

#### Bus volume

To modify the volume of a bus we use the `set_bus_volume` method. It uses the string it gets as a parameter to get the index of the bus we want to change. Then use `AudioServer.set_bus_volume_db()` to modify its volume. This method gets the new volume in decibels, so we previously have to transform that value using `linear_to_db()`.

The `get_bus_volume()` method works in a similar fashion. This time the `db_to_linear()` method is used in order to get the volume in a comprehensive format. (according to our circumstances)

#### Persistence.

To store sound data a config file is used. Config files in godot group their data in sections. A call to store a value looks like this

```gdscript
config.set_value(SECTION_NAME,DATA_KEY,DATA_VALUE)
```

So the tipical scenario would be to use 1 config file for every configurable field of the game and separate data with sections. What this implies is the need for a module in charge of managing r/w to the config file from other modules, for example, the sound manager and the graphics manager both would need to write to the single file through the "Config file manager".

In this case however, there are no more configurable fields, so the config file can be created and modified in this module.

```gdscript
func _ready() -> void:
    load_volume_settings()


func save_volume_settings():
    var config := ConfigFile.new()
    for b_idx in AudioServer.bus_count:
        var b_name := AudioServer.get_bus_name(b_idx)
        var b_volume := get_bus_volume(b_name)
        config.set_value(SECTION_NAME,b_name,b_volume)
    var err := config.save(CONFIG_FILE_PATH)
    if err:
        print_debug(err)
        return false
    return true


func load_volume_settings():
    var config := ConfigFile.new()
    var err := config.load(CONFIG_FILE_PATH)
    if err:
        print_debug("The file cannot be opened. Creating another one")
        save_volume_settings()
    for key in config.get_section_keys(SECTION_NAME):
        var volume = config.get_value(SECTION_NAME,key)
        set_bus_volume(key,volume)
```

Data is read once the component is ready by invoking `load_volume_settings()` . This method creates a config file object that reads the config file path and loops through the sound section getting the keys (the buse`s names) and assigning the corresponding volume value to each bus.

Data can  be saved with `save_volume_settings()` which again creates a config file that reads the values of each audio bus and stores it inside the config file.

### UI Sound effects

There are several approaches to adding sounds to UI. A viable one could be to create "low level" custom scenes for buttons and so on and give each one a `AudioSteamPlayer` with its respective sounds. This however involves creating too many audio sources.

Another approach is to instead create a scene with the audioSteamPlayers needed and let this scene be the one that plays the sounds when the buttons are pressed.

```gdscript
class_name UISounds extends Node

@export var menu_root:NodePath

@export_category("sound effects")
@export var accept_effect:AudioStream
@export var cancel_effect:AudioStream
@export var focus_effect:AudioStream


# The & character is for StringNames
@onready var sounds := {
	&"accept": AudioStreamPlayer.new(),
	&"cancel": AudioStreamPlayer.new(),
	&"focus": AudioStreamPlayer.new()
}


func _ready() -> void:
	assign_sounds()
	for key in sounds:
		add_child(sounds[key])
		attach_signals(get_node(menu_root))


func play_ui_sound(sound_name:StringName):
	if sounds[sound_name]:
		sounds[sound_name].play()


func assign_sounds()->void:
	sounds[&"accept"].stream = accept_effect
	sounds[&"accept"].bus = "UI"
	sounds[&"cancel"].stream = cancel_effect
	sounds[&"cancel"].bus = "UI"
	sounds[&"focus"].stream = focus_effect
	sounds[&"focus"].bus = "UI"
	
	
# A custom Button class is needed so that if the button is a cancel button another sound is played
## Recursively runs through the node tree from "node" attaching sounds to buttons
func attach_signals(node:Node):
	print_debug(node)
	if node is Button:
		node.mouse_entered.connect(func(): play_ui_sound(&"focus"))
		node.focus_entered.connect(func(): play_ui_sound(&"focus"))
		node.pressed.connect(func(): play_ui_sound(&"accept"))
		
	if node.get_child_count() == 0:
		return 
		
	else:
		for n in node.get_children():
			attach_signals(n)

```

This scene has a dictionary called sounds with an audio source for every type of sound that can be played. This sounds can be set through the editor and are then set on_ready through the `assign sounds` method.

The last step is the `attach_signals` function, that recursively runs throught the tree starting from the `node` parameter.

If the current node being explored is a button, it attaches the `play_sound()` function to its signals. Then, it checks if the node has more children, if it does, it loops through every one of them are runs `attach_signals()` again. If not just returns

#### Extending this behaviour.

This architecture can be expanded to create more nuanced sounds by writing custom scenes for basic UI elements. 

A custom button with a `cancel` flag could be created. This way, if the node exploring (which would be of class `CustomBtn`) has this flag == true, instead of assigning  the accept sound to its signal, we would assign the cancel one (and so on).

#### Problematic behaviour

Depending on how the menu architecture has been handled, some sounds could present unwanted behaviours. For example, if a button is in charge of navigation to another scene, maybe the scene change happens before the sound has been played.

This type of scenario has to be taken into account when writing both the menu architecture and the UISounds module.

### Menu architecture

The approach used in this project is a bad execution of a half cooked idea. However, it can lead to a proper way of handling UI architecture if refined.

```gdscript
class_name Menu extends Control

const MAIN_MENU_PATH = "res://UI/Menus/MainMenu/main_menu.tscn"


## Meant to be connected with its parent. When connected will tipically run _on_child_menu_back()
signal back(child_menu:Menu)

## The first element that should grab focus when getting shown
@export var element_to_focus:Control = null


func _ready():
	_on_visibility_changed()
	self.visibility_changed.connect(_on_visibility_changed)

## hides the menu passed as parameter and shows its parent
func _on_child_menu_back(child_menu:Menu):
	child_menu.hide()
	if self is Menu:
		self.show()

## hides the current menu and shows the menu to navigate to
func _navigate_to(menu:Menu):
	self.hide()
	menu.show()

func _on_visibility_changed():
	if visible:
		if element_to_focus != null:
			element_to_focus.grab_focus()


func change_to_scene(n_scene_path:String, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene_path == null:
		return false
	
	get_tree().paused = true
	#Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_file(n_scene_path)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	#Engine.time_scale = 1
	
	return true


func change_to_packed_scene(n_scene:PackedScene, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene == null:
		return false
	
	get_tree().paused = true
	#Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_packed(n_scene)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	#Engine.time_scale = 1
	
	return true
	


func quit():
	get_tree().quit()

```

#### "Local navigation"

The architecture has been designed so that every view is a `Menu` and sibling Menus can easily navigate between then. A "Complete menu" such as the pause menu will really just be a container of individual menus (they really are views).

<img title="" src="file:///C:/Users/Guillermo/AppData/Roaming/marktext/images/2024-09-29-12-12-33-image.png" alt="" data-align="center">

A menu scene has a back signal that will be emmited and caught manually whenever a menu wishes to go back to its predecesor. This signal will be tipically handled by the father using the `_on_child_menu_back()` 

```gdscript
# Father component
func _on_settings_menu_back(menu:Menu) -> void:
	_on_child_menu_back(menu)
```

This can evidenlty be refined, but i think is a good starting point.

Every Menu Scene also has  a `navigate_to()` method that simply hides the current Menu scene and shows the new one.

The visibility changed signal is handled to work in conjunction to every method described earlier. Whenever the Menu is visible, the `element_to_focus` node will be focused to ensure navigation with keyboard/controller is also possible.

#### Scene navigation

Menus also need to navigate to other scenes. This can be done easily with the `get_tree().change_scene` methods. However, it is important to encapsulate this behaviour so that more features can be easily added.

For example, in this case, changes in scenes trigger fade in /out transitions.

```gdscript
func change_to_packed_scene(n_scene:PackedScene, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene == null:
		return false
	
	get_tree().paused = true
	#Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_packed(n_scene)
	await GlobalTransitions.play_transition(out_transition)

	get
```

#### Future work

As stated before, the "local" way of managing menu scenes is a valid starting point but needs a lot of work. For instance, There should be a basic `MenuElement` Scene that every other element inherits from.

After that, there should be a difference between views (settings, level select...) and Big menus that encapsulate this views (pause menu, main menu etc) as for the local transitions to work (without changes in scenes) the views need to be siblings.

If main menu was attached to the parent node of the main menu scene, when navigating, triggering `hide` would hide the whole menu, including the rest of the views. This is why the semantic nuance is needed.

Also, custom element classes could be created such as `CustomBtn` so that more nuance could be added into UISound (exaplined in the UI sounds section)

# 
