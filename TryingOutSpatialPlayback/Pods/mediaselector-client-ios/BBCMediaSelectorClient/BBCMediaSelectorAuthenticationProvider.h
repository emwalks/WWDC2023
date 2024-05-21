//
//  BBCMediaSelectorAuthenticationProvider.h
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 01/03/2023.
//  Copyright © 2023 BBC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BBCMediaSelectorAuthentication.h"

NS_ASSUME_NONNULL_BEGIN


@protocol BBCMediaSelectorAuthenticationProvider <NSObject>

- (void) provideAuthentication:(void (^)(id<BBCMediaSelectorAuthentication>))onSuccess failure:(void (^)(NSError *))onFailure;

@end

NS_ASSUME_NONNULL_END
