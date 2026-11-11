import SwiftUI

/// Unfinished features, each off until explicitly enabled here.
struct ExperimentsCard: View {
    @Bindable var dictation: DictationController
    @State private var fullKeyboard = FullKeyboardSettings().isEnabled
    @State private var localParakeetV3 = LocalSpeechSettings().parakeetV3Enabled
    @State private var appleIntelligenceCleanup = AppleIntelligenceCleanupSettings().isEnabled
    @State private var customVocabulary = CustomVocabularySettings().isEnabled
    @State private var cleanupAvailability = AppleIntelligenceCleanupAvailability.current

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

            Toggle(isOn: $appleIntelligenceCleanup) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Clean up with Apple Intelligence")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(HexTheme.textBase)
                    Text("Fix misheard words and spoken corrections on device")
                        .font(.system(size: 12))
                        .foregroundStyle(HexTheme.textMuted)
                    if let reason = cleanupAvailability.reason {
                        Text(reason)
                            .font(.system(size: 12))
                            .foregroundStyle(HexTheme.textMuted)
                    }
                }
            }
            .tint(HexTheme.success)
            .disabled(!cleanupAvailability.isAvailable)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                HexTheme.bgBase,
                in: RoundedRectangle(cornerRadius: HexTheme.cardRadius, style: .continuous)
            )
            .onChange(of: appleIntelligenceCleanup) { _, enabled in
                AppleIntelligenceCleanupSettings().isEnabled = enabled
            }

            Toggle(isOn: $customVocabulary) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Custom vocabulary")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(HexTheme.textBase)
                    Text("Spell names and terms your way")
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
            .onChange(of: customVocabulary) { _, enabled in
                CustomVocabularySettings().isEnabled = enabled
            }

            if customVocabulary {
                CustomVocabularyEditor()
                    .padding(12)
                    .background(
                        HexTheme.bgBase,
                        in: RoundedRectangle(
                            cornerRadius: HexTheme.cardRadius,
                            style: .continuous
                        )
                    )
            }
        }
        .onAppear {
            fullKeyboard = FullKeyboardSettings().isEnabled
            localParakeetV3 = dictation.isLocalParakeetV3Enabled
            appleIntelligenceCleanup = AppleIntelligenceCleanupSettings().isEnabled
            customVocabulary = CustomVocabularySettings().isEnabled
            cleanupAvailability = AppleIntelligenceCleanupAvailability.current
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
