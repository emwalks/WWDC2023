//
//  BBCMediaSelectorClient.h
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

@import Foundation;
#import "MediaSelectorDefines.h"
#import "BBCMediaSelectorConfiguring.h"
#import "BBCMediaSelectorErrors.h"
#import "BBCMediaSelectorRequest.h"
#import "BBCMediaSelectorResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BBCWorker;
@protocol BBCHTTPClient;
@protocol BBCMediaSelectorRandomization;

NS_SWIFT_NAME(MediaSelectorClientResponseBlock)
typedef void (^BBCMediaSelectorClientResponseBlock)(BBCMediaSelectorResponse* response);

NS_SWIFT_NAME(MediaSelectorClientURLBlock)
typedef void (^BBCMediaSelectorClientURLBlock)(NSURL* url);

NS_SWIFT_NAME(MediaSelectorClientFailureBlock)
typedef void (^BBCMediaSelectorClientFailureBlock)(NSError* error);

#pragma mark -

NS_SWIFT_NAME(MediaSelectorClient)
@interface BBCMediaSelectorClient : NSObject

#pragma mark Client Builders

@property (class, nonatomic, strong, readonly) BBCMediaSelectorClient *sharedClient NS_REFINED_FOR_SWIFT;

- (instancetype)withConfiguring:(id<BBCMediaSelectorConfiguring>)configuring NS_SWIFT_NAME(with(configuration:));
- (instancetype)withHTTPClient:(id<BBCHTTPClient>)httpClient NS_SWIFT_NAME(with(httpClient:));
- (instancetype)withResponseWorker:(id<BBCWorker>)worker NS_SWIFT_NAME(with(responseWorker:));
- (instancetype)withConnectionSorter:(id<BBCMediaConnectionSorting>)connectionSorter NS_SWIFT_NAME(with(connectionSorter:));


#pragma mark Request Handling

/**
 Make a request to media selector.
 
 - Throws: `NSInternalInconsistencyException` if secureBaseURL is missing on the BBCMediaSelectorConfiguring configuration.
 */
- (void)sendMediaSelectorRequest:(BBCMediaSelectorRequest*)request
                         success:(BBCMediaSelectorClientResponseBlock)success
                         failure:(BBCMediaSelectorClientFailureBlock)failure;

#pragma mark Deprecated Client Builder
#pragma mark TODO: Delete deprecated withRandomiser function https://jira.dev.bbc.co.uk/browse/MOBILE-7518

- (instancetype)withRandomiser:(id<BBCMediaSelectorRandomization>)randomiser NS_SWIFT_NAME(with(randomiser:)) MEDIA_SELECTOR_DEPRECATED_WITH_REPLACEMENT("This randomiser was only required for the deprecated sorting algorithm and is no longer functional. To be removed in due course - MOBILE-7518. Add a sorting algorithm using withConnectionSorter:", "withConnectionSorter:id<BBCMediaConnectionSorting>");

@end

NS_ASSUME_NONNULL_END
