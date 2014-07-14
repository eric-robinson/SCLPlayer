# SCLPlayer

[![Version](https://img.shields.io/cocoapods/v/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![License](https://img.shields.io/cocoapods/l/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![Platform](https://img.shields.io/cocoapods/p/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)

SCLPlayer is a UIWebView based wrapper for the Soundcloud HTML5 widget. It allows you to easily embed a Soundcloud player and message it from your Cocoa code.

## Usage

To create a player...

`[[SCLPlayerViewController alloc] initWithURL:<<Soundcloud URL>> configuration:nil]`

To control the player...

```
- (void)play;
- (void)playTrackWithID:(NSString*)soundcloudTrackID;
- (void)pause;
- (void)next;
- (void)prev;
- (void)seekTo:(NSUInteger)milliseconds;
- (void)setVolume:(NSUInteger)volume;
- (void)toggle;
```

You can subscribe to events to update your UI based on user interaction with the player. The available notifications are...
```
SCLPlayerDidLoadNotification
SCLPlayerDidPlayNotification
SCLPlayerDidPauseNotification
SCLPlayerDidFinishNotification
````

You can also message the HTML5 player directly through SCLPlayer's UIWebView. The widget object is accessible through `SCLPlayer.scPlayer()`...

`[sclPlayerInstance.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().play()"];`

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

SCLPlayer is built for iOS 7 and above.

## Installation

SCLPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SCLPlayer"

## Author

Eric Robinson, eric DOT robinson AT me.com

## License

SCLPlayer is available under the MIT license. See the LICENSE file for more info.

