//
//  BBCSMPVideoSurfaceController.m
//  BBCSMP
//
//  Created by Thomas Sherwood on 15/01/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPVideoSurfaceController.h"
#import "BBCSMPVideoSurfaceManager.h"
#import "BBCSMPView.h"
#import "BBCSMPVideoSurface.h"
#import "BBCSMPVideoSurfaceContext.h"
#import "BBCSMPViewControllerEventsCoordinator.h"

@interface BBCSMPVideoSurfaceController () <BBCSMPVideoSurface,
                                            BBCSMPViewControllerLifecycleEventObserver>
@end

#pragma mark -

@implementation BBCSMPVideoSurfaceController {
    __weak id<BBCSMPVideoSurfaceManager> _videoSurfaceManager;
    __weak id<BBCSMPView> _view;
    NSMutableSet<id<BBCSMPVideoSurfaceControllerObserver>> *_observers;
    CALayer *_currentLayer;
}

#pragma mark Initialization

- (instancetype)initWithVideoSurfaceManager:(id<BBCSMPVideoSurfaceManager>)videoSurfaceManager
                                       view:(id<BBCSMPView>)view
         viewControllerLifecycleCoordinator:(BBCSMPViewControllerEventsCoordinator *)viewControllerLifecycleCoordinator
{
    self = [super init];
    if(self) {
        _videoSurfaceManager = videoSurfaceManager;
        _view = view;
        _observers = [NSMutableSet set];
        
        [viewControllerLifecycleCoordinator addObserver:self];
        [videoSurfaceManager registerVideoSurface:self];
    }

    return self;
}

#pragma mark Public

- (void)addObserver:(id<BBCSMPVideoSurfaceControllerObserver>)observer
{
    [_observers addObject:observer];
    
    if(_currentLayer) {
        [observer videoSurfaceDidBecomeAvailable:_currentLayer];
    }
}

#pragma mark BBCSMPVideoSurface

- (void)attachWithContext:(BBCSMPVideoSurfaceContext*)context
{
    _currentLayer = context.playerLayer;
    for(id<BBCSMPVideoSurfaceControllerObserver> observer in _observers) {
        [observer videoSurfaceDidBecomeAvailable:_currentLayer];
    }
}

- (void)detach
{
    [_observers makeObjectsPerformSelector:@selector(videoSurfaceDidDetach)];
}

- (void)videoFrameDidChangeToFrame:(CGRect)frame
{
    [_view setVideoRect:frame];
}

#pragma mark BBCSMPViewControllerLifecycleEventObserver

- (void)viewControllerWillAppear {
    [_videoSurfaceManager registerVideoSurface:self];
}
- (void)viewControllerDidAppear { }

- (void)viewControllerWillDisappear
{
    [_videoSurfaceManager deregisterVideoSurface:self];
}

- (void)viewControllerDidDisappear { }

@end
