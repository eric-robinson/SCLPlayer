# SCLPlayer

[![Version](https://img.shields.io/cocoapods/v/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![License](https://img.shields.io/cocoapods/l/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)
[![Platform](https://img.shields.io/cocoapods/p/SCLPlayer.svg?style=flat)](http://cocoadocs.org/docsets/SCLPlayer)

SCLPlayer is a UIWebView based wrapper for the SoundCloud HTML5 widget. It allows you to easily embed a SoundCloud player and message it from your Cocoa code.

## Usage

To create a player...

`[[SCLPlayerViewController alloc] initWithURL:<<SoundCloud URL>> configuration:nil]`

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

To query the player...

```
- (void)getSounds:(SCLPlayerResponseHandler)responseBlock;
- (void)getCurrentSound:(SCLPlayerResponseHandler)responseBlock;
- (void)getCurrentSoundIndex:(SCLPlayerResponseHandler)responseBlock;
- (void)getVolume:(SCLPlayerResponseHandler)responseBlock;
- (void)getDuration:(SCLPlayerResponseHandler)responseBlock;
- (void)getPosition:(SCLPlayerResponseHandler)responseBlock;
```

You can subscribe to events to update your UI based on user interaction with the player. The available notifications are...
```
SCLPlayerDidLoadNotification
SCLPlayerDidPlayNotification
SCLPlayerDidPauseNotification
SCLPlayerDidFinishNotification
SCLPlayerDidSeekNotification
SCLPlayerPlayProgressNotification
SCLPlayerLoadProgressNotification
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

## Backstory / Screenshot

SCLPlayer was developed for the [lWlVl Festival app](http://lwlvl.com/ios). (It's the bit at the bottom)

![](https://dl.dropboxusercontent.com/u/10239781/lwlvl_screenshot.png)
