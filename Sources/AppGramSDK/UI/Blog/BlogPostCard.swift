import SwiftUI
import NetworkImage

/// A card view displaying a blog post preview.
public struct BlogPostCard: View {
    let post: BlogPost
    let onTap: (() -> Void)?

    @Environment(\.appGramTheme) private var theme

    public init(post: BlogPost, onTap: (() -> Void)? = nil) {
        self.post = post
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                // Featured Image
                if let imageUrl = post.ogImageUrl, let url = URL(string: imageUrl) {
                    NetworkImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(theme.colors.neutral500)
                            }
                    } fallback: {
                        Rectangle()
                            .fill(theme.colors.border.opacity(0.3))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(theme.colors.neutral500)
                            }
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Category badge
                    if let category = post.category {
                        Text(category.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(theme.colors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.colors.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    // Title
                    Text(post.title)
                        .font(.headline)
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Excerpt
                    if let excerpt = post.excerpt, !excerpt.isEmpty {
                        Text(excerpt)
                            .font(.subheadline)
                            .foregroundStyle(theme.colors.neutral500)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }

                    // Meta info
                    HStack(spacing: 12) {
                        if let authorName = post.authorName, !authorName.isEmpty {
                            Label(authorName, systemImage: "person.circle")
                                .font(.caption)
                                .foregroundStyle(theme.colors.neutral500)
                        }

                        if let publishedAt = post.publishedAt {
                            Label(publishedAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(theme.colors.neutral500)
                        }

                        Spacer()

                        if post.isFeatured {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }

                    // Tags
                    if !post.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(post.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption2)
                                        .foregroundStyle(theme.colors.neutral500)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(theme.colors.cardBackground)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(12)
            .background(theme.colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
