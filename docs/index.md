# Virtual tabletop (VTT) for local, in-person RPG sessions

dungeoneering is a free and slimmed down virtual tabletop (VTT) that can be used as a combat grid and as a dungeon exploration tool, made for local, in-person tabletop RPG sessions. It can load static and animated maps, has a dynamic lighting system, can be easily used with D&D 5e games, and more.

<a class="lightbox" href="/assets/img/screenshot/screenshot.jpg" title="dungeoneering virtual tabletop screenshot"><img class="fit-width" src="/assets/img/screenshot/screenshot-thumb.jpg" alt="dungeoneering virtual tabletop screenshot" width="850" height="478" /></a>

The main goal here is to make an application with all the basic features needed to run a tabletop RPG session. It should be easy to install, set up, and run and should have a minimalistic, intuitive, and hopefully pretty user interface.



## Latest Version

The latest stable version <span id="latest-version-number-inline"></span>, available for Windows, Linux and macOS, can be downloaded on this page. It's also available, along with release notes, on the project's [releases](https://github.com/luiscastilho/dungeoneering/releases) page. There's also a [changelog](CHANGELOG.md) with all notable changes made to this project.



## Installation

1. On this page or on the [releases](https://github.com/luiscastilho/dungeoneering/releases) page, download the appropriate ZIP file for your operating system.
2. Extract all files to a folder of your choice — `Documents/dungeoneering` for example.
3. Run `dungeoneering`, `dungeoneeringDm`, or `dungeoneeringPlayers` depending on the screen configuration you plan to use. See [Single and Dual Screen Modes](#single-and-dual-screen-modes) below.

### Windows

The application should work with the instructions above. If it doesn't, create an issue, please.

### macOS

The macOS ZIP is unsigned, meaning macOS will complain about it. Once you unzip it, right-click on each of the executables and choose Open. If asked, grant access to the Documents folder since that's where dungeoneering saves its log files on macOS.

### Linux

To run dungeoneering on Linux, you will need to install Gstreamer v0.10. It's an older version of Gstreamer so it might be difficult to find the right packages to install. If you are using Ubuntu 18.04 or 20.04, [this script](releases/ubuntu_install_prereqs.sh) should install everything you need. If you are using another Linux distribution, create an issue please and I will try to help.



## How to Use It

Here's a video showing how to create a scene from scratch in dungeoneering:

<div class="video-wrap">
  <div class="video-container">
    <iframe
      class="lazyload"
      data-src="https://www.youtube.com/embed/mLLleHoVkdk"
      allowfullscreen=""
	  title="dungeoneering tutorial video"></iframe>
  </div>
</div>

If you prefer a text description, read on.

To see how a scene looks like once it's composed you can load one of the demo scenes that come with the application. Click on the load scene button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/load_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/load_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/load_idle.png"><img class="lazyload" data-src="/assets/img/icons/load_idle.jpg" width="20" height="20" alt="load scene icon" title="load scene icon" /></picture> ) and choose a scene (`*.json` files) from the `data/scenes` folder.

To create a new scene follow the steps below. It might be better to do this when preparing an RPG session and not during it since your players might get bored while they wait.

1. Click on the map setup button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/map_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/map_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/map_idle.png"><img class="lazyload" data-src="/assets/img/icons/map_idle.jpg" width="20" height="20" alt="map setup icon" title="map setup icon" /></picture> ) and choose an image or video to use as a map.
2. Click on the grid setup button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/grid_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/grid_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/grid_idle.png"><img class="lazyload" data-src="/assets/img/icons/grid_idle.jpg" width="20" height="20" alt="grid setup icon" title="grid setup icon" /></picture> ) and follow the on-screen instructions to set up a grid over the map you chose.
3. Add player ( <picture><source type="image/webp" data-srcset="/assets/img/icons/hero_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/hero_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/hero_idle.png"><img class="lazyload" data-src="/assets/img/icons/hero_idle.jpg" width="20" height="20" alt="add player token icon" title="add player token icon" /></picture> ) and DM tokens ( <picture><source type="image/webp" data-srcset="/assets/img/icons/monster_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/monster_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/monster_idle.png"><img class="lazyload" data-src="/assets/img/icons/monster_idle.jpg" width="20" height="20" alt="add DM token icon" title="add DM token icon" /></picture> ) using the corresponding buttons.
4. Setup walls ( <picture><source type="image/webp" data-srcset="/assets/img/icons/wall_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/wall_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/wall_idle.png"><img class="lazyload" data-src="/assets/img/icons/wall_idle.jpg" width="20" height="20" alt="walls setup icon" title="walls setup icon" /></picture> ) and doors ( <picture><source type="image/webp" data-srcset="/assets/img/icons/door_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/door_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/door_idle.png"><img class="lazyload" data-src="/assets/img/icons/door_idle.jpg" width="20" height="20" alt="doors setup icon" title="doors setup icon" /></picture> ) using the corresponding buttons and following the on-screen instructions. Walls and doors are used to hide parts of the map and to block token light sources. With these elements in place, you will have a dynamic lighting system, where players will only see parts of the map depending on where their characters are and what they can see.
5. If it's a combat scene, first add tokens to the initiative order widget by right-clicking on them, then choosing Settings, and then clicking on the initiative button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/toggle_initiative_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/toggle_initiative_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/toggle_initiative_idle.png"><img class="lazyload" data-src="/assets/img/icons/toggle_initiative_idle.jpg" width="20" height="20" alt="initiative icon" title="initiative icon" /></picture> ). After that, enable the initiative order widget by clicking on the combat button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/combat_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/combat_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/combat_idle.png"><img class="lazyload" data-src="/assets/img/icons/combat_idle.jpg" width="20" height="20" alt="combat icon" title="combat icon" /></picture> ). In this widget, you can drag players and enemies to the position they should occupy based on the initiative they rolled.
6. Save your scene using the save button ( <picture><source type="image/webp" data-srcset="/assets/img/icons/save_idle.webp"><source type="image/jpeg" data-srcset="/assets/img/icons/save_idle.jpg"><source type="image/png" data-srcset="/assets/img/icons/save_idle.png"><img class="lazyload" data-src="/assets/img/icons/save_idle.jpg" width="20" height="20" alt="save scene icon" title="save scene icon" /></picture> ) so you can load it when needed during your RPG sessions.

And that's it! Now that you have set up your scene, players and DM will have a virtual tabletop where they can drag their tokens around the map; right click on them to add conditions, light sources, and sight types (e.g., darkvision); pan and zoom the map as needed; players can reveal hidden parts of the map with the dynamic lighting system; and hopefully with all that you and your group will have more fun in your RPG sessions. :)



## Single and Dual Screen Modes

If you are going to use a single screen, to be shared by DM and players, run the executable called `dungeoneering` and you are all set.

If you want to use two separate screens connected to the same computer, one for the DM and another one to be shared by your players, run `dungeoneeringDm` first, and once the application loads run `dungeoneeringPlayers`. The two applications should work as a single virtual tabletop, they should connect to each other and a scene loaded in the DM app should load in the players' app as well. After that any changes made in the scene should be replicated in both directions - a token moved by a player should move in the DM app, a condition applied by the DM should show up in the players' app, same for any other changes made in the scene.

Remember to disable any network software, such as VPN or proxy, before running dungeoneering in dual screen mode. In this mode, dungeoneering uses network ports to connect the two apps and in my tests, some network software caused problems and didn't let the two apps connect properly.



## Contributing

dungeoneering code can be loaded, edited, and run directly in [Processing](https://processing.org/){:target="_blank" rel="noopener"} IDE (v3.x). Clone this repository and open the `dungeoneering.pde` file in Processing.

Bugs can be reported through the project's [issues](https://github.com/luiscastilho/dungeoneering/issues) page. Also, there's a list of features to implement and known bugs to fix in the [TODO list](TODO.md).



## Known Issues

- Dialog windows may appear behind the full-screen application, forcing users to switch between open windows to find the dialog that was just opened.

- Video and audio playback can be glitchy depending on the format/codec/framerate of the video being used. If you are having trouble with some of your video maps, try re-encoding them to 1080p30. In Windows it's quite easy: use [HandBrake](https://handbrake.fr/){:target="_blank" rel="noopener"} and in the Preset field choose General > Fast 1080p30. Create an issue if it doesn't work even after re-encoding.

- Tokens may look pixelated if zoom in is used, even if loading high-resolution token images.



## License

Copyright © 2019-2021 Luis Castilho

dungeoneering is licensed under the GPLv3. See [LICENSE](https://github.com/luiscastilho/dungeoneering/blob/main/LICENSE.md) for details. dungeoneering also uses components from other open-source projects. Their code and license can be found at these links:

- [Processing](https://github.com/processing/processing){:target="_blank" rel="noopener"}
- [ControlP5](https://github.com/sojamo/controlp5){:target="_blank" rel="noopener"} ([Forked](https://github.com/luiscastilho/controlp5){:target="_blank" rel="noopener"} and customized)
- [PostFX for Processing](https://github.com/cansik/processing-postfx){:target="_blank" rel="noopener"}
- [UiBooster](https://github.com/Milchreis/uibooster-for-processing){:target="_blank" rel="noopener"}
- [Apache Commons](https://commons.apache.org/){:target="_blank" rel="noopener"}
- [rotating-fos](https://github.com/vy/rotating-fos){:target="_blank" rel="noopener"}
- [Hazelcast IMDG](https://github.com/hazelcast/hazelcast){:target="_blank" rel="noopener"}

The icons used in the application were either released under a public-domain-like license ([CC0](https://creativecommons.org/share-your-work/public-domain/cc0/){:target="_blank" rel="noopener"}) or are free to use with attribution ([CC BY 3.0](https://creativecommons.org/licenses/by/3.0/){:target="_blank" rel="noopener"}, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/){:target="_blank" rel="noopener"}). Thanks to the following authors from the [Noun Project](https://thenounproject.com/){:target="_blank" rel="noopener"}: Andrew Nielsen; Tokka Elkholy; Sweet Farm; HeadsOfBirds; Mike Rowe; Denis; Yu luck; Patrick Morrison; and Sergey Demushkin. Thanks to Delapouite, Lorc, and sbed from [Game-icons.net](https://game-icons.net/){:target="_blank" rel="noopener"}. And thanks to Freepik and Good Ware from [Flaticon](https://www.flaticon.com/){:target="_blank" rel="noopener"}.



## Assets

There are a few demo scenes bundled with the application. The assets used in these scenes can be found at or created using the following links.

- The Sword Coast and Siege of Bamburgh animated maps are from [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page"){:target="_blank" rel="noopener"}.
- The Yawning Portal animated map was created by [3DMAcademy](https://www.reddit.com/user/3DMAcademy/ "3DMAcademy Reddit user page"){:target="_blank" rel="noopener"}.
- The <a class="lightbox-link cabin" title="Abandoned Cabin map by Mike Schley">Abandoned Cabin map</a> is from Mike Schley, available in this [D&D article](https://dnd.wizards.com/articles/features/schley-stack "D&D Schley Stack article"){:target="_blank" rel="noopener"}, © Wizards of the Coast.
- The <a class="lightbox-link illusionist" title="Dungeons of the Grand Illusionist map by Dyson Logos">Dungeons of the Grand Illusionist map</a> is from [Dyson Logos](https://www.patreon.com/dysonlogos "Dyson Logos Patreon page"){:target="_blank" rel="noopener"}.
- The <a class="lightbox-link library" title="The Lost Library map by Paths Peculiar">Lost Library map</a> is from [Paths Peculiar](https://www.wistedt.net/ "Paths Peculiar website"){:target="_blank" rel="noopener"}.
- The <a class="lightbox-link cliff" title="Cliff Edge map by Sliph">Cliff Edge map</a> is from [Sliph](https://www.patreon.com/sliph "Sliph Patreon page"){:target="_blank" rel="noopener"}.
- All tokens were created using the [Token Stamp tool](https://rolladvantage.com/tokenstamp/ "Token Stamp tool"){:target="_blank" rel="noopener"} with D&D 5th edition images, © Wizards of the Coast.



## Thanks

Thanks to my awesome RPG group that supported me in developing this application and were patient enough to playtest it in our sessions. <img class="emoji lazyload" data-src="/assets/img/emojis/heart.png" width="20" height="20" alt=":heart:" title=":heart:" />

<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/claw.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/claw.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/claw.png" alt="Claw token" title="Claw, Tabaxi Sorcerer (Wild Magic)" width="135" height="135" />
</picture>
<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/gruk.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/gruk.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/gruk.png" alt="Gruk token" title="Gruk, Dwarf Fighter (Eldritch Knight)" width="135" height="135" />
</picture>
<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/labard.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/labard.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/labard.png" alt="Labard token" title="Labard, Halfling Rogue (Assassin)" width="135" height="135" />
</picture>
<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/lander.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/lander.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/lander.png" alt="Lander token" title="Lander, Human Cleric (Forge Domain)" width="135" height="135" />
</picture>
<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/naven.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/naven.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/naven.png" alt="Naven token" title="Naven, Half-Elf Paladin (Oath of the Ancients)" width="135" height="135" />
</picture>
<picture>
	<source type="image/webp" data-srcset="/assets/img/playtesters/sora.webp">
	<source type="image/png" data-srcset="/assets/img/playtesters/sora.png">
	<img class="token-image lazyload" data-src="/assets/img/playtesters/sora.png" alt="Sora token" title="Sora, Human Monk (Way of the Long Death)" width="135" height="135" />
</picture>

And thanks to [Animated Dungeon Maps](https://www.patreon.com/animatedmaps "Animated Dungeon Maps Patreon page"){:target="_blank" rel="noopener"} for letting me use some of his maps on the demo scenes and even lending me an [exclusive map](https://github.com/luiscastilho/dungeoneering/blob/main/dungeoneering/data/maps/Animated-SwordCoast.mp4){:target="_blank" rel="noopener"}. Much appreciated! <img class="emoji lazyload" data-src="/assets/img/emojis/plus-one.png" width="20" height="20" alt=":+1:" title=":+1:" />

<a href="https://www.patreon.com/animatedmaps" title="Animated Dungeon Maps Patreon page" target="_blank" rel="noopener"><picture>
    <source type="image/webp" data-srcset="/assets/img/logos/animated-dungeon-maps.webp">
    <source type="image/png" data-srcset="/assets/img/logos/animated-dungeon-maps.png">
    <img class="fit-width lazyload" data-src="/assets/img/logos/animated-dungeon-maps.png" alt="Animated Dungeon Maps logo" width="600" height="82" />
  </picture>
</a>
