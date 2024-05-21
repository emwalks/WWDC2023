//
//  BBCMediaSelectorClient.m
//  BBCMediaSelectorClient
//
//  Created by Michael Emmens on 04/02/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

@import HTTPClient;
#import "BBCMediaSelectorClient.h"
#import "BBCMediaSelectorDefaultConfiguration.h"
#import "BBCMediaSelectorParser.h"
#import "BBCMediaSelectorRandomizer.h"
#import "BBCMediaSelectorRequestHeadersBuilder.h"
#import "BBCMediaSelectorURLBuilder.h"
#import "BBCMediaSelectorVersion.h"
#import "BBCOperationQueueWorker.h"
#import "BBCWorker.h"
#import "BBCMediaSelectorResponse+Internal.h"
#import "BBCConnectionSelectionAndLoadBalancingSorting.h"

NSErrorDomain const BBCMediaSelectorClientErrorDomain = @"BBCMediaSelectorClientError";
NSErrorDomain const BBCMediaSelectorErrorDomain = @"BBCMediaSelectorError";

BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorBadResponseDescription = @"Media-selector returned a bad response";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorSelectionUnavailableDescription = @"Selection is unavailable";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorGeoLocationDescription = @"Selection is GeoIP restricted";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorUnauthorizedDescription = @"Unauthorized access";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorTokenExpiredDescription = @"Token is expired";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorTokenInvalidDescription = @"Token is invalid";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorAuthorizationNotResolvedDescription = @"Authorization not resolved";
BBCMediaSelectorErrorDescription const BBCMediaSelectorErrorSelectionUnavailableWithTokenDescription = @"Selection is unavailable with token";

@interface BBCMediaSelectorClient ()

@property (strong, nonatomic) id<BBCMediaSelectorParsing> parsing;
@property (strong, nonatomic) id<BBCMediaSelectorConfiguring> configuring;
@property (strong, nonatomic) id<BBCMediaSelectorRandomization> randomiser;
@property (strong, nonatomic) id<BBCHTTPClient> httpClient;
@property (strong, nonatomic) id<BBCWorker> responseWorker;
@property (strong, nonatomic) id<BBCHTTPUserAgent> userAgent;

@end

@implementation BBCMediaSelectorClient

static BBCMediaSelectorClient* sharedClient = nil;

// MARK: Public methods

+ (BBCMediaSelectorClient*)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[BBCMediaSelectorClient alloc] init];
    });
    return sharedClient;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.parsing = [[BBCMediaSelectorParser alloc] initWithConnectionSorting:[[BBCConnectionSelectionAndLoadBalancingSorting alloc] init]];
        self.configuring = [[BBCMediaSelectorDefaultConfiguration alloc] init];
        self.httpClient = [[BBCHTTPNetworkClient alloc] init];
        self.userAgent = [BBCHTTPLibraryUserAgent userAgentWithLibraryName:@"MediaSelectorClient" libraryVersion:@BBC_MEDIASELECTOR_VERSION];
        self.responseWorker = [BBCOperationQueueWorker new];
    }
    return self;
}

- (instancetype)withRandomiser:(id<BBCMediaSelectorRandomization>)randomiser
{
    self.randomiser = randomiser;
    return self;
}

- (instancetype)withConfiguring:(id<BBCMediaSelectorConfiguring>)configuring
{
    self.configuring = configuring;
    if ([_configuring respondsToSelector:@selector(userAgent)] && [_configuring userAgent]) {
        self.userAgent = [_configuring userAgent];
    }
    return self;
}

- (instancetype)withHTTPClient:(id<BBCHTTPClient>)httpClient
{
    self.httpClient = httpClient;
    return self;
}

- (instancetype)withResponseWorker:(id<BBCWorker>)worker
{
    self.responseWorker = worker;
    return self;
}

- (instancetype)withConnectionSorter:(id<BBCMediaConnectionSorting>)connectionSorter
{
    self.parsing = [[BBCMediaSelectorParser alloc] initWithConnectionSorting:connectionSorter];
    return self;
}

- (void)sendMediaSelectorRequest:(BBCMediaSelectorRequest*)request success:(BBCMediaSelectorClientResponseBlock)success failure:(BBCMediaSelectorClientFailureBlock)failure
{
    NSError* requestValidationError = nil;
    if (![request isValid:&requestValidationError]) {
        failure(requestValidationError);
        return;
    }
    
    BBCMediaSelectorRequest* requestWithMediaSet = request;
    if (!request.hasMediaSet && [_configuring respondsToSelector:@selector(mediaSet)]) {
        requestWithMediaSet = [[[BBCMediaSelectorRequest alloc] initWithRequest:request] withMediaSet:[_configuring mediaSet]];
    }
    
    __weak BBCMediaSelectorClient *weakSelf = self;
    
    [self prepareAuthenticationForRequest:requestWithMediaSet success:^(BBCMediaSelectorRequest * requestToSend) {
        typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf sendPreparedRequest:requestToSend withSecureConnectionPreference:requestToSend.secureConnectionPreference success:success failure:failure];
        }
    } failure:^(NSError * _Nonnull error) {
        NSError *authorizationNotResolvedError = [
            [NSError alloc] initWithDomain:BBCMediaSelectorErrorDomain
            code:BBCMediaSelectorErrorAuthorizationNotResolved
            userInfo:@{
            NSUnderlyingErrorKey: error,
            NSLocalizedDescriptionKey: BBCMediaSelectorErrorAuthorizationNotResolvedDescription
          }
        ];
        failure(authorizationNotResolvedError);
    }];
}

// MARK: private methods

- (instancetype)withParsing:(id<BBCMediaSelectorParsing>)parsing
{
    self.parsing = parsing;
    return self;
}

- (void)prepareAuthenticationForRequest:(BBCMediaSelectorRequest*)request success:(void(^)(BBCMediaSelectorRequest *))success failure:(BBCMediaSelectorClientFailureBlock)failure {
    if (request.authenticationProvider) {
        [request.authenticationProvider provideAuthentication:^(id<BBCMediaSelectorAuthentication> _Nonnull auth) {
            BBCMediaSelectorRequest *requestWithAuth = [request withAuthentication:auth];
            success(requestWithAuth);
        } failure:^(NSError * _Nonnull error) {
            failure(error);
        }];
    } else {
        success(request);
    }
}

- (void)sendPreparedRequest:(BBCMediaSelectorRequest *)mediaSelectorRequest withSecureConnectionPreference:(BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference success:(BBCMediaSelectorClientResponseBlock)success failure:(BBCMediaSelectorClientFailureBlock)failure
{
    id<BBCWorker> responseWorker = _responseWorker;
    
    BBCMediaSelectorURLBuilder* urlBuilder = [[BBCMediaSelectorURLBuilder alloc] initWithConfiguring: _configuring];
    NSString* url = [urlBuilder urlForRequest:mediaSelectorRequest];
    
    BBCMediaSelectorRequestHeadersBuilder* requestHeadersBuilder = [[BBCMediaSelectorRequestHeadersBuilder alloc] initWithConfiguring:_configuring];
    NSDictionary* headers = [requestHeadersBuilder headersForRequest:mediaSelectorRequest];
    
    BBCHTTPNetworkRequest* httpRequest = [[[[[BBCHTTPNetworkRequest alloc] initWithString:url] withHeaders:headers] withUserAgent:_userAgent] withResponseProcessors:@[ [[BBCHTTPJSONResponseProcessor alloc] init] ]];
    __weak BBCMediaSelectorClient *weakSelf = self;
    [_httpClient sendRequest:httpRequest
                     success:^(id<BBCHTTPRequest> httpRequest, id<BBCHTTPResponse> response) {
        NSError* error = nil;
        BBCMediaSelectorResponse* mediaSelectorResponse = [weakSelf.parsing responseFromJSONObject:response.body request:mediaSelectorRequest error:&error];
        
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [mediaSelectorResponse setConfiguring:[strongSelf configuring]];
        }
        
        [mediaSelectorResponse setSecureConnectionPreference:secureConnectionPreference];
        [responseWorker performWork:^{
            if (mediaSelectorResponse) {
                success(mediaSelectorResponse);
            }
            else {
                failure(error);
            }
        }];
    }
                     failure:^(id<BBCHTTPRequest> request, id<BBCHTTPError> error) {
        NSError* responseError = error.error;
        if (error.body) {
            [weakSelf.parsing responseFromJSONObject:error.body request:mediaSelectorRequest error:&responseError];
        }
        
        [responseWorker performWork:^{
            failure(responseError);
        }];
    }];
}

- (NSTimeInterval) connectionRecoveryTime
{
    return [[self configuring] connectionRecoveryTime];
}

@end
