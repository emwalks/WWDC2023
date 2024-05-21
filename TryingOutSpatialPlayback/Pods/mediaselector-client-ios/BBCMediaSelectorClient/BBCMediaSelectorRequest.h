//
//  BBCMediaSelectorRequest.h
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

@import Foundation;
#import "MediaSelectorDefines.h"
#import "BBCMediaSelectorSecureConnectionPreference.h"
#import "BBCMediaSelectorAuthenticationProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCMediaSelectorRequestParameter;

NS_SWIFT_NAME(MediaSelectorRequest)
@interface BBCMediaSelectorRequest : NSObject
MEDIA_SELECTOR_INIT_UNAVAILABLE

@property (nonatomic, readonly, getter=isSecure) BOOL secure MEDIA_SELECTOR_DEPRECATED("This property is not part of our published API and will be removed in MOBILE-7611");
@property (nonatomic, readonly) BOOL hasMediaSet;
@property (nonatomic, copy, readonly) NSArray<BBCMediaSelectorRequestParameter *> *parameters;
@property (nonatomic, readonly) BBCMediaSelectorSecureConnectionPreference secureConnectionPreference;

/**
 * Throws if with(authentication:) has not been used to prepare this request.
 * Requests with an authentication provider should first use provider.provideAuthentication and then request.with(authentication:) to prepare the request.
 */
@property (nonatomic, nullable, readonly) id<BBCMediaSelectorAuthentication> authentication;
@property (nonatomic, nullable, readonly) id<BBCMediaSelectorAuthenticationProvider> authenticationProvider;

- (instancetype)initWithVPID:(NSString *)vpid NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(vpid:));
- (instancetype)initWithRequest:(BBCMediaSelectorRequest *)request;

- (instancetype)withMediaSet:(NSString *)mediaSet NS_SWIFT_NAME(with(mediaSet:));
- (instancetype)withProtocol:(NSString *)protocol NS_SWIFT_NAME(with(protocol:));
- (instancetype)withTransferFormats:(NSArray<NSString *> *)transferFormats NS_SWIFT_NAME(with(transferFormats:));
- (instancetype)withSAMLToken:(NSString *)samlToken NS_SWIFT_NAME(with(samlToken:)) MEDIA_SELECTOR_DEPRECATED_WITH_REPLACEMENT("Will be removed in MOBILE-7611.","withAuthentication:[[BBCMediaSelectorSAMLAuthentication alloc] initWithSecureClientId:<#(NSString *)#> token: <#(NSString *)#>]");
- (instancetype)withCeiling:(NSString *)ceiling NS_SWIFT_NAME(with(ceiling:));
- (instancetype)withSecureConnectionPreference:(BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference NS_SWIFT_NAME(with(secureConnectionPreference:));

/**
 * This will set the auth provider to nil, and the authentication getter will return the argument.
 */
- (instancetype)withAuthentication:(id<BBCMediaSelectorAuthentication>)authentication;

/**
 * This will set the authentication to nil, and the authentication getter will throw an exception.
 */
- (instancetype)withAuthenticationProvider:(id<BBCMediaSelectorAuthenticationProvider>)authenticationProvider;

- (BOOL)isValid:(NSError * __autoreleasing *)error NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
