# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][1], and this project adheres to
[Semantic Versioning][2].

## [1.3.0] - 2021-09-09

### Added

- Separate apps for DM and players, to be used in two separate screens
connected to the same computer. A scene loaded in the DM's app is shared with
the players' app and after that scene changes are shared in both directions.
- Tokens are no longer automatically added to the initiative widget. Instead,
there's a right-click menu option to toggle them in the initiative.
- Added missing sight types: blindsight, darkvision, and truesight, all with a
variety of ranges
- Added a Burned condition. Useful when fighting Trolls :) or if you are hit by
Alchemist's Fire :(
- When adding new walls, doors, or tokens, allow map panning by holding the
mouse middle button
- Added a new demo scene - Dungeons of the Grand Illusionist. This one uses a
huge map from [Dyson Logos][5] to show that the app can be used as a dungeon
exploration tool.

### Fixed

- Check for application updates in a separate thread so the application won't
hang if a problem occurs
- Fixed warnings in code - deprecated code, unused variables, etc

### Changed

- Moved website to dungeoneering.app domain
- Updated dependencies
- Don't reset map pan and zoom when adding new tokens

## [1.2.1] - 2021-07-05

### Fixed

- Avoid error during setup, which would get the application stuck in a grey
screen - Thanks @Finister-Finn and @Bazzatron19 for reporting and for helping
me debug this problem

## [1.2.0] - 2021-06-23

### Added

- macOS release
- Linux release
- Added code to check for updates
- Setup a GitHub Pages site

### Fixed

- Generate icons script now works with more recent versions of ImageMagick

### Changed

- Improved save and load scene code to work on macOS and Linux
- Improved logger code to work on macOS and Linux

## [1.1.3] - 2021-06-06

### Fixed

- Pressing ESC no longer exits the application

### Changed

- Improved logging and error handling
- Logs are now sent to console and to a log file - `/log/dungeoneering.log`
- Log file is rotated every 500KB
- Only the last 5 rotated log files are kept, older ones are deleted

## [1.1.2] - 2021-06-03

### Fixed

- Run in fullscreen on second screen, if present

## [1.1.1] - 2021-05-30

### Changed

- Wall segments setup can now be stopped by double clicking so you can continue
adding segments in another spot on the map
- Door segments are now added one at a time

## [1.1.0] - 2021-05-29

### Added

- Added tooltips to UI buttons, including conditions, light sources, etc., in
the right-click menu

## [1.0.2] - 2021-05-28

### Fixed

- Token light sources are now visible in all layers; e.g., a goblin carrying a
torch can be seen by players from far away if they have line of sight

## [1.0.1] - 2021-05-26

### Fixed

- Scenes can now be correctly loaded in any screen resolution, not only in the
same resolution where they were created

## [1.0.0] - 2021-05-18

### Added

- Static (PNG, JPG, etc) and animated (MP4, M4V) maps can be loaded
- Map can be zoomed and panned
- A grid can be set up and adjusted over the map
- Players and DM tokens can be added to the scene
- Several conditions, light sources, and sight types and can be added to tokens
- Walls and doors can be set up over the map to block tokens' light and vision
(dynamic lighting)
- Visual initiative order widget to help in combats
- An [exclusive video map][3] from [Animated Dungeon Maps][4]

[unreleased]: https://github.com/luiscastilho/dungeoneering/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/luiscastilho/dungeoneering/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/luiscastilho/dungeoneering/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/luiscastilho/dungeoneering/compare/v1.1.3...v1.2.0
[1.1.3]: https://github.com/luiscastilho/dungeoneering/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/luiscastilho/dungeoneering/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/luiscastilho/dungeoneering/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/luiscastilho/dungeoneering/releases/tag/v1.0.0

[1]: https://keepachangelog.com/en/1.0.0/
[2]: https://semver.org/spec/v2.0.0.html
[3]: https://github.com/luiscastilho/dungeoneering/blob/main/dungeoneering/data/maps/Animated-SwordCoast.mp4
[4]: https://www.patreon.com/animatedmaps
[5]: https://www.patreon.com/dysonlogos
