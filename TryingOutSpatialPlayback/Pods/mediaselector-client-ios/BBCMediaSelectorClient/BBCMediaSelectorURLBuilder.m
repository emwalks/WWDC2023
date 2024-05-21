//
//  BBCMediaSelectorURLBuilder.m
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCMediaSelectorURLBuilder.h"

#import "BBCMediaSelectorRequestParameter.h"
#import "BBCMediaSelectorSAMLAuthentication.h"

@interface BBCMediaSelectorURLBuilder ()

@property (weak,nonatomic) id<BBCMediaSelectorConfiguring> configuring;

@end

@implementation BBCMediaSelectorURLBuilder

- (instancetype)initWithConfiguring:(id<BBCMediaSelectorConfiguring>)configuring
{
    if ((self = [super init])) {
        self.configuring = configuring;
    }
    return self;
}

- (void)addParameter:(BBCMediaSelectorRequestParameter *)parameter toURLString:(NSMutableString *)urlString
{
    [urlString appendFormat:@"%@/%@/",parameter.name,parameter.value];
}

- (NSString *)urlForRequest:(BBCMediaSelectorRequest *)request
{
    id<BBCMediaSelectorAuthentication> authentication = request.authentication;
    
    // TODO: remove deprecation warning suppression and isSecure logic (MOBILE-7611)
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated"
    bool hasSamlAuth = request.isSecure || (authentication && [authentication isKindOfClass:[BBCMediaSelectorSAMLAuthentication class]]);
    #pragma clang diagnostic pop
    
    NSString *baseURL = nil;
    if (hasSamlAuth) {
        NSAssert([_configuring respondsToSelector:@selector(secureMediaSelectorBaseURL)], @"Configuring must provide secureMediaSelectorBaseURL if sending a request with a SAML token.");
        NSAssert([_configuring secureMediaSelectorBaseURL], @"Configuring must provide secureMediaSelectorBaseURL if sending a request with a SAML token.");
        baseURL = [_configuring secureMediaSelectorBaseURL];
        
    } else {
        NSAssert([_configuring mediaSelectorBaseURL], @"Configuring must provide mediaSelectorBaseURL.");
        baseURL = [_configuring mediaSelectorBaseURL];
    }
    if (![baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL stringByAppendingString:@"/"];
    }
    NSMutableString *urlString = [NSMutableString stringWithString:baseURL];
    if ([_configuring respondsToSelector:@selector(defaultParameters)]) {
        for (BBCMediaSelectorRequestParameter *parameter in [_configuring defaultParameters]) {
            [self addParameter:parameter toURLString:urlString];
        }
    }
    for (BBCMediaSelectorRequestParameter *parameter in request.parameters) {
        [self addParameter:parameter toURLString:urlString];
    }
    return urlString;
}

@end
