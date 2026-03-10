import Foundation
import CryptoKit

#if canImport(UIKit)
import UIKit
#endif

public actor DeviceFingerprint {
    public static let shared = DeviceFingerprint()

    private var cachedFingerprint: String?

    private init() {}

    public func generate() async -> String {
        if let cached = cachedFingerprint {
            return cached
        }

        #if canImport(UIKit)
        let identifierForVendor = await MainActor.run {
            UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        }
        let model = await MainActor.run {
            UIDevice.current.model
        }
        let systemVersion = await MainActor.run {
            UIDevice.current.systemVersion
        }
        #else
        let identifierForVendor = UUID().uuidString
        let model = "Mac"
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        #endif

        let combined = "\(identifierForVendor)-\(model)-\(systemVersion)"

        guard let data = combined.data(using: .utf8) else {
            let fallback = UUID().uuidString
            cachedFingerprint = fallback
            return fallback
        }

        let hash = SHA256.hash(data: data)
        let fingerprint = hash.compactMap { String(format: "%02x", $0) }.joined()
        cachedFingerprint = fingerprint
        return fingerprint
    }

    public func reset() {
        cachedFingerprint = nil
    }
}
