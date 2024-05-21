//
//  BBCSMPTimeObserver.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 15/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import <SMP/BBCSMPObserver.h>
#import <SMP/BBCSMPDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPDuration;
@class BBCSMPTime;
@class BBCSMPTimeRange;


@protocol BBCSMPTimeObserver <BBCSMPObserver>

- (void)durationChanged:(BBCSMPDuration*)duration
BBC_SMP_DEPRECATED("This method is now deprecated. Please use the BBCSMPProgressObserver");


- (void)seekableRangeChanged:(BBCSMPTimeRange*)range
BBC_SMP_DEPRECATED("This method is now deprecated. Please use the BBCSMPProgressObserver");


- (void)timeChanged:(BBCSMPTime*)time
BBC_SMP_DEPRECATED("This method is now deprecated. Please use the BBCSMPProgressObserver");


- (void)scrubbedFromTime:(BBCSMPTime*)fromTime toTime:(BBCSMPTime*)toTime;
- (void)playerRateChanged:(float)newPlayerRate;

@end

NS_ASSUME_NONNULL_END
