//
//  BBCSMPUUIDSessionInformationProvider.m
//  BBCSMP
//
//  Created by Ryan Johnstone on 21/06/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPUUIDSessionInformationProvider.h"

@interface BBCSMPUUIDSessionInformationProvider()

@property (nonatomic, strong) NSString* uuid;
@property (nonatomic) NSInteger eventID;

@end

@implementation BBCSMPUUIDSessionInformationProvider

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self resetEventID];
        _uuid = [BBCSMPUUIDSessionInformationProvider generateNewUUID];
    }
    return self;
}

-(NSString *)getSessionIdentifier
{
    return _uuid;
}

- (void)newSessionStarted {
    [self resetEventID];
    _uuid = [BBCSMPUUIDSessionInformationProvider generateNewUUID];
}

- (void)newEventWithinSessionStarted {
    _eventID++;
}

- (NSInteger)getEventID {
    return _eventID;
}

- (void)resetEventID {
    _eventID = 0;
}

+ (NSString *)generateNewUUID {
    return [[NSUUID UUID] UUIDString];
}

@end
