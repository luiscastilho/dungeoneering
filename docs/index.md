dungeoneering is a minimalistic virtual tabletop (VTT) that can be used as a combat grid or as a dungeon exploration tool, made for local tabletop RPG sessions. It can load static and animated maps, has a dynamic lighting system, offers lots of conditions that can be easily applied to tokens and more.

![dungeoneering screenshot]({{ "/docs/images/screenshot.png" | relative_url }} "dungeoneering screenshot")

The main goal here is to make an application with all the basic features needed to run a tabletop RPG session. It should be easy to install, setup and run and should have a minimalistic, intuitive and hopefully pretty user interface.



## Latest Version

The latest stable version along with release notes can be found on the project's [releases](https://github.com/luiscastilho/dungeoneering/releases) page. There's also a [changelog]({{site.baseurl}}/docs/CHANGELOG.md).



## Installation

1. In the [releases](https://github.com/luiscastilho/dungeoneering/releases) page, download the appropriate ZIP file for your operating system.
2. Extract all files to a folder of your choice — `Documents/dungeoneering` for example.
3. Run `dungeoneering.exe`, `dungeoneering.app`, or `dungeoneering` depending on your operating system.

### Windows

The application should work with the instructions above. If it doesn't, create an issue please.

### macOS

Coming soon!

### Linux

Coming soon too!



## How to Use It

To see how a scene looks like once it's composed you can load one of the demo scenes that come with the application. Click on the load scene button ([<img src="{{site.baseurl}}/dungeoneering/data/icons/app/load_idle.png" width="20" height="20" alt="load scene icon" title="load scene icon">](#how-to-use-it)) and choose a scene (`*.json` files) from the `data/scenes` folder.

To create a new scene follow the steps below. It might be better to do this when preparing an RPG session and not during it, since your players might get bored while they wait.

1. Click on the map setup button ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/map_idle.png" width="20" height="20" alt="map setup icon" title="map setup icon">](#how-to-use-it)) and choose an image or video to use as a map.
2. Click on the grid setup button ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/grid_idle.png" width="20" height="20" alt="grid setup icon" title="grid setup icon">](#how-to-use-it)) and follow the on-screen instructions to setup a grid over the map you chose.
3. Add player ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/hero_idle.png" width="20" height="20" alt="add player token icon" title="add player token icon">](#how-to-use-it)) and DM tokens ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/monster_idle.png" width="20" height="20" alt="add DM token icon" title="add DM token icon">](#how-to-use-it)) using the corresponding buttons.
4. Setup walls ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/wall_idle.png" width="20" height="20" alt="walls setup icon" title="walls setup icon">](#how-to-use-it)) and doors ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/setup/door_idle.png" width="20" height="20" alt="doors setup icon" title="doors setup icon">](#how-to-use-it)) using the corresponding buttons and following the on-screen instructions. Walls and doors are used to hide parts of the map and to block token light sources. With these elements in place you will have a dynamic lighting system, where players will only see parts of the map depending on where their characters are and what they can see.
5. If it's a combat scene, enable the initiative order widget by clicking on the combat button ([<img src="{{site.baseurl}}/dungeoneering/data/icons/scene/config/combat_idle.png" width="20" height="20" alt="combat icon" title="combat icon">](#how-to-use-it)). In this widget you can drag players or enemies to the position they should occupy based on the initiative they rolled.
6. Save your scene using the save button ([<img src="{{site.baseurl}}/dungeoneering/data/icons/app/save_idle.png" width="20" height="20" alt="save scene icon" title="save scene icon">](#how-to-use-it)) so you can load it when needed during your RPG sessions.

And that's it! Now that you have setup your scene, players and DM can drag their tokens around the map; right click on them to add conditions, light sources and sight types (e.g., darkvision); pan and zoom the map as needed; players can reveal hidden parts of the map with the dynamic lighting system; and hopefully with all that you and your group will have more fun in your RPG sessions. :)



## Contributing

dungeoneering code can be loaded, edited and run directly in [Processing](https://processing.org/) IDE. Clone this repository and open the `dungeoneering.pde` file in Processing.

Bugs can be reported through the project's [issues](https://github.com/luiscastilho/dungeoneering/issues) page. Also, there's a list of features to implement and known bugs to fix in the [TODO list]({{site.baseurl}}/docs/TODO.md).



## Known Issues

- Video and audio playback can be glitchy depending on the format/codec/framerate of the video being used. If you are having trouble with some of your video maps, try reencoding them to 1080p30. In Windows it's quite easy: use [HandBrake](https://handbrake.fr/) and in the Preset field choose General > Fast 1080p30. Create an issue please if it doesn't work even after reencoding.

- Tokens may look pixelated if zoom in is used, even if loading high-resolution token images.



## License

dungeoneering is licensed under the GPLv3. See [LICENSE.md]({{site.baseurl}}/LICENSE.md) for more details. dungeoneering also uses components from other open source projects. Their code and license can be found at these links:

- [Processing](https://github.com/processing/processing)
- [ControlP5](https://github.com/sojamo/controlp5) ([Forked](https://github.com/luiscastilho/controlp5) and customized)
- [PostFX for Processing](https://github.com/cansik/processing-postfx)
- [UiBooster](https://github.com/Milchreis/uibooster-for-processing)
- [Apache Commons](https://commons.apache.org/)
- [rotating-fos](https://github.com/vy/rotating-fos)



## Assets

There are a few demo scenes bundled with the application. The assets used in these scenes can be found at or created using the following links.

- The two awesome animated maps are from [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page").
- The [Abandoned Farmhouse map]({{site.baseurl}}/dungeoneering/data/maps/Static-AbandonedFarmhouse.jpg) is from Mike Schley, available in this [D&D article](https://dnd.wizards.com/articles/features/schley-stack "D&D Schley Stack article").
- The [Beholder Lair map]({{site.baseurl}}/dungeoneering/data/maps/Static-BeholderLair.jpg) is from [Antal Kéninger](https://www.artstation.com/kena "Antal Kéninger ArtStation profile").
- The [The Old Bridge map]({{site.baseurl}}/dungeoneering/data/maps/Static-TheOldBridge.jpg) is from [Sliph](https://www.patreon.com/sliph "Sliph Patreon").
- All tokens were created using [RollAdvantage's Token Stamp tool](https://rolladvantage.com/tokenstamp/ "Token Stamp tool") with D&D 5th edition images.



## Thanks

Thanks to my awesome RPG group that supported me in developing this application and were patient enough to playtest it in our sessions.

[![Claw token]({{site.baseurl}}/docs/images/playtesters/claw.png "Claw, Tabaxi Sorcerer (Wild Magic)")](#thanks)
[![Gruk token]({{site.baseurl}}/docs/images/playtesters/gruk.png "Gruk, Dwarf Fighter (Eldritch Knight)")](#thanks)
[![Labard token]({{site.baseurl}}/docs/images/playtesters/labard.png "Labard, Halfling Rogue (Assassin)")](#thanks)
[![Lander token]({{site.baseurl}}/docs/images/playtesters/lander.png "Lander, Human Cleric (Forge Domain)")](#thanks)
[![Naven token]({{site.baseurl}}/docs/images/playtesters/naven.png "Naven, Half-Elf Paladin (Oath of the Ancients)")](#thanks)
[![Sora token]({{site.baseurl}}/docs/images/playtesters/sora.png "Sora, Human Monk (Way of the Long Death)")](#thanks)

And thanks to [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page") for letting me use some of his maps on the demo scenes and even lending me an [exclusive map]({{site.baseurl}}/dungeoneering/data/maps/Animated-SwordCoast.mp4). Much appreciated!

[![Animated Dungeon Maps logo]({{site.baseurl}}/docs/images/logos/animated-dungeon-maps.png)](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page")