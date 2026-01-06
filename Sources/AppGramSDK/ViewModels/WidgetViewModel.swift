import Foundation
import SwiftUI

@MainActor
internal class WidgetViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var widgetData: [String: Any] = [:]
    @Published var error: Error?
    
    private let widgetService: WidgetServiceProtocol
    private let configuration: AGWidgetConfiguration
    
    init(
        widgetService: WidgetServiceProtocol,
        configuration: AGWidgetConfiguration
    ) {
        self.widgetService = widgetService
        self.configuration = configuration
    }
    
    func loadWidgetData() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            widgetData = try await widgetService.getWidgetData(
                type: configuration.type,
                parameters: configuration.parameters
            )
        } catch {
            logError("Failed to load widget data: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
}
