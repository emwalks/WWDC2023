//
//  BBCMediaSelectorJWTAuthentication.h
//  BBCMediaSelectorClient
//
//  Created by Rory Clear on 07/03/2023.
//  Copyright © 2023 BBC. All rights reserved.
//

@import Foundation;
#import "BBCMediaSelectorAuthentication.h"
#import "MediaSelectorDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBCMediaSelectorJWTAuthentication : NSObject <BBCMediaSelectorAuthentication>
MEDIA_SELECTOR_INIT_UNAVAILABLE

-(instancetype)initWithToken:(NSString *)token NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
