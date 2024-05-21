//
//  BBCSMPMediaSelectorErrorType.swift
//  SMP
//
//  Created by Sam Rowley on 01/07/2020.
//  Copyright © 2020 BBC. All rights reserved.
//
import Foundation

@objc public enum BBCSMPMediaSelectorErrorType: Int {
    case geolocation
    case generic
    case authorizationNotResolved
    case unauthorized
    case selectionUnavailable
    case tokenExpired
    case tokenInvalid
    case selectionUnavailableWithToken
}

@objc public class BBCSMPMediaSelectorErrorTransformer: NSObject {
    @objc public static func convertTypeToNSError(_ errorType: BBCSMPMediaSelectorErrorType) -> NSError {
        var errorCode: Int
        var localizedErrorDescription: String = NSStringFromBBCSMPErrorEnumeration(BBCSMPErrorEnumeration.mediaResolutionFailed)
        
        switch errorType {
        case .generic:
            errorCode = 1052
        case .geolocation:
            errorCode = 1056
            localizedErrorDescription = NSStringFromBBCSMPErrorEnumeration(BBCSMPErrorEnumeration.geolocation)
        case .authorizationNotResolved:
            errorCode = 7202
        case .unauthorized:
            errorCode = 1046
        case .selectionUnavailable:
            errorCode = 1052
        case .tokenExpired:
            errorCode = 1053
        case .tokenInvalid:
            errorCode = 1054
        case .selectionUnavailableWithToken:
            errorCode = 1073
            localizedErrorDescription = NSStringFromBBCSMPErrorEnumeration(BBCSMPErrorEnumeration.mediaResolutionFailedWithToken)
        }
        
        return NSError(domain: "smp-ios", code: errorCode, userInfo: [NSLocalizedDescriptionKey: localizedErrorDescription])
    }
    
    @objc public static func convertMediaSelectorErrorToNSError(_ mediaSelectorError: MediaSelectorError) -> NSError {
        var smpErrorType: BBCSMPMediaSelectorErrorType
        
        switch mediaSelectorError {
        case .geoLocation:
            smpErrorType = .geolocation
        case .selectionUnavailable:
            smpErrorType = .selectionUnavailable
        case .unauthorized:
            smpErrorType = .unauthorized
        case .tokenExpired:
            smpErrorType = .tokenExpired
        case .tokenInvalid:
            smpErrorType = .tokenInvalid
        case .authorizationNotResolved:
            smpErrorType = .authorizationNotResolved
        case .selectionUnavailableWithToken:
            smpErrorType = .selectionUnavailableWithToken
        default:
            smpErrorType = .generic
        }
        
        return convertTypeToNSError(smpErrorType)
    }
}
