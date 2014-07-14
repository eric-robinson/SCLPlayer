//
//  SCLViewController.m
//  SCLPlayer
//
//  Created by Eric Robinson on 07/12/2014.
//  Copyright (c) 2014 Eric Robinson. All rights reserved.
//

#import "SCLViewController.h"
#import <SCLPlayer/SCLPlayerViewController.h>

@interface SCLViewController ()

@property (readwrite, strong, nonatomic) SCLPlayerViewController* playerVC;

@end

@implementation SCLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.playerVC = [[SCLPlayerViewController alloc] initWithURL:[NSURL URLWithString:@"https://soundcloud.com/eeeee-5/sets/tracks"] configuration:nil];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.playerVC.view.frame = CGRectMake(0, 48.f, CGRectGetWidth(screenBounds), 128.f);
    
    [self.view addSubview:self.playerVC.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    [self.playerVC play];
}

- (IBAction)pause:(id)sender
{
    [self.playerVC pause];
}

- (IBAction)next:(id)sender
{
    [self.playerVC next];
}

- (IBAction)prev:(id)sender
{
    [self.playerVC prev];
}

- (IBAction)toggle:(id)sender
{
    [self.playerVC toggle];
}

@end
