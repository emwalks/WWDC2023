//
//  BBCSMPMediaSelectorItem.m
//  BBCSMP
//
//  Created by Michael Emmens on 31/07/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPMediaSelectorItem.h"
#import "BBCSMPURLResolvedContent.h"
#import "BBCSMPItemMetadata.h"

@implementation BBCSMPMediaSelectorItem

- (instancetype)init
{
    if ((self = [super init])) {
        self.metadata = [[BBCSMPItemMetadata alloc] init];
    }
    return self;
}

- (id<BBCSMPResolvedContent>)resolvedContent
{
    return [[BBCSMPURLResolvedContent alloc] initWithContentURL:_mediaURL representsNetworkResource:YES];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ : %@", [super description],
                     [@{
                                          @"metadata" : _metadata ? [_metadata description] : @"nil",
                                          @"mediaURL" : _mediaURL ? [_mediaURL description] : @"nil",
                                          @"subtitleURL" : _subtitleURL ? [_subtitleURL description] : @"nil"
                                      } description]];
}

 -(BOOL)isPlayable
{
    if (_mediaURL != nil) {
        return YES;
    } else {
        return NO;
    }
}

@end
