//
//  BBCSMPMediaSelectionLogMessage.m
//  SMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 29/01/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

#import "BBCSMPMediaSelectionLogMessage.h"
#import <MediaSelector/BBCMediaItem.h>
#import <MediaSelector/BBCMediaConnection.h>

@implementation BBCSMPMediaSelectionLogMessage {
    BBCMediaItem *_mediaItem;
}

#pragma mark Initialization

- (instancetype)initWithMediaItem:(BBCMediaItem *)mediaItem
{
    self = [super init];
    if (self) {
        _mediaItem = mediaItem;
    }
    
    return self;
}

#pragma mark BBCLogMessage

- (NSString *)createLogMessage
{
    NSString *connectionsMessage = [_mediaItem description];
    return [NSString stringWithFormat:@"Mediated Connections = %@", connectionsMessage];
}

@end
