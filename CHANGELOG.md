# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [2.1.1](https://github.com/kukushi/SideMenu/compare/v2.0.8...v2.1.1) (2024-02-26)


### Features

* add privacy ([9c7efc1](https://github.com/kukushi/SideMenu/commit/9c7efc1306c006f51fe270185a051caa6a5596e4))
* disable library evolution ([59f0d95](https://github.com/kukushi/SideMenu/commit/59f0d95b1bfc785a14e07d1cd246a370ae93cbe1))
* support keeps open when rotation ([db5812b](https://github.com/kukushi/SideMenu/commit/db5812b10b923da2c0bb695fa9ea97c1fa2edee1))
* update doc ([f0d1d96](https://github.com/kukushi/SideMenu/commit/f0d1d966505e2fc0ca213441aa3967d64ba634d9))
* usding DocC as the documentation format ([fc8fc18](https://github.com/kukushi/SideMenu/commit/fc8fc18bc767e5425170b686a200640833192ad4))


### Bug Fixes

* lint warnings ([4e80913](https://github.com/kukushi/SideMenu/commit/4e80913e2c82946625c5273f2b5ddad576a0bb63))
* swiftlint in run phase ([07b7b5b](https://github.com/kukushi/SideMenu/commit/07b7b5b2d9f1a9a9da76f576f4a4db6dabca2753))

## [2.0.19]

- Bump deployment target to iOS 12.0

## [2.0.9](https://github.com/kukushi/SideMenu/compare/v2.0.8...v2.0.9) (2022-04-24)

### Features

* update doc ([f0d1d96](https://github.com/kukushi/SideMenu/commit/f0d1d966505e2fc0ca213441aa3967d64ba634d9))
* usding DocC as the documentation format ([fc8fc18](https://github.com/kukushi/SideMenu/commit/fc8fc18bc767e5425170b686a200640833192ad4))

## [2.0.7]

- [Add `panGestureSensitivity`](https://github.com/kukushi/SideMenu/issues/71))

## [2.0.6]

- fix: menu view controller life cycle

## [2.0.5]

- Add `shouldAutorotate`

## [2.0.4]

- Update docs

## [2.0.3]

- Fix gesture backing [issue](https://github.com/kukushi/SideMenu/issues/67)

## [2.0.2]

- Disable status bar animation on iOS 13

## [2.0.1]

- Fix orientation size [issue](https://github.com/kukushi/SideMenu/issues/64)

## [2.0.0]

- Update to Swift 5.0

## [1.0.2]

- Remove shadow effect for `.under` position.

## [1.0.1]

- Add `shadowColor`

## [1.0.0]

- Update to Swift 4.2
- Rename some APIs to make it more swift.

## [0.5.0]

- Adds supports for transition animation
- Adds `...willShowViewController` , `...didShowViewController` delegate methods

## [0.4.1]

- Introduces the new `shouldRespectLanguageDirection` option in preference which reverses the direction of the side menu when using RTL language.
- Disable pan gesture when there is another gesture recognizer.