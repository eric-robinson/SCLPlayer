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
- (void)play;
- (void)playTrackWithID:(NSString*)soundcloudTrackID;
- (void)pause;

- (void)next;
- (void)prev;

- (void)seekTo:(NSUInteger)milliseconds;
- (void)setVolume:(NSUInteger)volume;
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
