//
//  BBCSMPPlayerObservable.h
//  BBCSMP
//
//  Created by Timothy James Condon on 17/03/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BBCSMPObserver;
@protocol BBCSMPAVStatisticsConsumer;
@protocol BBCSMPPlaybackStateObserver;
@protocol BBCSMPPictureInPictureObserver;
@protocol BBCSMPProgressObserver;
@protocol BBCSMPPlayerObservable <NSObject>

- (void)addObserver:(id<BBCSMPObserver>)observer NS_SWIFT_NAME(add(observer:));
- (void)removeObserver:(id<BBCSMPObserver>)observer NS_SWIFT_NAME(remove(observer:));


- (void)addStateObserver:(id<BBCSMPPlaybackStateObserver>)observer NS_SWIFT_NAME(add(stateObserver:));
- (void)removeStateObserver:(id<BBCSMPPlaybackStateObserver>)observer NS_SWIFT_NAME(remove(stateObserver:));

- (void)addPictureInPictureObserver:(id<BBCSMPPictureInPictureObserver>)observer NS_SWIFT_NAME(add(pictureInPictureObserver:));
- (void)removePictureInPictureObserver:(id<BBCSMPPictureInPictureObserver>)observer NS_SWIFT_NAME(remove(pictureInPictureObserver:));

-(void)addProgressObserver:(id<BBCSMPProgressObserver>)listener NS_SWIFT_NAME(add(progressObserver:));
-(void)removeProgressObserver:(id<BBCSMPProgressObserver>)listener NS_SWIFT_NAME(remove(progressObserver:));

@end

NS_ASSUME_NONNULL_END
