import SwiftUI

/// Unfinished features, each off until explicitly enabled here.
struct ExperimentsCard: View {
    @Bindable var dictation: DictationController
    @State private var fullKeyboard = FullKeyboardSettings().isEnabled
    @State private var localParakeetV3 = LocalSpeechSettings().parakeetV3Enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Experiments")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(HexTheme.textMuted)
                .padding(.leading, 16)

            experimentRow(
                "Full keyboard",
                description: "Type with Hex, with a Hex key to dictate",
                isOn: $fullKeyboard
            )
            .onChange(of: fullKeyboard) { _, enabled in
                FullKeyboardSettings().isEnabled = enabled
            }

            experimentRow(
                "Local Parakeet v3",
                description: "Transcribe on this iPhone in 25 languages",
                isOn: $localParakeetV3
            )
            .disabled(!dictation.canChangeSpeechEngine)
            .onChange(of: localParakeetV3) { _, enabled in
                if !dictation.setLocalParakeetV3Enabled(enabled) {
                    localParakeetV3 = dictation.isLocalParakeetV3Enabled
                }
            }
        }
        .onAppear {
            fullKeyboard = FullKeyboardSettings().isEnabled
            localParakeetV3 = dictation.isLocalParakeetV3Enabled
        }
    }

    private func experimentRow(
        _ title: String,
        description: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(HexTheme.textBase)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(HexTheme.textMuted)
            }
        }
        .tint(HexTheme.success)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            HexTheme.bgBase,
            in: RoundedRectangle(cornerRadius: HexTheme.cardRadius, style: .continuous)
        )
    }
}
