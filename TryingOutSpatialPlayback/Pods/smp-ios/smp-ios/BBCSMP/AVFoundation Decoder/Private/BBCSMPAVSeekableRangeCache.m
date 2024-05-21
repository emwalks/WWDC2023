//
//  BBCSMPAVSeekableRangeCache.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 27/07/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "AVPlayerProtocol.h"
#import "BBCSMPAVSeekableRangeCache.h"
#import "BBCSMPTimeRange.h"
#import "BBCSMPEventBus.h"
#import <SMP/SMP-Swift.h>

// used to reason about converting relative times to absolute times
typedef CMTime RelativeCMTime;
typedef NSTimeInterval AbsoluteTimeSeconds;

@implementation BBCSMPAVSeekableRangeCache {
    __weak AVPlayerItem * _Nullable _playerItem;
}

#pragma mark Initialization

- (instancetype)initWithEventBus:(BBCSMPEventBus *)eventBus
{
    self = [super init];
    if (self) {
        _seekableTimeRange = [BBCSMPTimeRange rangeWithStart:0 end:0];
        [eventBus addTarget:self selector:@selector(playerItemDidChange:) forEventType:[BBCSMPAVPlayerItemChangedEvent class]];
    }

    return self;
}

#pragma mark Target Action

- (void)playerItemDidChange:(BBCSMPAVPlayerItemChangedEvent *)event
{
    _playerItem = event.playerItem;
    [self update];
}

#pragma mark Public

- (void)update
{
    NSArray<NSValue*>* seekableTimeRanges = _playerItem.seekableTimeRanges;
    
    if (seekableTimeRanges.count > 0) {
        CMTimeRange seekableTimeRange = [[seekableTimeRanges lastObject] CMTimeRangeValue];
        BOOL isVod = !CMTIME_IS_INDEFINITE(_playerItem.duration);
        if (isVod) {
            _seekableTimeRange = [self convertRelativeCMTimeRangeToRelativeBBCSMPTimeRange:seekableTimeRange];
        } else if ([BBCSMPAVSeekableRangeCache rangeValueIsntRidiculous:_seekableTimeRange newTimeRange:seekableTimeRange] && _playerItem.currentDate != nil) {
            _seekableTimeRange = [self convertRelativeCMTimeRangeToAbsoluteBBCSMPTimeRange:seekableTimeRange];
        }

    }
}

+ (BOOL) rangeValueIsntRidiculous:(BBCSMPTimeRange *)previousTimeRange newTimeRange:(CMTimeRange) timeRange
{
    return (![self validRangePreviouslySet:previousTimeRange] || CMTimeGetSeconds(timeRange.duration) > 0);
}

+ (BOOL)validRangePreviouslySet:(BBCSMPTimeRange *)previousTimeRange
{
    return previousTimeRange.start > 0;
}


- (BBCSMPTimeRange *) convertRelativeCMTimeRangeToRelativeBBCSMPTimeRange:(CMTimeRange)relativeCMTimeRange {
    BBCSMPTimeRange* result  = [[BBCSMPTimeRange alloc] init];
    
    result.start = CMTimeGetSeconds(relativeCMTimeRange.start);
    result.end = CMTimeGetSeconds(CMTimeRangeGetEnd(relativeCMTimeRange));
    
    return result;
}

- (BBCSMPTimeRange *) convertRelativeCMTimeRangeToAbsoluteBBCSMPTimeRange:(CMTimeRange)relativeCMTimeRange {
    RelativeCMTime itemStartToPlayhead = _playerItem.currentTime;

    AbsoluteTimeSeconds playhead = _playerItem.currentDate.timeIntervalSince1970;
    AbsoluteTimeSeconds itemStart = playhead - CMTimeGetSeconds(itemStartToPlayhead);

    RelativeCMTime itemStartToRangeStart = relativeCMTimeRange.start;
    RelativeCMTime itemStartToRangeEnd = CMTimeRangeGetEnd(relativeCMTimeRange);

    AbsoluteTimeSeconds rangeStart = itemStart + CMTimeGetSeconds(itemStartToRangeStart);
    AbsoluteTimeSeconds rangeEnd = itemStart + CMTimeGetSeconds(itemStartToRangeEnd);


    BBCSMPTimeRange* result  = [[BBCSMPTimeRange alloc] init];
    result.start = rangeStart;
    result.end = rangeEnd;
    result.rangeStartOffset = CMTimeGetSeconds(itemStartToRangeStart);
    
    return result;
}

@end
