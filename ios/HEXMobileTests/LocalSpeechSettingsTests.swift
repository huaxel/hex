import XCTest
@testable import HEX

final class LocalSpeechSettingsTests: XCTestCase {
    private var suite = ""
    private var defaults: UserDefaults!

    override func setUp() {
        suite = "hex.local-speech.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
    }

    func testV3IsOffByDefaultAndUsesTheExistingV2Fallback() {
        let settings = LocalSpeechSettings(defaults: defaults)
        XCTAssertFalse(settings.parakeetV3Enabled)
        XCTAssertEqual(settings.parakeetVariant, .v2)
    }

    func testExplicitOptInSurvivesReopeningAndTurningOffRestoresV2() {
        let settings = LocalSpeechSettings(defaults: defaults)
        settings.parakeetV3Enabled = true
        let reopened = LocalSpeechSettings(defaults: defaults)
        XCTAssertTrue(reopened.parakeetV3Enabled)
        XCTAssertEqual(reopened.parakeetVariant, .v3)
        reopened.parakeetV3Enabled = false
        XCTAssertFalse(settings.parakeetV3Enabled)
        XCTAssertEqual(settings.parakeetVariant, .v2)
    }

    func testMalformedOrUnavailablePreferencesCannotEnableV3() {
        defaults.set("true", forKey: "experiments.localParakeetV3")
        XCTAssertFalse(LocalSpeechSettings(defaults: defaults).parakeetV3Enabled)
        XCTAssertFalse(LocalSpeechSettings(defaults: nil).parakeetV3Enabled)
    }

    func testModelMetadataNamesTheSelectedVersionAndLanguages() {
        XCTAssertEqual(ParakeetVariant.v2.displayName, "Parakeet V2")
        XCTAssertEqual(ParakeetVariant.v2.languageName, "English")
        XCTAssertEqual(ParakeetVariant.v3.displayName, "Parakeet v3")
        XCTAssertEqual(ParakeetVariant.v3.languageName, "25 languages")
    }
}
