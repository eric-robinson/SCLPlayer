# SCLPlayer

[![CI Status](http://img.shields.io/travis/Eric Robinson/SCLPlayer.svg?style=flat)](https://travis-ci.org/Eric Robinson/SCLPlayer)
[![Version](https://img.shields.io/cocoapods/v/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![License](https://img.shields.io/cocoapods/l/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![Platform](https://img.shields.io/cocoapods/p/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)

## Usage

To create a player...

`[[SCLPlayerViewController alloc] initWithURL:<<Soundcloud URL>> configuration:nil]`

You can subscribe to events to update your UI based on user interaction with the player. The available notifications are...
```
SCLPlayerDidLoadNotification
SCLPlayerDidPlayNotification
SCLPlayerDidPauseNotification
SCLPlayerDidFinishNotification
````

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SCLPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SCLPlayer"

## Author

Eric Robinson, eric DOT robinson AT me.com

## License

SCLPlayer is available under the MIT license. See the LICENSE file for more info.

