#import "BBCSMPCommonAVReporting.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BBCHTTPClient;
@protocol BBCSMPSessionInformationProvider;

@interface BBCSMPRDotCommonAVReporting : NSObject <BBCSMPCommonAVReporting>

@property (nonatomic, readonly) id<BBCHTTPClient> httpClient;

- (instancetype)initWithHTTPClient:(id<BBCHTTPClient>)httpClient
         sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider NS_DESIGNATED_INITIALIZER;

- (void)overrideBaseUrl:(NSString*)baseUrl;

@end

NS_ASSUME_NONNULL_END
