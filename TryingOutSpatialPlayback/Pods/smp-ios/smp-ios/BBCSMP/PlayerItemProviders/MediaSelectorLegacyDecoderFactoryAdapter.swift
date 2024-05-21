import Foundation

/// A type that bridges the legacy ``DecoderFactory`` system into the item provider based system.
///
/// Wrap an pre-configured ``BBCSMPAVDecoderFactory`` within this adapter in order to continue supplying any custom
/// configuration applied to the resultant decoders (e.g. time update frequency).
@objc(BBCSMPMediaSelectorLegacyDecoderFactoryAdapter)
public class MediaSelectorLegacyDecoderFactoryAdapter: NSObject, MediaSelectorDecoderFactory {
    
    private let decoderFactory: BBCSMPAVDecoderFactory
    
    public override convenience init() {
        self.init(decoderFactory: BBCSMPAVDecoderFactory())
    }
    
    public init(decoderFactory: BBCSMPAVDecoderFactory) {
        self.decoderFactory = decoderFactory
    }
    
    public func createDecoderForPlaylist(atURL url: URL, videoTrackSubscriber: VideoTrackSubscriber?) -> BBCSMPDecoder {
        if let videoTrackSubscriber = videoTrackSubscriber {
            decoderFactory.withVideoTrackSubscriber(videoTrackSubscriber)
        }
        
        return decoderFactory.createDecoder()
    }
    
}
