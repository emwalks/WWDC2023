//
//  BBCMediaSelectorSAMLAuthentication.h
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 15/02/2023.
//  Copyright © 2023 BBC. All rights reserved.
//

@import Foundation;
#import "BBCMediaSelectorAuthentication.h"
#import "MediaSelectorDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBCMediaSelectorSAMLAuthentication : NSObject <BBCMediaSelectorAuthentication>
MEDIA_SELECTOR_INIT_UNAVAILABLE

-(instancetype)initWithSecureClientId:(NSString *)secureClientId token:(NSString *)token NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
