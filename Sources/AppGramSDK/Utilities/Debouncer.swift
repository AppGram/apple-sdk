import Foundation

@MainActor
public final class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: TimeInterval

    public init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }

    public func debounce(action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
