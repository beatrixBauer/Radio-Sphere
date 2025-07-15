//
//  TestSummaryObserver.swift
//  Radio_SphereTests
//
// Observer für Test-Zusammenfassungen
// Druckt eine kompakte Übersicht und legt sie als Attachment ab.
//

import XCTest

final class TestSummaryObserver: NSObject, XCTestObservation {

    // MARK: - Singleton
    static let shared = TestSummaryObserver()

    private var results: [(name: String, ok: Bool)] = []

    private override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    // MARK: - XCTestObservation

    func testCaseDidFinish(_ testCase: XCTestCase) {
        if let run = testCase.testRun {
            results.append((testCase.name, run.hasSucceeded))
        }
    }

    func testBundleDidFinish(_ bundle: Bundle) {
        guard !results.isEmpty else { return }

        // 1. String zusammenbauen
        var summary = "\n===== Test-Summary =====\n"
        for (idx, r) in results.enumerated() {
            summary += "Test \(idx + 1) \(r.name): \(r.ok ? "passed" : "FAILED")\n"
        }
        summary += "========================\n"

        // 2. In die Konsole (für schnelle Sichtprüfung)
        print(summary)

        // 3. Als Attachment ablegen  (erscheint unter „Attachments“)
        let attachment = XCTAttachment(string: summary)
        attachment.lifetime = .keepAlways
        XCTContext.runActivity(named: "Compact Test Summary") { act in
            act.add(attachment)
        }
    }
}
