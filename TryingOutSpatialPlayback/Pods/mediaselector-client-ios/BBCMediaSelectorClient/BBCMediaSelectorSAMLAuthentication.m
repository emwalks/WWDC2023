//
//  BBCMediaSelectorSAMLAuthentication.m
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 15/02/2023.
//  Copyright © 2023 BBC. All rights reserved.
//

#import "BBCMediaSelectorSAMLAuthentication.h"

@interface BBCMediaSelectorSAMLAuthentication ()

@property (nonatomic, nonnull) NSString *clientId;
@property (nonatomic, nonnull) NSString *token;

@end

@implementation BBCMediaSelectorSAMLAuthentication

-(instancetype)initWithSecureClientId:(NSString *)secureClientId token:(NSString *)token
{
    if ((self = [super init])) {
        self.clientId = secureClientId;
        self.token = token;
    }
    return self;
}

- (NSDictionary *)toHeader {
    return @{
        BBCMediaSelectorAuthenticationHeaderKey: @"Authorization",
        BBCMediaSelectorAuthenticationHeaderValue: [NSString stringWithFormat:@"%@ x=%@", _clientId, _token],
    };
}

@end
