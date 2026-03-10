import Foundation
import os.log

/// Logger for AppGramSDK using OSLog with automatic production mode detection
public final class Logger {

    /// Log levels supported by the logger
    public enum LogLevel: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3

        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }

        var prefix: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }

    private let subsystem: String
    private let category: String
    private let osLog: OSLog

    /// Minimum log level to display. Set to .info or .error in production to hide debug logs
    public static var minimumLogLevel: LogLevel = {
        #if DEBUG
        return .debug
        #else
        return .error // Only show errors in production
        #endif
    }()

    /// Global flag to enable/disable logging
    public static var isEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false // Disable all logs in production by default
        #endif
    }()

    /// Shared logger instance for AppGramSDK
    public static let shared = Logger(subsystem: "com.appgram.sdk", category: "AppGramSDK")

    /// Initialize a logger with a specific subsystem and category
    /// - Parameters:
    ///   - subsystem: Subsystem identifier (usually bundle identifier)
    ///   - category: Category name for organizing logs
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }

    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func debug(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message(), file: file, function: function, line: line)
    }

    /// Log an info message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func info(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message(), file: file, function: function, line: line)
    }

    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func warning(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warning, message: message(), file: file, function: function, line: line)
    }

    /// Log an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: Source file (automatically captured)
    ///   - function: Function name (automatically captured)
    ///   - line: Line number (automatically captured)
    public func error(
        _ message: @autoclosure () -> String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, message: message(), file: file, function: function, line: line)
    }

    /// Internal logging method
    private func log(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard Self.isEnabled else { return }
        guard level >= Self.minimumLogLevel else { return }

        let fileName = (file as NSString).lastPathComponent
        let formattedMessage = "[\(fileName):\(line)] \(function) - \(message)"

        os_log("%{public}@", log: osLog, type: level.osLogType, formattedMessage)
    }
}

// MARK: - Convenience Extensions

extension Logger {
    /// Create a logger for a specific category
    public static func category(_ name: String) -> Logger {
        return Logger(subsystem: "com.appgram.sdk", category: name)
    }
}

// MARK: - Global Logging Functions

/// Log a debug message using the shared logger
public func logDebug(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.debug(message(), file: file, function: function, line: line)
}

/// Log an info message using the shared logger
public func logInfo(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.info(message(), file: file, function: function, line: line)
}

/// Log a warning message using the shared logger
public func logWarning(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.warning(message(), file: file, function: function, line: line)
}

/// Log an error message using the shared logger
public func logError(
    _ message: @autoclosure () -> String,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Logger.shared.error(message(), file: file, function: function, line: line)
}
