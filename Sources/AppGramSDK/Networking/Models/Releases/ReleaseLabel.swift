import Foundation
import SwiftUI

/// Labels that categorize releases by their type.
///
/// ## Discussion
/// Release labels help users quickly identify what type of changes are included
/// in a release (new features, improvements, bug fixes, etc.).
///
/// ## Example
/// ```swift
/// let label: ReleaseLabel = .feature
/// ```
public enum ReleaseLabel: String, Codable, CaseIterable, Sendable {
    /// A new feature has been added.
    case feature
    
    /// An existing feature has been improved.
    case improvement
    
    /// A bug has been fixed.
    case bugfix
    
    /// Maintenance and updates.
    case maintenance
    
    /// Performance improvements.
    case performance
    
    /// An announcement or important notice.
    case announcement

    public var displayName: String {
        switch self {
        case .feature:
            return "Feature"
        case .improvement:
            return "Improvement"
        case .bugfix:
            return "Bug Fix"
        case .maintenance:
            return "Maintenance"
        case .performance:
            return "Performance"
        case .announcement:
            return "Announcement"
        }
    }

    public var color: Color {
        switch self {
        case .feature:
            return .blue
        case .improvement:
            return .green
        case .bugfix:
            return .red
        case .maintenance:
            return .orange
        case .performance:
            return .purple
        case .announcement:
            return .cyan
        }
    }

    public var iconName: String {
        switch self {
        case .feature:
            return "star.fill"
        case .improvement:
            return "arrow.up.circle.fill"
        case .bugfix:
            return "ladybug.fill"
        case .maintenance:
            return "wrench.and.screwdriver.fill"
        case .performance:
            return "bolt.fill"
        case .announcement:
            return "megaphone.fill"
        }
    }
}
