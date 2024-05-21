//
//  BBCMediaSelectorJWTAuthentication.m
//  BBCMediaSelectorClient
//
//  Created by Rory Clear on 07/03/2023.
//  Copyright © 2023 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBCMediaSelectorJWTAuthentication.h"

@interface BBCMediaSelectorJWTAuthentication ()

@property (nonatomic, nonnull) NSString *token;

@end

@implementation BBCMediaSelectorJWTAuthentication

-(instancetype)initWithToken:(NSString *)token
{
    if ((self = [super init])) {
        self.token = token;
    }
    return self;
}

- (NSDictionary *)toHeader {
    return @{
        BBCMediaSelectorAuthenticationHeaderKey: @"Authorization",
        BBCMediaSelectorAuthenticationHeaderValue: [NSString stringWithFormat:@"Bearer %@", _token],
    };
}

@end
