//
//  SCLPlayerViewController.h
//  SCLPlayer
//
//  This class provides a UIWebView based SoundCloud player with relatively complete api coverage.
//  Docs for the js widget can be found at: https://developers.soundcloud.com/docs/api/html5-widget
//
//  Created by Eric Robinson on 7/10/14.
//  Copyright (c) 2014 Eric Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - Typedefs
typedef void (^SCLPlayerResponseHandler)(id results);


#pragma mark = SCLPlayerViewConroller

@interface SCLPlayerViewController : UIViewController

@property (readonly, assign, nonatomic) BOOL isPaused;

@property (readonly, strong, nonatomic) UIWebView* webview;
@property (readonly, strong, nonatomic) UILabel *connectionIssueLabel;

- (id)initWithURL:(NSURL*)url configuration:(NSDictionary*)config;

#pragma mark - Player Controls

/** Start playing from the current position */
- (void)play;

/** If showing a playlist, jump to the given track id, you can call this method (and only this method) before SCLPlayerDidLoadNotification fires */
- (void)playTrackWithID:(NSString*)soundcloudTrackID;

/** Pause the player */
- (void)pause;

/** Advance the player to the next track */
- (void)next;

/** Set the player to the previous track */
- (void)prev;

/** Seek the player to the provided millisecond */
- (void)seekTo:(NSUInteger)milliseconds;

/** Set the volume of the player (0-100) */
- (void)setVolume:(NSUInteger)volume;

/** "Toggle" the player */
- (void)toggle;

/**  Jump to the soundIndex sound, starting from 0 (only if the widget contains multiple sounds) */
- (void)skip:(NSUInteger)soundIndex;

/** Get the current sounds */
- (void)getSounds:(SCLPlayerResponseHandler)responseBlock;

/** Get the current sound */
- (void)getCurrentSound:(SCLPlayerResponseHandler)responseBlock;

/** Get the current sound index */
- (void)getCurrentSoundIndex:(SCLPlayerResponseHandler)responseBlock;

/** Get the volume */
- (void)getVolume:(SCLPlayerResponseHandler)responseBlock;

/** Get the duration */
- (void)getDuration:(SCLPlayerResponseHandler)responseBlock;

/** Get the position */
- (void)getPosition:(SCLPlayerResponseHandler)responseBlock;

@end

#pragma mark - Constants

#pragma mark Notifications
extern NSString* const SCLPlayerDidLoadNotification;
extern NSString* const SCLPlayerDidPlayNotification;
extern NSString* const SCLPlayerDidPauseNotification;
extern NSString* const SCLPlayerDidFinishNotification;
extern NSString* const SCLPlayerDidSeekNotification;

extern NSString* const SCLPlayerPlayProgressNotification;
extern NSString* const SCLPlayerLoadProgressNotification;

extern NSString* const SCLPlayerContextUserInfoKey;

#pragma mark Configuration
extern NSString* const SCLPlayerPropertyHideRelated;
extern NSString* const SCLPlayerPropertyShowComments;
extern NSString* const SCLPlayerPropertyShowUser;
extern NSString* const SCLPlayerPropertyShowArtwork;
extern NSString* const SCLPlayerPropertySharing;
extern NSString* const SCLPlayerPropertyLiking;
extern NSString* const SCLPlayerPropertyDownload;
extern NSString* const SCLPlayerPropertyBuying;

