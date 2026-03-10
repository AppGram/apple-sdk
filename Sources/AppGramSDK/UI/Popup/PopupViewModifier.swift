import SwiftUI

/// A view modifier that overlays a popup on any SwiftUI view.
///
/// This modifier makes it easy to add popup functionality to any view in your app.
/// Simply apply it to your root view to enable automatic popups throughout your app.
///
/// ## Example
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         TabView {
///             HomeView()
///             SettingsView()
///         }
///         .withAppGramPopup(manager: try! AppGramSDK.shared.getPopupManager())
///     }
/// }
/// ```
struct PopupViewModifier: ViewModifier {
    @ObservedObject var manager: PopupManager

    func body(content: Content) -> some View {
        ZStack {
            content
            PopupContainerView(manager: manager)
        }
    }
}

extension View {
    /// Adds AppGram popup functionality to this view.
    ///
    /// This method overlays a popup container on your view that will automatically
    /// display popups based on the configured trigger conditions.
    ///
    /// - Parameter manager: The popup manager instance from the SDK.
    /// - Returns: A view with popup functionality enabled.
    ///
    /// ## Example
    /// ```swift
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .withAppGramPopup(manager: try! AppGramSDK.shared.getPopupManager())
    ///         }
    ///     }
    /// }
    /// ```
    public func withAppGramPopup(manager: PopupManager) -> some View {
        self.modifier(PopupViewModifier(manager: manager))
    }
}
