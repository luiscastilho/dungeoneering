# Virtual tabletop for local, in-person RPG sessions

dungeoneering is a minimalistic virtual tabletop (VTT) that can be used as a combat grid or as a dungeon exploration tool, made for local, in-person tabletop RPG sessions. It can load static and animated maps, has a dynamic lighting system, offers lots of conditions that can be easily applied to tokens, and more.

<a class="lightbox" href="images/screenshot.png" title="dungeoneering screenshot"><img src="images/screenshot.png" alt="dungeoneering screenshot"/></a>

The main goal here is to make an application with all the basic features needed to run a tabletop RPG session. It should be easy to install, set up, and run and should have a minimalistic, intuitive, and hopefully pretty user interface.



## Latest Version

The latest stable version <span id="latest-version-number-inline"></span> can be downloaded on this page - links under Download Latest Version. It's also available, along with release notes, on the project's [releases](https://github.com/luiscastilho/dungeoneering/releases) page. There's also a [changelog](CHANGELOG.md) with all notable changes made to this project.



## Installation

1. On this page or on the [releases](https://github.com/luiscastilho/dungeoneering/releases) page, download the appropriate ZIP file for your operating system.
2. Extract all files to a folder of your choice — `Documents/dungeoneering` for example.
3. Run `dungeoneering`, `dungeoneeringDm`, or `dungeoneeringPlayers` depending on the screen configuration you plan to use. See ["Single and Dual Screen Modes"](#single-and-dual-screen-modes) below.

### Windows

The application should work with the instructions above. If it doesn't, create an issue, please.

### macOS

The macOS ZIP is unsigned, meaning macOS will complain about it. Once you unzip the macOS ZIP, right-click on each of the executables and choose Open. If asked, grant access to the Documents folder since that's where dungeoneering saves its log files on macOS.

### Linux

To run dungeoneering on Linux, you will need to install Gstreamer v0.10. It's an older version of Gstreamer so it might be difficult to find the right packages to install. If you are using Ubuntu 18.04 or 20.04, [this script](releases/ubuntu_install_prereqs.sh) should install everything you need. If you are using another Linux distribution, create an issue please and I will try to help you.



## How to Use It

Here's a video showing how to create a scene from scratch in dungeoneering:

<div class="video-wrap">
  <div class="video-container">
    <iframe src="https://www.youtube.com/embed/mLLleHoVkdk" allowfullscreen=""></iframe>
  </div>
</div>

If you prefer a text description instead of a video, read on.

To see how a scene looks like once it's composed you can load one of the demo scenes that come with the application. Click on the load scene button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/app/load_idle.png" width="20" height="20" alt="load scene icon" title="load scene icon">) and choose a scene (`*.json` files) from the `data/scenes` folder.

To create a new scene follow the steps below. It might be better to do this when preparing an RPG session and not during it since your players might get bored while they wait.

1. Click on the map setup button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/map_idle.png" width="20" height="20" alt="map setup icon" title="map setup icon">) and choose an image or video to use as a map.
2. Click on the grid setup button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/grid_idle.png" width="20" height="20" alt="grid setup icon" title="grid setup icon">) and follow the on-screen instructions to set up a grid over the map you chose.
3. Add player (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/hero_idle.png" width="20" height="20" alt="add player token icon" title="add player token icon">) and DM tokens (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/monster_idle.png" width="20" height="20" alt="add DM token icon" title="add DM token icon">) using the corresponding buttons.
4. Setup walls (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/wall_idle.png" width="20" height="20" alt="walls setup icon" title="walls setup icon">) and doors (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/setup/door_idle.png" width="20" height="20" alt="doors setup icon" title="doors setup icon">) using the corresponding buttons and following the on-screen instructions. Walls and doors are used to hide parts of the map and to block token light sources. With these elements in place, you will have a dynamic lighting system, where players will only see parts of the map depending on where their characters are and what they can see.
5. If it's a combat scene, first add tokens to the initiative order widget by right-clicking on them, then choosing Settings, and then clicking on the initiative button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/token/settings/toggle_initiative_idle.png" width="20" height="20" alt="initiative icon" title="initiative icon">). After that, enable the initiative order widget by clicking on the combat button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/scene/config/combat_idle.png" width="20" height="20" alt="combat icon" title="combat icon">). In this widget, you can drag players and enemies to the position they should occupy based on the initiative they rolled.
6. Save your scene using the save button (<img src="https://raw.githubusercontent.com/luiscastilho/dungeoneering/main/dungeoneering/data/icons/app/save_idle.png" width="20" height="20" alt="save scene icon" title="save scene icon">) so you can load it when needed during your RPG sessions.

And that's it! Now that you have set up your scene, players and DM can drag their tokens around the map; right click on them to add conditions, light sources, and sight types (e.g., darkvision); pan and zoom the map as needed; players can reveal hidden parts of the map with the dynamic lighting system; and hopefully with all that you and your group will have more fun in your RPG sessions. :)



## Single and Dual Screen Modes

If you are going to use a single screen, to be shared by DM and players, run the executable called `dungeoneering` and you are all set.

If you want to use two separate screens connected to the same computer, one for the DM and another one to be shared by your players, run `dungeoneeringDm` first, and once the application loads run `dungeoneeringPlayers`. The two applications should connect to each other and a scene loaded in the DM app should load in the players' app as well. After that any changes made in the scene should be replicated in both directions - a token moved by a player should move in the DM app, a condition applied by the DM should show up in the players' app, same for any other changes made in the scene.

Remember to disable any network software, such as VPN or proxy, before running dungeoneering in dual screen mode. In this mode, dungeoneering uses network ports to connect the two apps and in my tests, some network software caused problems and didn't let the two apps connect properly.



## Contributing

dungeoneering code can be loaded, edited, and run directly in [Processing](https://processing.org/){:target="_blank"} IDE (v3.x). Clone this repository and open the `dungeoneering.pde` file in Processing.

Bugs can be reported through the project's [issues](https://github.com/luiscastilho/dungeoneering/issues) page. Also, there's a list of features to implement and known bugs to fix in the [TODO list](TODO.md).



## Known Issues

- Dialog windows may appear behind the full-screen application, forcing users to switch between open windows to find the dialog that was just opened.

- Video and audio playback can be glitchy depending on the format/codec/framerate of the video being used. If you are having trouble with some of your video maps, try re-encoding them to 1080p30. In Windows it's quite easy: use [HandBrake](https://handbrake.fr/){:target="_blank"} and in the Preset field choose General > Fast 1080p30. Create an issue if it doesn't work even after re-encoding.

- Tokens may look pixelated if zoom in is used, even if loading high-resolution token images.



## License

Copyright © 2019-2021 Luis Castilho

dungeoneering is licensed under the GPLv3. See [LICENSE](https://github.com/luiscastilho/dungeoneering/blob/main/LICENSE.md) for details. dungeoneering also uses components from other open-source projects. Their code and license can be found at these links:

- [Processing](https://github.com/processing/processing){:target="_blank"}
- [ControlP5](https://github.com/sojamo/controlp5){:target="_blank"} ([Forked](https://github.com/luiscastilho/controlp5){:target="_blank"} and customized)
- [PostFX for Processing](https://github.com/cansik/processing-postfx){:target="_blank"}
- [UiBooster](https://github.com/Milchreis/uibooster-for-processing){:target="_blank"}
- [Apache Commons](https://commons.apache.org/){:target="_blank"}
- [rotating-fos](https://github.com/vy/rotating-fos){:target="_blank"}
- [Hazelcast IMDG](https://github.com/hazelcast/hazelcast){:target="_blank"}

The icons used in the application were either released under a public-domain-like license ([CC0](https://creativecommons.org/share-your-work/public-domain/cc0/){:target="_blank"}) or are free to use with attribution ([CC BY 3.0](https://creativecommons.org/licenses/by/3.0/){:target="_blank"}, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/){:target="_blank"}). Thanks to the following authors from the [Noun Project](https://thenounproject.com/){:target="_blank"}: Andrew Nielsen; Tokka Elkholy; Sweet Farm; HeadsOfBirds; Mike Rowe; Denis; Yu luck; Patrick Morrison; and Sergey Demushkin. Thanks to Delapouite, Lorc, and sbed from [Game-icons.net](https://game-icons.net/){:target="_blank"}. And thanks to Freepik and Good Ware from [Flaticon](https://www.flaticon.com/){:target="_blank"}.



## Assets

There are a few demo scenes bundled with the application. The assets used in these scenes can be found at or created using the following links.

- The two awesome animated maps are from [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page"){:target="_blank"}.
- The <a class="lightbox-link farmhouse" title="Abandoned Farmhouse map">Abandoned Farmhouse map</a> is from Mike Schley, available in this [D&D article](https://dnd.wizards.com/articles/features/schley-stack "D&D Schley Stack article"){:target="_blank"}.
- The <a class="lightbox-link beholder" title="Beholder Lair map">Beholder Lair map</a> is from [Antal Kéninger](https://www.artstation.com/kena "Antal Kéninger ArtStation profile"){:target="_blank"}.
- The <a class="lightbox-link illusionist" title="Dungeons of the Grand Illusionist map">Dungeons of the Grand Illusionist map</a> is from [Dyson Logos](https://www.patreon.com/dysonlogos "Dyson Logos Patreon page"){:target="_blank"}.
- The <a class="lightbox-link bridge" title="Old Bridge map">Old Bridge map</a> is from [Sliph](https://www.patreon.com/sliph "Sliph Patreon page"){:target="_blank"}.
- All tokens were created using the [Token Stamp tool](https://rolladvantage.com/tokenstamp/ "Token Stamp tool"){:target="_blank"} with D&D 5th edition images, © Wizards of the Coast.



## Thanks

Thanks to my awesome RPG group that supported me in developing this application and were patient enough to playtest it in our sessions. :heart:

![Claw token](images/playtesters/claw.png "Claw, Tabaxi Sorcerer (Wild Magic)")
![Gruk token](images/playtesters/gruk.png "Gruk, Dwarf Fighter (Eldritch Knight)")
![Labard token](images/playtesters/labard.png "Labard, Halfling Rogue (Assassin)")
![Lander token](images/playtesters/lander.png "Lander, Human Cleric (Forge Domain)")
![Naven token](images/playtesters/naven.png "Naven, Half-Elf Paladin (Oath of the Ancients)")
![Sora token](images/playtesters/sora.png "Sora, Human Monk (Way of the Long Death)")

And thanks to [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page"){:target="_blank"} for letting me use some of his maps on the demo scenes and even lending me an [exclusive map](https://github.com/luiscastilho/dungeoneering/blob/main/dungeoneering/data/maps/Animated-SwordCoast.mp4){:target="_blank"}. Much appreciated! :+1:

[![Animated Dungeon Maps logo](images/logos/partners/animated-dungeon-maps.png)](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page"){:target="_blank"}
