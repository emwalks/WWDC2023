//
//  BBCMediaSelectorAuthentication.h
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 15/02/2023.
//  Copyright © 2023 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString* const BBCMediaSelectorAuthenticationHeaderKey = @"key";
static NSString* const BBCMediaSelectorAuthenticationHeaderValue = @"value";

@protocol BBCMediaSelectorAuthentication <NSObject>

- (NSDictionary *) toHeader;

@end

NS_ASSUME_NONNULL_END
