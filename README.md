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

- [ ] Other feature
  
  - [ ] Sound
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

### UI Sound effects ?

### Menu architecture

## The results
