//
//  BBCMediaItem.m
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCMediaItem.h"
#import "BBCMediaConnectionFilteringFactory.h"
#import "BBCMediaSelectorErrors.h"
#import "BBCConnectionsEnumerator.h"
#import "BBCMediaConnection+Internal.h"

@interface BBCMediaItem ()

@property (strong,nonatomic) NSString *kind;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *encoding;
@property (strong,nonatomic) NSNumber *bitrate;
@property (strong,nonatomic) NSNumber *width;
@property (strong,nonatomic) NSNumber *height;
@property (strong,nonatomic) NSString *service;
@property (strong,nonatomic) NSDate *expires;
@property (strong,nonatomic) NSNumber *mediaFileSize;

@property (weak,nonatomic) NSNumberFormatter *numberFormatter;
@property (weak,nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) BBCConnectionsEnumerator* connectionsEnumerator;

@end

@implementation BBCMediaItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                 connectionSorting:(id<BBCMediaConnectionSorting>)connectionSorting
                   numberFormatter:(NSNumberFormatter *)numberFormatter
                     dateFormatter:(NSDateFormatter *)dateFormatter
{
    if ((self = [super init])) {
        self.numberFormatter = numberFormatter;
        self.dateFormatter = dateFormatter;
        
        self.connectionsEnumerator = [[BBCConnectionsEnumerator alloc] init];
        [_connectionsEnumerator setConnectionSorting:connectionSorting];
        [_connectionsEnumerator setSecureConnectionPreference:BBCMediaSelectorSecureConnectionUseServerResponse];
        
        [self setValuesForKeysWithDictionary:dictionary];
        self.numberFormatter = nil;
        self.dateFormatter = nil;
    }

    return self;
}

- (void)setConnectionRecoveryTime:(NSTimeInterval)connectionRecoveryTime
{
    [_connectionsEnumerator setConnectionRecoveryTime:connectionRecoveryTime];
}

- (NSArray<BBCMediaConnection*>*)connections
{
    return [_connectionsEnumerator connections];
}

- (void)setConnectionFilter:(BBCMediaConnectionFilter*)connectionFilter
{
    [_connectionsEnumerator setConnectionFilter:connectionFilter];
}

- (void)setSecureConnectionPreference:(BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference
{
    [_connectionsEnumerator setSecureConnectionPreference:secureConnectionPreference];
}

- (BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference
{
    return _connectionsEnumerator.secureConnectionPreference;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"connection"] && [value isKindOfClass:[NSArray class]]) {
        NSArray *connectionDictionaries = value;
        NSMutableArray *mutableConnections = [NSMutableArray arrayWithCapacity:connectionDictionaries.count];
        for (NSDictionary *connectionDictionary in connectionDictionaries) {
            BBCMediaConnection *connection = [[BBCMediaConnection alloc] initWithDictionary:connectionDictionary numberFormatter:_numberFormatter dateFormatter:_dateFormatter];
            [mutableConnections addObject:connection];
        }
        
        [_connectionsEnumerator setUnsortedConnections:mutableConnections];
    } else if ([key isEqualToString:@"width"] && [value isKindOfClass:[NSString class]]) {
        self.width = [_numberFormatter numberFromString:value];
    } else if ([key isEqualToString:@"height"] && [value isKindOfClass:[NSString class]]) {
        self.height = [_numberFormatter numberFromString:value];
    } else if ([key isEqualToString:@"bitrate"] && [value isKindOfClass:[NSString class]]) {
        self.bitrate = [_numberFormatter numberFromString:value];
    } else if ([key isEqualToString:@"media_file_size"] && [value isKindOfClass:[NSString class]]) {
        self.mediaFileSize = [_numberFormatter numberFromString:value];
    } else if ([key isEqualToString:@"expires"] && [value isKindOfClass:[NSString class]]) {
        self.expires = [_dateFormatter dateFromString:value];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"BBCMediaSelection: Undefined key - %@ : %@",key,value);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\n  Kind:%@; Type:%@; Bitrate:%@kbps; Width:%@; Height:%@; Connections:\n%@",[super description],_kind,_type,_bitrate,_width,_height,[[_connectionsEnumerator connections] description]];
}

- (nullable BBCMediaConnection *)selectNextConnectionWithError:(NSError **)error
{
    return [_connectionsEnumerator selectNextConnectionWithError:error];
}

- (void)setClock:(id<BBCClock>)clock
{
    [_connectionsEnumerator setClock:clock];
}

@end
