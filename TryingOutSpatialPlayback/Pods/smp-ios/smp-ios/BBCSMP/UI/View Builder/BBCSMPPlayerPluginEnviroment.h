//
//  BBCSMPPlayerPluginEnviroment.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 26/08/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPPluginEnvironment.h"
#import "BBCSMPDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPNavigationCoordinator;
@protocol BBCSMP;
@protocol BBCSMPView;
@protocol BBCSMPChromeSupression;
@protocol BBCSMPUICommand;
@protocol BBCSMPVideoSurfaceManager;

@interface BBCSMPPlayerPluginEnviroment : NSObject <BBCSMPPluginEnvironment>
BBC_SMP_INIT_UNAVAILABLE

- (instancetype)initWithPlayer:(id<BBCSMP>)player
                          view:(id<BBCSMPView>)view
             chromeSuppression:(id<BBCSMPChromeSupression>)chromeSuppression
         navigationCoordinator:(BBCSMPNavigationCoordinator *)navigationCoordinator
          playerViewController:(UIViewController*)playerViewController
           videoSurfaceManager:(id<BBCSMPVideoSurfaceManager>)videoSurfaceManager
                NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
