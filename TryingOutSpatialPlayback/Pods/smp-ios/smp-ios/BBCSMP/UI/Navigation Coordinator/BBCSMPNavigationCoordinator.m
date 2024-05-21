//
//  BBCSMPNavigationCoordinator.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 18/01/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPNavigationCoordinator.h"
#import "BBCSMPPlayerViewFullscreenPresenter.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPViewControllerProviding.h"
#import "BBCSMPVideoSurfaceManager.h"

@implementation BBCSMPNavigationCoordinator {
    __weak id<BBCSMP> _player;
    id<BBCSMPPlayerViewFullscreenPresenter> _fullscreenPresenter;
    BBCSMPViewControllerProviding *_viewControllerProviding;
    NSHashTable *_observers;
    id<BBCSMPVideoSurfaceManager> _videoSurfaceManager;
}

#pragma mark Initialization

- (instancetype)initWithPlayer:(id<BBCSMP>)player videoSurfaceManager:(id<BBCSMPVideoSurfaceManager>)videoSurfaceManager
{
    return self = [self initWithPlayer:player
                   fullscreenPresenter:nil
               viewControllerProviding:nil
                   videoSurfaceManager:videoSurfaceManager];
}

- (instancetype)initWithPlayer:(id<BBCSMP>)player
           fullscreenPresenter:(id<BBCSMPPlayerViewFullscreenPresenter>)fullscreenPresenter
       viewControllerProviding:(BBCSMPViewControllerProviding *)fullscreenViewControllerProviding
           videoSurfaceManager:(id<BBCSMPVideoSurfaceManager>)videoSurfaceManager
{
    self = [super init];
    if(self) {
        _player = player;
        _fullscreenPresenter = fullscreenPresenter;
        _viewControllerProviding = fullscreenViewControllerProviding;
        _observers = [NSHashTable weakObjectsHashTable];
        _videoSurfaceManager = videoSurfaceManager;
    }
    
    return self;
}

#pragma mark Public

- (void)addObserver:(id<BBCSMPNavigationCoordinatorObserver>)observer
{
    [_observers addObject:observer];
}

- (void)leaveFullscreen
{
    if(_fullscreenPresenter) {
        if(_presentedViewController) {
            [_fullscreenPresenter leaveFullscreenByDismissingViewController:_presentedViewController completion:^{}];
            _presentedViewController = nil;
        }
    }
    else {
        [_videoSurfaceManager setContentFit];
    }
    
    for(id observer in _observers) {
        [observer didLeaveFullscreen];
    }
}

- (void)enterFullscreen
{
    if(_fullscreenPresenter) {
        UIViewController *viewController = [_viewControllerProviding createViewController];
        _presentedViewController = viewController;
        
        [_fullscreenPresenter enterFullscreenByPresentingViewController:_presentedViewController completion:^{}];
    }
    else {
        [_videoSurfaceManager setContentFill];
    }
    
    for(id observer in _observers) {
        [observer didEnterFullscreen];
    }
}

- (void)teardown
{
    _viewControllerProviding = nil;
}

@end
