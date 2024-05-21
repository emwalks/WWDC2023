//
//  BBCMediaItem.h
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

@import Foundation;
#import "BBCMediaConnection.h"
#import "BBCMediaConnectionSorting.h"
#import "BBCMediaConnectionFilter.h"
#import "BBCMediaSelectorSecureConnectionPreference.h"
#import "MediaSelectorDefines.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MediaItem)
@interface BBCMediaItem : NSObject
MEDIA_SELECTOR_INIT_UNAVAILABLE

@property (nonatomic, readonly, nullable) NSString* kind;
@property (nonatomic, readonly, nullable) NSString* type;
@property (nonatomic, readonly, nullable) NSString* encoding;
@property (nonatomic, readonly, nullable) NSNumber* bitrate;
@property (nonatomic, readonly, nullable) NSNumber* width;
@property (nonatomic, readonly, nullable) NSNumber* height;
@property (nonatomic, readonly, nullable) NSString* service;

#pragma mark Deprecated BBCMediaConnection property
#pragma mark TODO: Delete deprecated property https://jira.dev.bbc.co.uk/browse/MOBILE-7518
@property (nonatomic, readonly) NSArray<BBCMediaConnection*>* connections MEDIA_SELECTOR_DEPRECATED_WITH_REPLACEMENT("To be removed in due course - MOBILE-7518. Access connections using selectNextConnectionWithError:", "selectNextConnectionWithError:<#NSError **#>");

@property (nonatomic, readonly, nullable) NSDate* expires;
@property (nonatomic, readonly, nullable) NSNumber* mediaFileSize;

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                 connectionSorting:(nullable id<BBCMediaConnectionSorting>)connectionSorting
                   numberFormatter:(NSNumberFormatter*)numberFormatter
                     dateFormatter:(NSDateFormatter*)dateFormatter
NS_DESIGNATED_INITIALIZER;

- (void)setConnectionFilter:(BBCMediaConnectionFilter*)connectionFilter;
- (void)setSecureConnectionPreference:(BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference;

/// Attempts to select the next eligible connection for consumption.
///
/// @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error
///              object containing the error information. You may specify nil for this parameter if you do not want the
///              error information.
///
/// @returns The next eligible connection that may be used for consumption. If no connections are eligible, this method
///          returns nil and assigns an appropriate error object to the error parameter.
- (nullable BBCMediaConnection *)selectNextConnectionWithError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
