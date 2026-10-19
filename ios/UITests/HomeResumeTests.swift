import XCTest

final class HomeResumeTests: XCTestCase {
    func testReadingPositionSurvivesRelaunchAndHomeResume() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["探す"].tap()
        let field = app.textFields["discovery.query"]
        XCTAssertTrue(field.waitForExistence(timeout: 15))
        field.tap(); field.typeText("RAGとは\n")
        let article = app.buttons.containing(.staticText, identifier: "RAGとは").firstMatch
        XCTAssertTrue(article.waitForExistence(timeout: 40)); article.tap()
        let position = app.buttons["reader.position"]
        XCTAssertTrue(position.waitForExistence(timeout: 20))
        // Reset this article explicitly so the test does not depend on its old bookmark.
        position.tap(); app.buttons["先頭から読む"].tap()
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        let moved = expectation(for: NSPredicate { _, _ in self.percent(position) > 2 }, evaluatedWith: position)
        wait(for: [moved], timeout: 8)
        let before = percent(position)
        let visibleParagraph = app.scrollViews.staticTexts.allElementsBoundByIndex.first {
            $0.isHittable && $0.label.count > 35 && $0.label.count < 1000
        }?.label
        XCTAssertNotNil(visibleParagraph)
        capture(app, "Reading position before leaving")
        app.tabBars.buttons["ホーム"].tap()
        let resume = app.buttons["home.resumeRead"]
        XCTAssertTrue(resume.waitForExistence(timeout: 10))
        capture(app, "Home prioritizes recent reading")
        app.terminate(); app.launch()
        XCTAssertTrue(resume.waitForExistence(timeout: 20)); resume.tap()
        XCTAssertTrue(position.waitForExistence(timeout: 15))
        let restored = expectation(for: NSPredicate { _, _ in abs(self.percent(position) - before) <= 3 }, evaluatedWith: position)
        wait(for: [restored], timeout: 8)
        if let visibleParagraph {
            let paragraph = app.staticTexts[visibleParagraph].firstMatch
            let scrolled = expectation(for: NSPredicate { _, _ in paragraph.isHittable }, evaluatedWith: paragraph)
            wait(for: [scrolled], timeout: 8)
        }
        capture(app, "Reading position restored after relaunch")
        position.tap(); app.buttons["先頭から読む"].tap()
        let top = expectation(for: NSPredicate { _, _ in self.percent(position) == 0 }, evaluatedWith: position)
        wait(for: [top], timeout: 5)
        capture(app, "Return to beginning")
    }
    func testHomeAudioResumeAfterRelaunch() {
        let app = XCUIApplication(); app.launch()
        app.tabBars.buttons["聴く"].tap()
        let track = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "RAGとは・ずんだもんの入門解説")).firstMatch
        XCTAssertTrue(track.waitForExistence(timeout: 20)); track.tap()
        XCTAssertTrue(app.buttons["一時停止"].firstMatch.waitForExistence(timeout: 10))
        app.buttons["15秒進む"].tap(); app.buttons["一時停止"].firstMatch.tap()
        app.terminate(); app.launch()
        let resume = app.buttons["home.resumeListen"]
        XCTAssertTrue(resume.waitForExistence(timeout: 20))
        capture(app, "Home prioritizes recent listening")
        resume.tap()
        XCTAssertTrue(app.buttons["一時停止"].firstMatch.waitForExistence(timeout: 10))
        capture(app, "Audio resumed from home")
        app.buttons["一時停止"].firstMatch.tap()
    }
    private func percent(_ element: XCUIElement) -> Int {
        Int(element.label.filter { $0.isNumber }) ?? -1
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = name + " hierarchy"; hierarchy.lifetime = .keepAlways; add(hierarchy)
    }
}
