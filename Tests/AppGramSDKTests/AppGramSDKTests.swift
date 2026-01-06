import Testing
@testable import AppGramSDK

@Suite("AppGramSDK Tests")
struct AppGramSDKTests {
    @Test("SDK version is correct")
    func testVersion() {
        #expect(AppGramSDK.version == "1.2.0")
    }

    @Test("UserContext anonymous mode")
    func testAnonymousUserContext() {
        let context = UserContext.anonymous
        #expect(context.isAnonymous == true)
        #expect(context.userId == nil)
        #expect(context.email == nil)
        #expect(context.name == nil)
    }

    @Test("UserContext authenticated mode")
    func testAuthenticatedUserContext() {
        let context = UserContext(
            userId: "user_123",
            email: "test@example.com",
            name: "Test User",
            isAnonymous: false
        )
        #expect(context.isAnonymous == false)
        #expect(context.userId == "user_123")
        #expect(context.email == "test@example.com")
        #expect(context.name == "Test User")
    }

    @Test("Color hex initialization")
    @MainActor
    func testColorHexInitialization() {
        let color = ColorPalette.modern.primary
        #expect(color != nil)
    }

    @Test("WishStatus display names")
    func testWishStatusDisplayNames() {
        #expect(WishStatus.pending.displayName == "Pending")
        #expect(WishStatus.underReview.displayName == "Under Review")
        #expect(WishStatus.planned.displayName == "Planned")
        #expect(WishStatus.inProgress.displayName == "In Progress")
        #expect(WishStatus.completed.displayName == "Completed")
        #expect(WishStatus.declined.displayName == "Declined")
    }
}
