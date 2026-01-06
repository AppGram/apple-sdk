# AppGramSDK Design System Migration Guide

## Overview

AppGramSDK v2.0 introduces a unified design system based on **shadcn's minimal aesthetic**, creating a modern, professional SDK that feels native to iOS while maintaining web design sophistication.

**All changes are backward compatible with zero breaking changes.**

## What's New

### Design System (DesignSystem.swift)

A centralized design system providing constants for:

- **Spacing Scale**: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32), xxxl(48)
- **Typography Scale**: xs(12), sm(14), base(16), lg(18), xl(20), xxl(24), xxxl(32)
- **Corner Radius**: xs(4), sm(6), md(8), lg(12), xl(16), xxl(20), pill(999)
- **Border Width**: hairline(0.5), thin(1), medium(1.5), thick(2)
- **Shadow Styles**: Subtle low-opacity shadows (xs, sm, md, lg, xl)
- **Animations**: Spring curves with natural feel (150-400ms)
- **Opacity Levels**: disabled(0.4), muted(0.6), subtle(0.8), full(1.0)

### Enhanced Color System

**Neutral Color Scale** (shadcn-inspired):
```swift
neutral50, neutral100, neutral200, // ... neutral900
```
- `neutral200` is the primary color for subtle borders (#e5e5e5)

### New Theme Presets

Two new presets alongside the existing 7:

1. **slate** - shadcn minimal aesthetic with slate gray tones
2. **neutral** - pure minimal design with neutral grayscale

**Total: 8 theme presets** (modern, modernDark, ocean, forest, sunset, minimal, classic, slate, neutral)

### View Extensions

Convenient modifiers for applying design system styles:

```swift
.shadowStyle(DesignSystem.Shadow.sm)
.layeredShadow()
.pressAnimation(isPressed: isPressed)
.focusRing(isFocused: isFocused, color: colors.primary)
.cardHoverEffect()
.dynamicShrink(isScrolling: isScrolling)
```

## Migration Examples

### Before/After: Buttons

```swift
// BEFORE
.padding(.vertical, 14)
.background(colors.primary)
.cornerRadius(10)

// AFTER
.padding(.vertical, DesignSystem.Spacing.lg)  // 16px
.padding(.horizontal, DesignSystem.Spacing.xl)  // 24px
.background(colors.primary)
.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))  // 12px
.shadowStyle(DesignSystem.Shadow.sm)
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(DesignSystem.Animation.spring, value: isPressed)
```

### Before/After: Cards

```swift
// BEFORE
.padding()  // 16
.background(colors.cardBackground)
.cornerRadius(12)
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(colors.border, lineWidth: 1)
)

// AFTER
.padding(DesignSystem.Spacing.lg)  // 16px, explicit
.background(colors.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))  // 12px
.overlay(
    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)  // subtle border
)
.layeredShadow()  // Soft double shadow
.cardHoverEffect()  // iOS 26 hover
```

### Before/After: Badges

```swift
// BEFORE
.padding(.horizontal, 8)
.padding(.vertical, 4)
.background(statusColor.opacity(0.1))
.cornerRadius(4)

// AFTER
.padding(.horizontal, DesignSystem.Spacing.sm)  // 8px
.padding(.vertical, DesignSystem.Spacing.xs)  // 4px
.background(statusColor.opacity(0.08))  // More subtle
.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))  // 4px
.overlay(
    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
        .strokeBorder(statusColor.opacity(0.2), lineWidth: DesignSystem.BorderWidth.hairline)  // Ultra-thin border
)
```

## Design Principles Applied

### Shadcn Aesthetic

1. **Subtle Borders**: 0.5-1px borders using `neutral200` color, barely visible but provide definition
2. **Soft Shadows**: Low opacity (0.04-0.08), layered for depth without heaviness
3. **Consistent Spacing**: 4px base increment, no magic numbers
4. **Refined Typography**: Clear size scale with proper line heights and weights
5. **Minimal**: Clean, professional, no visual noise


## Backward Compatibility

### Zero Breaking Changes

✅ All existing APIs work unchanged
✅ Existing configurations remain functional
✅ Current theme presets preserved
✅ Public interfaces unchanged

### Opt-In Features

- New theme presets are alongside existing ones (user choice)
- Design system constants recommended but existing values still work

## Migration Strategy

### Recommended Approach

1. **Review updated components** as reference implementations:
   - `PrimaryButton.swift` - Button pattern
   - `FeedbackCardView.swift` - Card pattern
   - `StatusBadge.swift` - Badge pattern

2. **Adopt design system constants** in your custom components:
   ```swift
   // Replace hardcoded values
   .padding(16) → .padding(DesignSystem.Spacing.lg)
   .font(.system(size: 14)) → .font(.system(size: DesignSystem.Typography.sm))
   .cornerRadius(12) → .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
   ```

3. **Apply new theme colors** where appropriate:
   ```swift
   // Use subtle borders
   .stroke(colors.border) → .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
   ```

4. **Add animations** for interactive elements:
   ```swift
   .scaleEffect(isPressed ? 0.98 : 1.0)
   .animation(DesignSystem.Animation.spring, value: isPressed)
   ```

5. **Try new theme presets**:
   ```swift
   AppGramSDK.shared.configure(
       projectId: "...",
       theme: .glass  // or .slate, .neutral
   )
   ```

## Components Updated

### ✅ Completed

**Foundation:**
- DesignSystem.swift (new)
- ColorPalette.swift (extended)
- ColorPresets.swift (3 new presets)

**Buttons:**
- PrimaryButton.swift

**Cards:**
- FeedbackCardView.swift
- RoadmapItemCard.swift

**Badges:**
- StatusBadge.swift
- CategoryBadge.swift
- TicketStatusBadge.swift
- ReleaseLabelBadge.swift

### 🚧 Pending (Following Established Pattern)

**Cards:**
- ReleaseCard.swift
- HelpArticleCard.swift
- AnnouncementCardView.swift
- (plus ~4 more)

**Forms:**
- FormTextFieldView.swift
- FormEmailFieldView.swift
- FormTextAreaView.swift
- FormSelectFieldView.swift
- FormRadioFieldView.swift
- FormCheckboxFieldView.swift

**Utility:**
- EmptyStateView.swift
- LoadingView.swift
- ErrorView.swift
- VoteButton.swift
- CommentView.swift

**Popup System:**
- PopupContainerView.swift
- BottomBannerView.swift

## Usage Examples

### Using Design System Spacing

```swift
VStack(spacing: DesignSystem.Spacing.lg) {
    Text("Title")
        .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold))
        .padding(.horizontal, DesignSystem.Spacing.xl)

    Text("Description")
        .font(.system(size: DesignSystem.Typography.sm))
        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
}
```


### Creating Animated Buttons

```swift
Button("Action") {
    // handle action
}
.padding(.vertical, DesignSystem.Spacing.lg)
.padding(.horizontal, DesignSystem.Spacing.xl)
.background(colors.primary)
.clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
.shadowStyle(DesignSystem.Shadow.sm)
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(DesignSystem.Animation.spring, value: isPressed)
```

### Using New Theme Presets

```swift
// Slate theme - shadcn minimal aesthetic
AppGramSDK.shared.configure(
    projectId: "your-project-id",
    theme: AppGramTheme(
        colors: .slate,
        darkColors: nil  // Uses same colors with system dark mode adaptation
    )
)

// Neutral theme - pure minimal design
AppGramSDK.shared.configure(
    projectId: "your-project-id",
    theme: AppGramTheme(
        colors: .neutral,
        darkColors: nil
    )
)
```


## Design Tokens Reference

### Spacing Scale

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 4px | Tiny gaps, badge padding |
| `sm` | 8px | Small spacing, icon gaps |
| `md` | 12px | Medium spacing |
| `lg` | 16px | Default padding (most common) |
| `xl` | 24px | Section spacing |
| `xxl` | 32px | Large sections |
| `xxxl` | 48px | Major sections |

### Typography Scale

| Token | Size | Use Case |
|-------|------|----------|
| `xs` | 12px | Captions, fine print |
| `sm` | 14px | Secondary text |
| `base` | 16px | Body text (default) |
| `lg` | 18px | Subheadings |
| `xl` | 20px | Headings |
| `xxl` | 24px | Large headings |
| `xxxl` | 32px | Hero text |

### Shadow Styles

| Style | Radius | Y Offset | Opacity | Use Case |
|-------|--------|----------|---------|----------|
| `xs` | 2 | 1 | 0.04 | Minimal elevation |
| `sm` | 4 | 2 | 0.06 | Subtle elevation (buttons) |
| `md` | 8 | 4 | 0.08 | Standard cards |
| `lg` | 12 | 6 | 0.10 | Prominent elements |
| `xl` | 16 | 8 | 0.12 | Floating elements |

### Corner Radius

| Token | Value | Use Case |
|-------|-------|----------|
| `xs` | 4px | Badges |
| `sm` | 6px | Small buttons |
| `md` | 8px | Form fields |
| `lg` | 12px | Cards, buttons (most common) |
| `xl` | 16px | Large cards |
| `xxl` | 20px | Sheets, modals |
| `pill` | 999px | Capsule shapes |

## Performance Considerations

### Zero Runtime Overhead

- All design system values are compile-time constants
- No performance impact on existing code
- Spring animations are GPU-accelerated by SwiftUI
- Liquid Glass materials use native iOS rendering

### Best Practices

1. Use design system constants to maintain consistency
2. Apply `.layeredShadow()` sparingly (only on cards)
3. Prefer `.clipShape()` over `.cornerRadius()` for better performance
4. Use `.liquidGlass()` on iOS 16+ (automatic fallback on older versions)

## Support & Resources

### Documentation

- All components have DocC documentation with examples
- Design system constants are fully documented
- Migration patterns established in reference implementations

### iOS 26 Liquid Glass Research

- [Apple Liquid Glass Design Announcement](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [iOS 26 Developer Guide](https://www.index.dev/blog/ios-26-developer-guide)
- [Complete Guide to iOS 26 - WWDC 2025](https://medium.com/simform-engineering/wwdc-2025-the-complete-guide-to-ios-26-45aaf8d1c5e5)

## Questions?

For issues or questions about the design system migration:
- Review reference implementations (PrimaryButton, FeedbackCardView, StatusBadge)
- Check component DocC documentation
- Refer to this migration guide

---

**Version**: 2.0
**Last Updated**: December 2025
**iOS Support**: iOS 14+ (iOS 16+ for full Liquid Glass)
