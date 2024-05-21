//
//  BBCMediaSelectorParser.m
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 12/02/2015.
//  Copyright (c) 2015 Michael Emmens. All rights reserved.
//

#import "BBCMediaSelectorParser.h"
#import "BBCMediaSelectorErrors.h"
#import "BBCMediaSelectorResponse.h"
#import "BBCMediaSelectorResponse+Internal.h"
#import "BBCMediaSelectorRequest.h"

@interface BBCMediaSelectorParser ()

@property (strong,nonatomic) id<BBCMediaConnectionSorting> connectionSorting;

@end

@implementation BBCMediaSelectorParser


+ (NSNumberFormatter *)createNumberFormatter
{
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    return numberFormatter;
}

+ (NSDateFormatter *)createDateFormatter
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ'";
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    
    return dateFormatter;
}

- (instancetype)initWithConnectionSorting:(id<BBCMediaConnectionSorting>)connectionSorting
{
    if ((self = [super init])) {
        self.connectionSorting = connectionSorting;
    }
    return self;
}

- (NSError *)errorForResult:(NSString *)result errorForRequest:(BBCMediaSelectorRequest *)request
{
    NSDictionary *descriptionsDict = [self errorDescriptionsDictionary];
    NSInteger indexForErrorCode = 0;
    NSInteger indexForErrorDescription = 1;

    if ([descriptionsDict objectForKey:result] == nil) {
        return [NSError errorWithDomain:BBCMediaSelectorErrorDomain
                                   code:BBCMediaSelectorErrorBadResponse
                               userInfo:@{NSLocalizedDescriptionKey:BBCMediaSelectorErrorBadResponseDescription}];
    }
    
    NSError *error = [NSError errorWithDomain:BBCMediaSelectorErrorDomain
                                         code:[[descriptionsDict objectForKey:result][indexForErrorCode] intValue]
                                     userInfo:@{NSLocalizedDescriptionKey:[descriptionsDict objectForKey:result][indexForErrorDescription]}];
    
    if (error.code == BBCMediaSelectorErrorSelectionUnavailable && [request.authentication isKindOfClass:BBCMediaSelectorJWTAuthentication.class])  {
        error = [NSError errorWithDomain:BBCMediaSelectorErrorDomain
                                    code:BBCMediaSelectorErrorSelectionUnavailableWithToken
                                userInfo:@{NSLocalizedDescriptionKey:BBCMediaSelectorErrorSelectionUnavailableWithTokenDescription}];
    }
    return error;
}

- (NSDictionary *)errorDescriptionsDictionary
{
    NSMutableDictionary *descriptionsDict = [[NSMutableDictionary alloc] init];
    [descriptionsDict setObject: @[[NSNumber numberWithInteger:BBCMediaSelectorErrorSelectionUnavailable], BBCMediaSelectorErrorSelectionUnavailableDescription] forKey: @"selectionunavailable"];
    [descriptionsDict setObject: @[[NSNumber numberWithInteger:BBCMediaSelectorErrorGeoLocation], BBCMediaSelectorErrorGeoLocationDescription] forKey: @"geolocation"];
    [descriptionsDict setObject: @[[NSNumber numberWithInteger:BBCMediaSelectorErrorUnauthorized], BBCMediaSelectorErrorUnauthorizedDescription] forKey: @"unauthorized"];
    [descriptionsDict setObject: @[[NSNumber numberWithInteger:BBCMediaSelectorErrorTokenExpired], BBCMediaSelectorErrorTokenExpiredDescription] forKey: @"tokenexpired"];
    [descriptionsDict setObject: @[[NSNumber numberWithInteger:BBCMediaSelectorErrorTokenInvalid], BBCMediaSelectorErrorTokenInvalidDescription]  forKey: @"tokeninvalid"];
    return descriptionsDict;
}

- (BBCMediaSelectorResponse *)responseFromJSONObject:(id)jsonObject request:(nonnull BBCMediaSelectorRequest *)request error:(NSError **)error
{
    BBCMediaSelectorResponse *response = nil;
    NSError *parsingError = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        if ([[jsonObject allKeys] containsObject:@"media"]) {
            NSArray *mediaArray = [jsonObject valueForKey:@"media"];
            response = [[BBCMediaSelectorResponse alloc] initWithMediaArray:mediaArray connectionSorting:_connectionSorting numberFormatter:[[self class] createNumberFormatter] dateFormatter:[[self class] createDateFormatter]];
        } else if ([[jsonObject allKeys] containsObject:@"result"]) {
            NSString *result = [jsonObject valueForKey:@"result"];
            parsingError = [self errorForResult:result errorForRequest:request];
        }
    }
    if (!response && error) {
        if (parsingError) {
            *error = parsingError;
        } else {
            *error = [NSError errorWithDomain:BBCMediaSelectorErrorDomain code:BBCMediaSelectorErrorBadResponse userInfo:@{NSLocalizedDescriptionKey:BBCMediaSelectorErrorBadResponseDescription}];
        }
    }
    return response;
}

@end
