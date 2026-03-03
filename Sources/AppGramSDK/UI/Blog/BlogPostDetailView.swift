import SwiftUI
import NetworkImage

/// A view displaying the full content of a blog post.
public struct BlogPostDetailView: View {
    let post: BlogPost
    let relatedPosts: [BlogPost]
    let onRelatedPostTap: ((BlogPost) -> Void)?
    let onBack: (() -> Void)?

    @Environment(\.appGramTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    public init(
        post: BlogPost,
        relatedPosts: [BlogPost] = [],
        onRelatedPostTap: ((BlogPost) -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.post = post
        self.relatedPosts = relatedPosts
        self.onRelatedPostTap = onRelatedPostTap
        self.onBack = onBack
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Image
                if let imageUrl = post.ogImageUrl, let url = URL(string: imageUrl) {
                    NetworkImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                            .overlay {
                                ProgressView()
                                    .tint(theme.colors.primary)
                            }
                    } fallback: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(theme.colors.neutral500)
                            }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Category
                    if let category = post.category {
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.colors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(theme.colors.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    // Title
                    Text(post.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(theme.colors.text)

                    // Meta info
                    HStack(spacing: 16) {
                        if let authorName = post.authorName, !authorName.isEmpty {
                            Label(authorName, systemImage: "person.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.neutral500)
                        }

                        if let publishedAt = post.publishedAt {
                            Label(publishedAt.formatted(date: .long, time: .omitted), systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.neutral500)
                        }

                        if post.viewCount > 0 {
                            Label("\(post.viewCount)", systemImage: "eye")
                                .font(.subheadline)
                                .foregroundStyle(theme.colors.neutral500)
                        }
                    }

                    Divider()
                        .background(theme.colors.border)

                    // Content
                    BlogContentView(content: post.content, theme: theme)

                    // Tags
                    if !post.tags.isEmpty {
                        Divider()
                            .background(theme.colors.border)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.colors.neutral500)

                            FlowLayout(spacing: 8) {
                                ForEach(post.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.colors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(theme.colors.primary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Related Posts
                    if !relatedPosts.isEmpty {
                        Divider()
                            .background(theme.colors.border)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Posts")
                                .font(.headline)
                                .foregroundStyle(theme.colors.text)

                            ForEach(relatedPosts, id: \.id) { relatedPost in
                                RelatedPostRow(post: relatedPost, theme: theme) {
                                    onRelatedPostTap?(relatedPost)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .background(theme.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onBack != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onBack?()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Related Post Row

private struct RelatedPostRow: View {
    let post: BlogPost
    let theme: AppGramTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let imageUrl = post.ogImageUrl, let url = URL(string: imageUrl) {
                    NetworkImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                    } fallback: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(2)

                    if let publishedAt = post.publishedAt {
                        Text(publishedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(theme.colors.neutral500)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.colors.neutral500)
            }
            .padding(12)
            .background(theme.colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

