//
//  NSArray+Shuffling.h
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 20/10/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
// When https://jira.dev.bbc.co.uk/browse/MOBILE-7513 is completed and we are targeting iOS > 10
// we can remove this in favour of the standard library function.  https://developer.apple.com/documentation/foundation/nsarray/1640855-shuffledarray?language=objc
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end
