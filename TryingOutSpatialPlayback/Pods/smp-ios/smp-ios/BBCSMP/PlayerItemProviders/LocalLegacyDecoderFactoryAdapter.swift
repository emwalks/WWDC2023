//
//  LocalLegacyDecoderFactoryAdapter.swift
//  SMP
//
//  Created by Marc Jowett on 01/07/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

import Foundation

/// A type that bridges the legacy ``DecoderFactory`` system into the item provider based system.
///
/// Wrap an pre-configured ``BBCSMPAVDecoderFactory`` within this adapter in order to continue supplying any custom
/// configuration applied to the resultant decoders (e.g. time update frequency).
@objc(BBCSMPLocalLegacyDecoderFactoryAdapter)
public class LocalLegacyDecoderFactoryAdapter: NSObject, LocalDecoderFactory {
    
    private let decoderFactory: BBCSMPAVDecoderFactory
    
    public override convenience init() {
        self.init(decoderFactory: BBCSMPAVDecoderFactory())
    }
    
    public init(decoderFactory: BBCSMPAVDecoderFactory) {
        self.decoderFactory = decoderFactory
    }
    
    public func createDecoderForContent(atLocalURL url: URL, videoTrackSubscriber: VideoTrackSubscriber?) -> BBCSMPDecoder {
        if let videoTrackSubscriber = videoTrackSubscriber {
            decoderFactory.withVideoTrackSubscriber(videoTrackSubscriber)
        }
        
        return decoderFactory.createDecoder()
    }
    
}
