//
//  BBCSMPLegacyUIComposer.m
//  SMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 09/05/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

#import "BBCSMPLegacyUIComposer.h"
#import "BBCSMPPlayerViewBuilder.h"
#import "BBCSMPPlayerViewPresenterFactory.h"
#import "BBCSMPDefaultPlayerViewFactory.h"
#import <SMP/SMP-Swift.h>

@implementation BBCSMPLegacyUIComposer

- (id<BBCSMPUIBuilder>)createBuilderWithPlayer:(id<BBCSMP, BBCSMPStateObservable>)player
{
    BBCSMPPlayerViewPresenterFactory *presenterFactory = [[BBCSMPPlayerViewPresenterFactory alloc] init];
    BBCSMPDefaultPlayerViewFactory *viewFactory = [[BBCSMPDefaultPlayerViewFactory alloc] init];
    BBCSMPAttachableVideoSurfaceManager *newVideoSurfaceManager = [[BBCSMPAttachableVideoSurfaceManager alloc] init];
    [viewFactory setVideoTrackSubscriber:newVideoSurfaceManager];
    
    return [[[BBCSMPPlayerViewBuilder alloc] initWithPlayer:player
                                        videoSurfaceManager:newVideoSurfaceManager
                                           presenterFactory:presenterFactory]
            withViewFactory:viewFactory];
}

@end
