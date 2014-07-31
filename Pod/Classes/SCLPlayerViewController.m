//
//  SCLPlayerViewController.m
//
//  Created by Eric Robinson on 7/10/14.
//  Copyright (c) 2014 Eric Robinson. All rights reserved.
//

#import "SCLPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

//auto_play=false&amp;hide_related=true&amp;show_comments=false&amp;show_user=false&amp;show_artwork=false&amp;sharing=false&amp;liking=false&amp;download=false&amp;buying=false&amp;show_reposts=false

#pragma mark Notifications
NSString* const SCLPlayerDidLoadNotification = @"SCLPlayerDidLoadNotification";
NSString* const SCLPlayerDidPlayNotification = @"SCLPlayerDidPlayNotification";
NSString* const SCLPlayerDidPauseNotification = @"SCLPlayerDidPauseNotification";
NSString* const SCLPlayerDidFinishNotification = @"SCLPlayerDidPauseNotification";
NSString* const SCLPlayerDidSeekNotification = @"SCLPlayerDidSeekNotification";

NSString* const SCLPlayerPlayProgressNotification = @"SCLPlayerPlayProgressNotification";
NSString* const SCLPlayerLoadProgressNotification = @"SCLPlayerLoadProgressNotification";

NSString* const SCLPlayerContextUserInfoKey = @"SCLPlayerContext";

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

@property (readwrite, assign, nonatomic) BOOL isPaused;

@property (readwrite, strong, nonatomic) NSString *pendingTrackID;
@property (readwrite, assign, nonatomic) BOOL isPendingPlay;

@property (readwrite, assign, nonatomic) BOOL isLoadingPlayer;
@property (readwrite, assign, nonatomic) BOOL hasLoadedPlayer;
@property (readwrite, assign, nonatomic) BOOL loadDidFail;


@property (readwrite, strong, nonatomic) NSMutableDictionary* pendingResponseHandlers;

@end

@implementation SCLPlayerViewController

- (id)initWithURL:(NSURL*)url configuration:(NSDictionary *)config
{
    self = [super init];
    
    if (self)
    {
        self.isPaused = YES;
        
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
        
        self.pendingResponseHandlers = [NSMutableDictionary dictionary];
        
        [self.pendingResponseHandlers addEntriesFromDictionary:@{
            @"getSounds" : [NSMutableArray array],
            @"getCurrentSound" : [NSMutableArray array]
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
    
    self.webview.backgroundColor = [UIColor clearColor];
    self.webview.scrollView.scrollEnabled = NO;
    self.webview.scrollView.bounces = NO;
    self.webview.mediaPlaybackRequiresUserAction = NO;
    self.webview.suppressesIncrementalRendering = YES;
    
    [self.view addSubview:self.webview];

    self.blurToolbar = [[UIToolbar alloc] initWithFrame:self.webview.bounds];
    self.blurToolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.view insertSubview:self.blurToolbar atIndex:0];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = self.view.center;
    
    self.connectionIssueLabel = [[UILabel alloc] initWithFrame:self.webview.bounds];
    self.connectionIssueLabel.text = NSLocalizedString(@"Device Offline", nil);
    self.connectionIssueLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionIssueLabel.font = [UIFont systemFontOfSize:18.f];
    self.connectionIssueLabel.textColor = [UIColor whiteColor];
    self.connectionIssueLabel.alpha = 0;
    
    [self.view addSubview:self.connectionIssueLabel];
    
    [self loadPlayer];
}

- (void)loadPlayer
{
    if(self.isLoadingPlayer)
    {
        return;
    }
    
    self.loadDidFail = NO;
    self.isLoadingPlayer = YES;
    
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
    
    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 0;
    }];
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
        [self loadPlayer];
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
    if(!self.hasLoadedPlayer)
    {
        self.isPendingPlay = YES;
        [self loadPlayer];
    }
    else {
        [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().play()"];
    }
}

- (void)next
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().next()"];
}

- (void)prev
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().prev()"];
}

- (void)skip:(NSUInteger)soundIndex
{
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.scPlayer().skip(%@)", @(soundIndex)]];
}

- (void)seekTo:(NSUInteger)milliseconds
{
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.scPlayer().seekTo(%@)", @(milliseconds)]];
}

- (void)setVolume:(NSUInteger)volume
{
    //bind the input
    volume = MIN(MAX(volume, 0), 100);
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.scPlayer().setVolume(%@)", @(volume)]];
}

- (void)toggle
{
    [self.webview stringByEvaluatingJavaScriptFromString:@"SCLPlayer.scPlayer().toggle()"];
}

- (void)performQuery:(NSString*)query withResponseHandler:(SCLPlayerResponseHandler)responseBlock
{
    SCLPlayerResponseHandler responseCopy = [responseBlock copy];
    [(NSMutableArray*)[self.pendingResponseHandlers objectForKey:query] addObject:responseCopy];
    
    NSString* js = [NSString stringWithFormat:@"SCLPlayer.%@()", query];
    [self.webview stringByEvaluatingJavaScriptFromString:js];
}

- (void)getSounds:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getSounds" withResponseHandler:responseBlock];
}

- (void)getCurrentSound:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getCurrentSound" withResponseHandler:responseBlock];
}

- (void)getCurrentSoundIndex:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getCurrentSoundIndex" withResponseHandler:responseBlock];
}

- (void)getVolume:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getVolume" withResponseHandler:responseBlock];
}

- (void)getDuration:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getDuration" withResponseHandler:responseBlock];
}

- (void)getPosition:(SCLPlayerResponseHandler)responseBlock
{
    [self performQuery:@"getPosition" withResponseHandler:responseBlock];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // sclplayer:// is used to message the webview from soundcloudPlayer.html
    if([[request.URL scheme] isEqualToString:@"sclplayer"])
    {
        NSString* urlString = [request.URL absoluteString];
        NSString* playerMessage = [urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://", [request.URL scheme]] withString:@""];
        
        NSRange queryRange = [playerMessage rangeOfString:@"?"];
        NSString* command = (queryRange.location == NSNotFound) ? playerMessage : [playerMessage substringToIndex:queryRange.location];
        
        NSString* contextJSON = (queryRange.location == NSNotFound) ? nil : [[playerMessage substringFromIndex:queryRange.location + 1] stringByRemovingPercentEncoding];
        
        NSError* jsonParsingError = nil;
        id context = nil;
        
        if(contextJSON)
        {
            context = [NSJSONSerialization JSONObjectWithData:[contextJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonParsingError];
        }
        
        if(jsonParsingError)
        {
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            context = [numberFormatter numberFromString:contextJSON];
            
            if(context == nil)
            {
                NSLog(@"%s: Unable to parse response param: %@", __PRETTY_FUNCTION__, urlString);                
            }
        }
        
        NSDictionary* userContext = nil;
        
        if (context)
        {
             userContext = @{SCLPlayerContextUserInfoKey : context};
        }
        
        if ([command isEqualToString:@"didLoad"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidLoadNotification object:nil];
            
            if (self.pendingTrackID)
            {
                [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SCLPlayer.playTrack(%@);", self.pendingTrackID]];
                
            }
            else if (self.isPendingPlay)
            {
                [self play];
            }
            
            self.pendingTrackID = nil;
            self.isPendingPlay = NO;
        }
        else if ([command isEqualToString:@"didPlay"])
        {
            self.isPaused = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidPlayNotification object:self userInfo:userContext];
        }
        else if ([command isEqualToString:@"didPause"])
        {
            self.isPaused = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidPauseNotification object:self userInfo:userContext];
        }
        else if ([command isEqualToString:@"didFinish"])
        {
            self.isPaused = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidFinishNotification object:self userInfo:userContext];
        }
        else if ([command isEqualToString:@"didSeek"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerDidSeekNotification object:self userInfo:userContext];
        }
        else if ([command isEqualToString:@"playProgress"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerPlayProgressNotification object:self userInfo:userContext];
        }
        else if ([command isEqualToString:@"loadProgress"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SCLPlayerLoadProgressNotification object:self userInfo:userContext];
        }
        else if ([command hasPrefix:@"get"])
        {
            for(SCLPlayerResponseHandler handler in [self.pendingResponseHandlers objectForKey:command])
            {
                handler(context);
            }
            
            [self.pendingResponseHandlers setObject:[NSMutableArray array] forKey:command];
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
    self.isLoadingPlayer = NO;
    
    if (self.loadDidFail)
    {
        return;
    }
    
    [self.activityIndicator stopAnimating];

    self.hasLoadedPlayer = YES;

    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 0.f;
        self.webview.alpha = 1.f;
    }];
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.isLoadingPlayer = NO;
    self.hasLoadedPlayer = NO;
    self.loadDidFail = YES;
    
    
    [UIView animateWithDuration:0.25 animations:^{
        self.connectionIssueLabel.alpha = 1.f;
        self.webview.alpha = 0;
    }];
    
    [self.activityIndicator stopAnimating];
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
