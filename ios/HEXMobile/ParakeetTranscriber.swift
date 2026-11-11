import FluidAudio
import Foundation

struct ModelPreparationProgress: Sendable {
    let fractionCompleted: Double
    let detail: String
}

protocol LocalTranscribing: Actor {
    nonisolated var displayName: String { get }
    var languageName: String { get }

    func prepare(
        progressHandler: @escaping @Sendable (ModelPreparationProgress) -> Void
    ) async throws

    func transcribe(_ audioURL: URL) async throws -> String
    func transcribe(_ audioURL: URL, vocabulary: [String]) async throws -> String
}

extension LocalTranscribing {
    /// Engines without a recognition hint ignore the list and transcribe exactly as before.
    nonisolated func transcribe(_ audioURL: URL, vocabulary: [String]) async throws -> String {
        try await transcribe(audioURL)
    }
}

actor ParakeetTranscriber: LocalTranscribing {
    enum TranscriberError: LocalizedError {
        case notPrepared
        case emptyTranscript

        var errorDescription: String? {
            switch self {
            case .notPrepared:
                "Parakeet is not ready."
            case .emptyTranscript:
                "Parakeet did not detect any speech."
            }
        }
    }

    private var manager: AsrManager?

    private let variant: ParakeetVariant
    nonisolated let displayName: String
    let languageName: String

    init(variant: ParakeetVariant = .v2) {
        self.variant = variant
        self.displayName = variant.displayName
        self.languageName = variant.languageName
    }

    private static func modelVersion(for variant: ParakeetVariant) -> AsrModelVersion {
        switch variant {
        case .v2: .v2
        case .v3: .v3
        }
    }

    nonisolated static func hasCachedModel(for variant: ParakeetVariant) -> Bool {
        let version = modelVersion(for: variant)
        return AsrModels.modelsExist(
            at: AsrModels.defaultCacheDirectory(for: version),
            version: version
        )
    }

    func prepare(
        progressHandler: @escaping @Sendable (ModelPreparationProgress) -> Void
    ) async throws {
        guard manager == nil else { return }

        let models = try await AsrModels.downloadAndLoad(
            version: Self.modelVersion(for: variant),
            progressHandler: { progress in
                progressHandler(
                    ModelPreparationProgress(
                        fractionCompleted: progress.fractionCompleted,
                        detail: Self.detail(for: progress.phase)
                    )
                )
            }
        )
        let manager = AsrManager(config: .default)
        try await manager.loadModels(models)
        self.manager = manager
    }

    private static func detail(for phase: DownloadPhase) -> String {
        switch phase {
        case .listing:
            "Checking model files"
        case .downloading(let completedFiles, let totalFiles):
            "Downloading file \(min(completedFiles + 1, totalFiles)) of \(totalFiles)"
        case .compiling(let modelName):
            "Compiling \(modelName)"
        }
    }

    func transcribe(_ audioURL: URL) async throws -> String {
        guard let manager else {
            throw TranscriberError.notPrepared
        }

        let decoderLayers = await manager.decoderLayerCount
        var decoderState = TdtDecoderState.make(decoderLayers: decoderLayers)
        let result = try await manager.transcribe(
            audioURL,
            decoderState: &decoderState
        )
        let text = result.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !text.isEmpty else {
            throw TranscriberError.emptyTranscript
        }
        return text
    }
}
