//
//  BBCMediaSelectorRandomizer.m
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 23/01/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCMediaSelectorRandomizer.h"

#pragma mark TODO: Delete as part of https://jira.dev.bbc.co.uk/browse/MOBILE-7518

@implementation BBCMediaSelectorRandomizer

- (NSUInteger)generateRandomPercentage
{
    return (arc4random() % 100) + 1;
}

@end
