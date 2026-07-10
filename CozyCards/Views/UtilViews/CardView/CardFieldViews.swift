import SwiftUI



/// One editable field of a card.
///
/// Reads `isEnabled` from the environment: enabled it is a `TextField`, disabled
/// it renders as text and hides itself entirely when empty. That is what lets
/// the same card view stream in the chat (`.disabled(true)`, fields appear as
/// the model fills them) and be edited in a sheet, with no second view.
struct CardField: View {


    private let placeholder: LocalizedStringKey

    @Binding private var text: String

    private let font: Font

    private let color: HierarchicalShapeStyle


    @Environment(\.isEnabled) private var isEnabled


    init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        font: Font = .body,
        color: HierarchicalShapeStyle = .primary
    ) {
        self.placeholder = placeholder
        self._text = text
        self.font = font
        self.color = color
    }


    var body: some View {
        if isEnabled {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(font)
                .foregroundStyle(color)
        } else if !text.isEmpty {
            Text(text)
                .font(font)
                .foregroundStyle(color)
        }
    }


}



/// The example sentences of a card.
///
/// Enabled, every example is editable and a trailing empty row adds a new one.
/// Disabled, empty examples are dropped and nothing is shown when none remain.
struct CardExamplesView: View {


    @Binding var examples: [String]


    @Environment(\.isEnabled) private var isEnabled


    var body: some View {
        if isEnabled {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(examples.indices, id: \.self) { index in
                    CardField("Example", text: $examples[index], font: .callout, color: .secondary)
                }

                CardField("Add an example", text: appended, font: .callout, color: .secondary)
            }
        } else {
            let filled = examples.filter { !$0.isEmpty }

            if !filled.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(filled, id: \.self) { example in
                        Text(example)
                            .font(.callout)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }


    /// A binding to a phantom trailing row that materializes on first keystroke.
    private var appended: Binding<String> {
        Binding(
            get: { "" },
            set: { newValue in
                guard !newValue.isEmpty else { return }
                examples.append(newValue)
            }
        )
    }


}



extension Binding where Value == String? {


    /// Presents an optional field as a plain string, storing an empty edit as `nil`.
    var orEmpty: Binding<String> {
        Binding<String>(
            get: { wrappedValue ?? "" },
            set: { wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }


}
