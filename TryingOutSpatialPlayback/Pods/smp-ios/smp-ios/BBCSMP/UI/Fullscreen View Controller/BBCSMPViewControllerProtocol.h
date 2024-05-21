//
//  BBCSMPViewControllerProtocol.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 18/01/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPStatusBar.h"
#import "BBCSMPHomeIndicatorScene.h"
#import <SMP/SMP-Swift.h>

@protocol BBCSMPViewControllerDelegate;
@protocol BBCSMPVideoTrackSubscriber;

@protocol BBCSMPViewControllerProtocol <BBCSMPStatusBar, BBCSMPHomeIndicatorScene, BBCSMPVideoTrackSubscriber>
@required

@property (nonatomic, weak, nullable) id<BBCSMPViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL supportAllOrientations;

@end
