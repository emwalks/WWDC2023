//
//  MediaSelectorItemProviderBuilder.swift
//  SMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 13/03/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import MediaSelector.BBCMediaSelectorClient
import Foundation

@objc(BBCSMPMediaSelectorItemProviderBuilder)
@objcMembers
public class MediaSelectorItemProviderBuilder: NSObject {

    // MARK: Properties

    private let VPID: String
    private let mediaSet: String
    private let AVType: BBCSMPAVType
    private let avStatisticsConsumer: BBCSMPAVStatisticsConsumer

    private var mediaSelectorClient: MediaSelectorClient = .shared
    private var artworkFetcher: BBCSMPArtworkFetcher?
    private var samlToken: String?
    private var ceiling: String?
    private var secureConnectionPreference: BBCSMPConnectionPreference?
    private var streamType: BBCSMPStreamType
    private var suppliers: [String]?
    private var artworkURLProvider: BBCSMPArtworkURLProvider?
    private var contentID: String?
    private var playOffset: TimeInterval?
    private var title: String?
    private var subtitle: String?
    private var guidanceMessage: String?
    private var duration: BBCSMPDuration?
    private var customAVStatsLabels: [String: String]?
    private var connectionResolver: BBCSMPMediaSelectorConnectionResolver?
    private var playbackConfigAdapter: PlaybackConfigAdapter!
    private var authenticationProvider: BBCMediaSelectorAuthenticationProvider?
    private var videoTrackSubscriber: VideoTrackSubscriber?
    private var decoderFactory: MediaSelectorDecoderFactory = MediaSelectorLegacyDecoderFactoryAdapter()

    // MARK: Initialization

    public class func builderWithVPID(_ vpid: String, mediaSet: String, AVType: BBCSMPAVType, streamType: BBCSMPStreamType,
                                      avStatisticsConsumer: BBCSMPAVStatisticsConsumer) -> MediaSelectorItemProviderBuilder {
        return MediaSelectorItemProviderBuilder(VPID: vpid, mediaSet: mediaSet, AVType: AVType, streamType: streamType, avStatisticsConsumer: avStatisticsConsumer)
    }

    public init(VPID: String, mediaSet: String, AVType: BBCSMPAVType, streamType: BBCSMPStreamType, avStatisticsConsumer: BBCSMPAVStatisticsConsumer) {
        self.VPID = VPID
        self.mediaSet = mediaSet
        self.AVType = AVType
        self.streamType = streamType
        self.avStatisticsConsumer = avStatisticsConsumer
        self.playbackConfigAdapter = PlaybackConfigServiceAdapter()
        connectionResolver = NetworkSensitiveConnectionResolver(networkAvailability: HTTPClientNetworkAvailability())
    }

    // MARK: Builder Mutations
    @discardableResult
    func withPlaybackConfigAdapter(_ playbackConfigAdapter: PlaybackConfigAdapter) -> MediaSelectorItemProviderBuilder {
        self.playbackConfigAdapter = playbackConfigAdapter
        return self
    }

    @discardableResult
    func withMediaSelectorClient(_ mediaSelectorClient: MediaSelectorClient) -> MediaSelectorItemProviderBuilder {
        self.mediaSelectorClient = mediaSelectorClient
        return self
    }

    @discardableResult
    public func withMediaSelectorConfiguration(_ mediaSelectorConfiguring: MediaSelectorConfiguring) -> MediaSelectorItemProviderBuilder {
        self.mediaSelectorClient = MediaSelectorClient().with(configuration: mediaSelectorConfiguring)
        return self
    }

    @discardableResult
    public func withArtworkFetcher(_ artworkFetcher: BBCSMPArtworkFetcher) -> MediaSelectorItemProviderBuilder {
        self.artworkFetcher = artworkFetcher
        return self
    }

    @discardableResult
    public func withSAMLToken(_ samlToken: String) -> MediaSelectorItemProviderBuilder {
        self.samlToken = samlToken
        return self
    }

    @discardableResult
    public func withCeiling(_ ceiling: String) -> MediaSelectorItemProviderBuilder {
        self.ceiling = ceiling
        return self
    }

    @discardableResult
    public func withSecureConnectionPreference(_ secureConnectionPreference: BBCSMPConnectionPreference) -> MediaSelectorItemProviderBuilder {
        self.secureConnectionPreference = secureConnectionPreference
        return self
    }

    @discardableResult
    public func withSuppliers(_ suppliers: [String]) -> MediaSelectorItemProviderBuilder {
        self.suppliers = suppliers
        return self
    }

    @discardableResult
    public func withArtworkURLProvider(_ artworkURLProvider: BBCSMPArtworkURLProvider) -> MediaSelectorItemProviderBuilder {
        self.artworkURLProvider = artworkURLProvider
        return self
    }

    @discardableResult
    public func withContentID(_ contentID: String) -> MediaSelectorItemProviderBuilder {
        self.contentID = contentID
        return self
    }

    @discardableResult
    public func withPlayOffset(_ playOffset: TimeInterval) -> MediaSelectorItemProviderBuilder {
        self.playOffset = playOffset
        return self
    }

    @discardableResult
    public func withTitle(_ title: String) -> MediaSelectorItemProviderBuilder {
        self.title = title
        return self
    }

    @discardableResult
    public func withSubtitle(_ subtitle: String) -> MediaSelectorItemProviderBuilder {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    public func withGuidanceMessage(_ guidanceMessage: String) -> MediaSelectorItemProviderBuilder {
        self.guidanceMessage = guidanceMessage
        return self
    }

    @discardableResult
    public func withDuration(_ duration: BBCSMPDuration) -> MediaSelectorItemProviderBuilder {
        self.duration = duration
        return self
    }

    @discardableResult
    public func withCustomAVStatsLabels(_ customAVStatsLabels: [String: String]) -> MediaSelectorItemProviderBuilder {
        self.customAVStatsLabels = customAVStatsLabels
        return self
    }

    @discardableResult
    public func withConnectionResolver(_ connectionResolver: BBCSMPMediaSelectorConnectionResolver) -> MediaSelectorItemProviderBuilder {
        self.connectionResolver = connectionResolver
        return self
    }
    
    @discardableResult
    public func withDecoderFactory(_ decoderFactory: MediaSelectorDecoderFactory) -> MediaSelectorItemProviderBuilder {
        self.decoderFactory = decoderFactory
        return self
    }
    
    @discardableResult
    public func withVideoTrackSubscriber(
        _ videoTrackSubscriber: VideoTrackSubscriber
    ) -> MediaSelectorItemProviderBuilder {
        self.videoTrackSubscriber = videoTrackSubscriber
        return self
    }
    
    @discardableResult
    public func withAuthenticationProvider(
    _ authenticationProvider: BBCMediaSelectorAuthenticationProvider
    ) -> MediaSelectorItemProviderBuilder {
        self.authenticationProvider = authenticationProvider
        return self
    }

    // MARK: Assembly
    
    public func buildItemProvider() -> BBCSMPItemProvider {
        let provider = BBCSMPBackingOffMediaSelectorPlayerItemProvider(
            mediaSelectorClient: mediaSelectorClient,
            mediaSet: mediaSet,
            vpid: VPID,
            artworkFetcher: artworkFetcher,
            connectionResolver: self.connectionResolver,
            avStatisticsConsumer: avStatisticsConsumer,
            decoderFactory: decoderFactory,
            videoTrackSubsciber: videoTrackSubscriber
        )!
        
        if authenticationProvider != nil {
            provider.authenticationProvider = authenticationProvider
        }
                
        if samlToken != "" {
            provider.samlToken = samlToken
        }
        
        if ceiling != "" {
            provider.ceiling = ceiling
        }
        
        if let pref = secureConnectionPreference {
            provider.preference = pref
        }

        if let playOffset = playOffset {
            provider.playOffset = playOffset
        }

        if guidanceMessage != "" {
            provider.guidanceMessage = guidanceMessage
        }

        if let suppliers = suppliers, suppliers.isEmpty == false {
            provider.suppliers = suppliers
        }

        if let artworkFetcher = artworkFetcher {
            provider.artworkFetcher = artworkFetcher
        }

        provider.configServiceIsOnValue = playbackConfigAdapter.config().isOn ? "true" : "false"

        provider.avType = AVType
        provider.streamType = streamType
        provider.artworkURLProvider = artworkURLProvider
        provider.contentId = contentID
        provider.title = title
        provider.subtitle = subtitle
        provider.duration = duration
        provider.customAVStatsLabels = customAVStatsLabels

        return provider
    }
}
