//
//  SCLPlayerViewController.m
//  SCLvl
//
//  Created by Eric Robinson on 7/10/14.
//  Copyright (c) 2014 SCLvl. All rights reserved.
//

#import "SCLPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

//auto_play=false&amp;hide_related=true&amp;show_comments=false&amp;show_user=false&amp;show_artwork=false&amp;sharing=false&amp;liking=false&amp;download=false&amp;buying=false&amp;show_reposts=false

#pragma mark Notifications
NSString* const SCLPlayerDidLoadNotification = @"SCLPlayerDidLoadNotification";
NSString* const SCLPlayerDidPlayNotification = @"SCLPlayerDidPlayNotification";
NSString* const SCLPlayerDidPauseNotification = @"SCLPlayerDidPauseNotification";
NSString* const SCLPlayerDidFinishNotification = @"SCLPlayerDidPauseNotification";

#pragma mark Configuration
NSString* const SCLPlayerPropertyHideRelated = @"hide_related";
NSString* const SCLPlayerPropertyShowComments = @"show_comments";
NSString* const SCLPlayerPropertyShowUser  = @"show_user";
NSString* const SCLPlayerPropertyShowArtwork = @"show_artwork";
NSString* const SCLPlayerPropertySharing = @"sharing";
NSString* const SCLPlayerPropertyLiking = @"liking";
NSString* const SCLPlayerPropertyDownload = @"download";
NSString* const SCLPlayerPropertyBuying = @"buying";

@interface SCLPlayerViewController () <UIWebViewDelegate>

#pragma mark - Configuration

@property (readwrite, strong, nonatomic) NSURL* initialURL;
@property (readwrite, strong, nonatomic) NSMutableDictionary* playerConfiguration;

#pragma mark - View

@property (readwrite, strong, nonatomic) UIWebView* webview;

@property (readwrite, strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (readwrite, strong, nonatomic) UILabel *connectionIssueLabel;
@property (readwrite, strong, nonatomic) UIToolbar *blurToolbar;


#pragma mark State Tracking

@property (readwrite, strong, nonatomic) NSString *pendingTrackID;
@property (readwrite, assign, nonatomic) BOOL hasLoadedPlayer;

@end

@implementation SCLPlayerViewController

- (id)initWithURL:(NSURL*)url configuration:(NSDictionary *)config
{
    self = [super init];
    
    if (self)
    {
        self.initialURL = url;
        self.playerConfiguration = [NSMutableDictionary dictionary];
        for (NSString* property in [self allPlayerProperties])
        {
            [self.playerConfiguration setObject:@"false" forKey:property];
        }
        
        [config enumerateKeysAndObjectsUsingBlock:^(NSString* propertyName, id propertyValue, BOOL *stop) {
            if([propertyValue isKindOfClass:[NSNumber class]])
            {
                [self.playerConfiguration setObject:([propertyValue boolValue] ? @"true":@"false") forKey:propertyName];
            }
            else
            {
                [self.playerConfiguration setObject:propertyValue forKey:propertyName];
            }
        }];
    }
    
    return self;
}

- (void)loadView
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
                             error:&setCategoryError];
    if (!ok) {
        NSLog(@"%s Error setting audio category: %@", __PRETTY_FUNCTION__, setCategoryError);
    }
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(screenBounds), 96.f)];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview.delegate = self;
    self.webview.opaque = NO;
    
    self.blurToolbar = [[UIToolbar alloc] initWithFrame:self.webview.bounds];
    self.blurToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    self.webview.backgroundColor = [UIColor clearColor];
    [self.webview insertSubview:self.blurToolbar atIndex:0];
    self.webview.scrollView.scrollEnabled = NO;
    self.webview.scrollView.bounces = NO;
    self.webview.mediaPlaybackRequiresUserAction = NO;
    self.webview.suppressesIncrementalRendering = YES;
    
    [self.view addSubview:self.webview];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = self.view.center;
    
    self.connectionIssueLabel = [[UILabel alloc] initWithFrame:self.webview.bounds];
    self.connectionIssueLabel.text = NSLocalizedString(@"Device Offline", nil);
    self.connectionIssueLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionIssueLabel.font = [UIFont systemFontOfSize:18.f];
    self.connectionIssueLabel.textColor = [UIColor whiteColor];
    self.connectionIssueLabel.alpha = 0;
    
    [self.webview addSubview:self.connectionIssueLabel];
    
    
    NSURL* scURL = [[NSBundle mainBundle] URLForResource:@"soundcloudPlayer" withExtension:@"html"];
    
    NSAssert(scURL, @"Unable to find soundcloudPlayer.html in source bundle");
    
    NSString* urlParam = [[self.initialURL absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString* configurationParams = [NSMutableString new];
    
    __block NSUInteger configIndex = 0;
    NSUInteger propertyCount = [[self.playerConfiguration allKeys] count];
    
    [self.playerConfiguration enumerateKeysAndObjectsUsingBlock:^(NSString* propertyName, id value, BOOL *stop) {
        [configurationParams appendFormat:@"%@=%@", propertyName, value];
        
        configIndex++;
        
        if (configIndex < propertyCount)
        {
            [configurationParams appendString:@"&"];
        }
    }];

    
    
    NSString* htmlString = [NSString stringWithContentsOfURL:scURL encoding:NSUTF8StringEncoding error:nil];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{{URL}}"
                                                       withString:urlParam];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"{{CONFIGURATION}}"
                                                       withString:[configurationParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    [self.webview loadHTMLString:htmlString baseURL:nil];
    
    [self.activityIndicator startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGPoint center = [self.view convertPoint:self.view.center fromView:self.view.superview];
    
    self.activityIndicator.center = center;
    self.blurToolbar.frame = self.view.bounds;
    self.webview.frame = self.view.bounds;
}

- (void)playTrackWithID:(NSString*)soundcloudTrackID
{
    if (self.hasLoadedPlayer)
    {
        [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.playTrack(%@);", soundcloudTrackID]];
    }
    else
    {
        self.pendingTrackID = soundcloudTrackID;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 0.f;
    }];
}

- (void)pause
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().pause()"];
}

- (void)play
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().play()"];
}

- (void)next
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().next()"];
}

- (void)prev
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().prev()"];
}

- (void)seekTo:(NSUInteger)milliseconds
{
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.scPlayer().seekTo(%@)", @(milliseconds)]];
}

- (void)setVolume:(NSUInteger)volume
{
    volume = MIN(MAX(volume, 0), 100);
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.scPlayer().setVolume(%@)", @(volume)]];
}

- (void)toggle
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().toggle()"];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([[request.URL scheme] isEqualToString:@"sclplayer"])
    {
        NSString* urlString = [request.URL absoluteString];
        NSString* playerMessage = [urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://", [request.URL scheme]] withString:@""];
        
        if([playerMessage isEqualToString:@"didLoad"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidLoadNotification object:nil];
        }
        else if([playerMessage isEqualToString:@"didPlay"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidPlayNotification object:nil];
        }
        else if([playerMessage isEqualToString:@"didPause"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidPauseNotification object:nil];
        }
        else if([playerMessage isEqualToString:@"didFinish"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidFinishNotification object:nil];
        }
        
        return NO;
    }
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        return NO;
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.hasLoadedPlayer = YES;
    
    if (self.pendingTrackID)
    {
        [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.playTrack(%@);", self.pendingTrackID]];
        self.pendingTrackID = nil;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 0.f;
        self.webview.alpha = 1.f;
    }];
    
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 1.f;
        self.webview.alpha = 0;
    }];
}

#pragma mark - Configuration

- (NSArray*)allPlayerProperties
{
    return @[SCLPlayerPropertyHideRelated,
             SCLPlayerPropertyShowComments,
             SCLPlayerPropertyShowUser,
             SCLPlayerPropertyShowArtwork,
             SCLPlayerPropertySharing,
             SCLPlayerPropertyLiking,
             SCLPlayerPropertyDownload,
             SCLPlayerPropertyBuying];
}

@end
