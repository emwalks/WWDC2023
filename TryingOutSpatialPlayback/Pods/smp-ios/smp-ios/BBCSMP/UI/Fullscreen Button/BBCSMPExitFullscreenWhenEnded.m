//
//  BBCSMPExitFullscreenWhenEnded.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 23/12/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPExitFullscreenWhenEnded.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPNavigationCoordinator.h"
#import "BBCSMPState.h"

@interface BBCSMPExitFullscreenWhenEnded () <
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver
#pragma GCC diagnostic pop
>
@end

#pragma mark -

@implementation BBCSMPExitFullscreenWhenEnded {
    __weak BBCSMPNavigationCoordinator *_navigationCoordinator;
    BBCSMPPresentationMode _presentationMode;
}

#pragma mark Initialization

- (instancetype)initWithContext:(BBCSMPPresentationContext *)context
{
    self = [super init];
    if(self) {
        _navigationCoordinator = context.navigationCoordinator;
        _presentationMode = context.presentationMode;
        
        [context.player addObserver:self];
    }
    
    return self;
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState *)state
{
    if(state.state == BBCSMPStateEnded &&
       _presentationMode == BBCSMPPresentationModeFullscreenFromEmbedded) {
        [_navigationCoordinator leaveFullscreen];
    }
}

@end
