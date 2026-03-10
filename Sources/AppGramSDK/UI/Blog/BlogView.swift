import SwiftUI

/// The main blog view that combines list and detail views.
public struct BlogView: View {
    @State private var viewModel: BlogViewModel
    @State private var selectedPost: BlogPost?
    @State private var showingDetail = false

    private let blogService: BlogServiceProtocol

    @Environment(\.appGramTheme) private var theme

    public init(blogService: BlogServiceProtocol) {
        self.blogService = blogService
        self._viewModel = State(initialValue: BlogViewModel(blogService: blogService))
    }

    public var body: some View {
        NavigationStack {
            BlogListView(
                blogService: blogService,
                onPostTap: { post in
                    selectedPost = post
                    showingDetail = true
                }
            )
            .navigationTitle("Blog")
            .navigationDestination(isPresented: $showingDetail) {
                if let post = selectedPost {
                    BlogPostDetailView(
                        post: post,
                        relatedPosts: viewModel.relatedPosts,
                        onRelatedPostTap: { relatedPost in
                            selectedPost = relatedPost
                            Task {
                                await viewModel.loadPost(slug: relatedPost.slug)
                            }
                        }
                    )
                    .task {
                        await viewModel.loadPost(slug: post.slug)
                    }
                }
            }
        }
    }
}

// MARK: - Convenience Initializer

extension BlogView {
    /// Creates a BlogView using the shared SDK instance.
    ///
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    public static func create() throws -> BlogView {
        let service = try AppGramSDK.shared.getBlogService()
        return BlogView(blogService: service)
    }
}
