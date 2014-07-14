//
//  SCLPlayerViewController.h
//  lwlvl
//
//  Created by Eric Robinson on 7/10/14.
//  Copyright (c) 2014 lwlvl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCLPlayerViewController : UIViewController

@property (readonly, strong, nonatomic) UIWebView* webview;
@property (readonly, strong, nonatomic) UILabel *connectionIssueLabel;

- (id)initWithURL:(NSURL*)url configuration:(NSDictionary*)config;

#pragma mark - Player Controls

/** Start playing from the current position */
- (void)play;

/** If showing a playlist, jump to the given track id */
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

@end

#pragma mark - Constants

#pragma mark Notifications
extern NSString* const SCLPlayerDidLoadNotification;
extern NSString* const SCLPlayerDidPlayNotification;
extern NSString* const SCLPlayerDidPauseNotification;
extern NSString* const SCLPlayerDidFinishNotification;

#pragma mark Configuration
extern NSString* const SCLPlayerPropertyHideRelated;
extern NSString* const SCLPlayerPropertyShowComments;
extern NSString* const SCLPlayerPropertyShowUser;
extern NSString* const SCLPlayerPropertyShowArtwork;
extern NSString* const SCLPlayerPropertySharing;
extern NSString* const SCLPlayerPropertyLiking;
extern NSString* const SCLPlayerPropertyDownload;
extern NSString* const SCLPlayerPropertyBuying;
