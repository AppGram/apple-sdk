import Foundation

public actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    private struct CacheEntry {
        let value: Value
        let expiresAt: Date
    }

    private var storage: [Key: CacheEntry] = [:]
    private let defaultTTL: TimeInterval

    public init(defaultTTL: TimeInterval = 300) {
        self.defaultTTL = defaultTTL
    }

    public func get(key: Key) -> Value? {
        guard let entry = storage[key] else {
            return nil
        }

        if Date() > entry.expiresAt {
            storage.removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    public func set(key: Key, value: Value, ttl: TimeInterval? = nil) {
        let expiresAt = Date().addingTimeInterval(ttl ?? defaultTTL)
        storage[key] = CacheEntry(value: value, expiresAt: expiresAt)
    }

    public func remove(key: Key) {
        storage.removeValue(forKey: key)
    }

    public func clear() {
        storage.removeAll()
    }

    public func cleanup() {
        let now = Date()
        storage = storage.filter { $0.value.expiresAt > now }
    }
}
