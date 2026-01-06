import SwiftUI

// MARK: - Text Field View

public struct FormTextFieldView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            fieldLabel

            TextField(field.placeholder ?? "", text: $value)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text)
                .textFieldStyle(.plain)
                .padding(DesignSystem.Spacing.md)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .onChange(of: value) { _, _ in
                    onValidate()
                }

            if let error = error {
                errorText(error)
            }
        }
    }

    private var fieldLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(field.label)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text)

            if field.required {
                Text("*")
                    .foregroundColor(colors.error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}

// MARK: - Email Field View

public struct FormEmailFieldView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            fieldLabel

            TextField(field.placeholder ?? "email@example.com", text: $value)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text)
                .textFieldStyle(.plain)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .padding(DesignSystem.Spacing.md)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .onChange(of: value) { _, _ in
                    onValidate()
                }

            if let error = error {
                errorText(error)
            }
        }
    }

    private var fieldLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(field.label)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text)

            if field.required {
                Text("*")
                    .foregroundColor(colors.error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}

// MARK: - TextArea Field View

public struct FormTextAreaView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            fieldLabel

            ZStack(alignment: .topLeading) {
                TextEditor(text: $value)
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text)
                    .scrollContentBackground(.hidden)
                    .padding(DesignSystem.Spacing.sm)
                    .frame(minHeight: 120)
                    .background(colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                    .onChange(of: value) { _, _ in
                        onValidate()
                    }

                if value.isEmpty, let placeholder = field.placeholder {
                    Text(placeholder)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(0.3))
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.lg)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                if let error = error {
                    errorText(error)
                }

                Spacer()

                if let maxLength = field.validation?.maxLength {
                    Text("\(value.count)/\(maxLength)")
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(value.count > maxLength ? colors.error : colors.text.opacity(0.5))
                }
            }
        }
    }

    private var fieldLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(field.label)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text)

            if field.required {
                Text("*")
                    .foregroundColor(colors.error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}

// MARK: - Select Field View

public struct FormSelectFieldView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            fieldLabel

            Menu {
                Button("Select an option") {
                    value = ""
                    onValidate()
                }

                if let options = field.options {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            value = option
                            onValidate()
                        }
                    }
                }
            } label: {
                HStack {
                    Text(value.isEmpty ? (field.placeholder ?? "Select an option") : value)
                        .foregroundColor(value.isEmpty ? colors.text.opacity(0.5) : colors.text)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.text.opacity(0.5))
                }
                .padding(DesignSystem.Spacing.md)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }

            if let error = error {
                errorText(error)
            }
        }
    }

    private var fieldLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(field.label)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text)

            if field.required {
                Text("*")
                    .foregroundColor(colors.error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}

// MARK: - Radio Field View

public struct FormRadioFieldView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            fieldLabel

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if let options = field.options {
                    ForEach(options, id: \.self) { option in
                        radioButton(for: option)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
            )

            if let error = error {
                errorText(error)
            }
        }
    }

    private func radioButton(for option: String) -> some View {
        Button {
            value = option
            onValidate()
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .strokeBorder(value == option ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.medium)
                        .frame(width: 20, height: 20)

                    if value == option {
                        Circle()
                            .fill(colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                Text(option)
                    .font(.body)
                    .foregroundColor(colors.text)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    private var fieldLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(field.label)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text)

            if field.required {
                Text("*")
                    .foregroundColor(colors.error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}

// MARK: - Checkbox Field View

public struct FormCheckboxFieldView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let field: FormField
    @Binding var value: String
    let error: String?
    let onValidate: () -> Void

    private var isChecked: Bool {
        value == "true"
    }

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        field: FormField,
        value: Binding<String>,
        error: String?,
        onValidate: @escaping () -> Void
    ) {
        self.field = field
        self._value = value
        self.error = error
        self.onValidate = onValidate
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Button {
                value = isChecked ? "false" : "true"
                onValidate()
            } label: {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                            .strokeBorder(isChecked ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.medium)
                            .frame(width: 22, height: 22)

                        if isChecked {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                .fill(colors.primary)
                                .frame(width: 22, height: 22)

                            Image(systemName: "checkmark")
                                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.bold))
                                .foregroundColor(.white)
                        }
                    }

                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(field.label)
                            .font(.body)
                            .foregroundColor(colors.text)
                            .multilineTextAlignment(.leading)

                        if field.required {
                            Text("*")
                                .foregroundColor(colors.error)
                        }
                    }

                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(error != nil ? colors.error : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }
            .buttonStyle(.plain)

            if let error = error {
                errorText(error)
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.Typography.xs))
            .foregroundColor(colors.error)
    }
}
