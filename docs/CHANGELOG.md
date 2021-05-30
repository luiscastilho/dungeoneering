# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][1], and this project adheres to
[Semantic Versioning][2].

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
- A grid can be setup and adjusted over the map
- Players and DM tokens can be added to the scene
- Several conditions, light sources and sight types and can be added to tokens
- Walls and doors can be setup over the map to block tokens' light and vision
(dynamic lighting)
- Visual initiative order widget to help in combats
- An [exclusive video map][3] from [Animated Dungeon Maps][4]

[unreleased]: https://github.com/luiscastilho/dungeoneering/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/luiscastilho/dungeoneering/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/luiscastilho/dungeoneering/releases/tag/v1.0.0

[1]: https://keepachangelog.com/en/1.0.0/
[2]: https://semver.org/spec/v2.0.0.html
[3]: https://github.com/luiscastilho/dungeoneering/blob/main/dungeoneering/data/maps/Animated-SwordCoast.mp4
[4]: https://www.patreon.com/animatedmaps
