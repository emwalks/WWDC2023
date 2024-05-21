//
//  BBCSMPError.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 29/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BBCSMPErrorEnumeration) {
    BBCSMPErrorUnknown = 1,
    BBCSMPErrorFailedToPlayToEnd,
    BBCSMPErrorInitialLoadFailed,
    BBCSMPErrorAvailableCDNsExceeded,
    BBCSMPErrorMediaResolutionFailed,
    BBCSMPErrorGeolocation,
    BBCSMPErrorMediaResolutionFailedWithToken
};

extern NSString* const BBCSMPPlayerErrorDomain;
extern NSString *NSStringFromBBCSMPErrorEnumeration(BBCSMPErrorEnumeration);

@interface BBCSMPError : NSObject
BBC_SMP_INIT_UNAVAILABLE

@property (nonatomic, strong, readonly) NSError* error;
@property (nonatomic, readonly) BOOL recoverable;
@property (nonatomic, assign) BOOL recovered;
@property (nonatomic, readonly) BBCSMPErrorEnumeration reason BBC_SMP_DEPRECATED("Use SMPError.error.code and refer to https://confluence.dev.bbc.co.uk/display/mp/Error+Model");

- (instancetype)initWithError:(NSError *)error reason:(BBCSMPErrorEnumeration)reason recoverable:(BOOL)recoverable NS_DESIGNATED_INITIALIZER;

+ (instancetype)error:(NSError*)error NS_SWIFT_NAME(init(_:));
+ (instancetype)error:(NSError*)error andReason:(BBCSMPErrorEnumeration)reason NS_SWIFT_NAME(init(_:reason:));
+ (instancetype)recoverableError:(NSError*)error NS_SWIFT_NAME(recoverableError(_:));

@end

NS_ASSUME_NONNULL_END
