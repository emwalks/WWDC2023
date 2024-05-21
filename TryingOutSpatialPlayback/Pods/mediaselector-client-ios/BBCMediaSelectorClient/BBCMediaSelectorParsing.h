//
//  BBCMediaSelectorParsing.h
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 13/02/2015.
//  Copyright (c) 2015 Michael Emmens. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class BBCMediaSelectorResponse;
@class BBCMediaSelectorRequest;

NS_SWIFT_NAME(MediaSelectorParsing)
@protocol BBCMediaSelectorParsing <NSObject>

- (nullable BBCMediaSelectorResponse *)responseFromJSONObject:(nullable id)jsonObject request:(BBCMediaSelectorRequest *)request error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
