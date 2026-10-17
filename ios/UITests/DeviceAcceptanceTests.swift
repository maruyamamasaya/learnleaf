import XCTest

final class DeviceAcceptanceTests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    override func tearDownWithError() throws { capture("Final state") }
    private func capture(_ name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name; screenshot.lifetime = .keepAlways; add(screenshot)
        let tree = XCTAttachment(string: app.debugDescription)
        tree.name = name + " hierarchy"; tree.lifetime = .keepAlways; add(tree)
    }
    func testReadingListeningAndVisualEntryPoints() {
        XCTAssertTrue(app.tabBars.buttons["記事"].waitForExistence(timeout: 30))
        capture("Article home")
        app.buttons["記事・音声・資料を検索"].tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 10))
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("RAG")
        capture("Search results")
        app.buttons["閉じる"].tap()
        app.tabBars.buttons["聴く"].tap()
        capture("Listening home")
        app.tabBars.buttons["見る"].tap()
        capture("Visual library")
        app.tabBars.buttons["設定"].tap()
        capture("Settings")
    }
    private func scrollTo(_ element: XCUIElement, limit: Int = 20) {
        for _ in 0..<limit {
            if element.exists && element.isHittable { return }
            app.swipeUp()
        }
        XCTFail("Could not reach: \(element)")
    }
    func testArticleAndPresentation() {
        app.buttons["記事・音声・資料を検索"].tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap(); field.typeText("RAGとは\n")
        let article = app.buttons.containing(.staticText, identifier: "RAGとは").firstMatch
        scrollTo(article, limit: 5); capture("Before opening search result"); article.tap()
        capture("After opening search result")
        XCTAssertTrue(app.buttons["この記事を聴く"].waitForExistence(timeout: 20))
        capture("Article content")
        let create = app.buttons["この記事からスライドを作る"]
        scrollTo(create); create.tap()
        let open = app.buttons["作成したスライドを開く"]
        XCTAssertTrue(open.waitForExistence(timeout: 15)); scrollTo(open); open.tap()
        XCTAssertTrue(app.buttons["ノート"].waitForExistence(timeout: 15))
        capture("Presentation")
        verifyPresentationEditingAndExport()
    }
    func testPlaybackAndBackgroundResume() {
        app.tabBars.buttons["聴く"].tap()
        let track = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "RAGとは・ずんだもんの入門解説")).firstMatch
        XCTAssertTrue(track.waitForExistence(timeout: 15)); track.tap()
        let pause = app.buttons["一時停止"].firstMatch
        XCTAssertTrue(pause.waitForExistence(timeout: 15))
        capture("Audio playing")
        pause.tap()
        let play = app.buttons["再生"].firstMatch
        XCTAssertTrue(play.waitForExistence(timeout: 5)); play.tap()
        app.buttons["15秒進む"].tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(pause.waitForExistence(timeout: 10))
        capture("Audio after background")
        pause.tap()
        app.tabBars.buttons["記事"].tap()
        capture("Mini player on article tab")
    }

    private func verifyPresentationEditingAndExport() {
        let savedTitle = "Learnleaf Acceptance " + String(UUID().uuidString.prefix(8))
        app.buttons["chevron.right"].firstMatch.tap()
        capture("Presentation second page")
        app.buttons["ノート"].tap()
        XCTAssertTrue(app.navigationBars["発表者ノート"].waitForExistence(timeout: 5))
        app.navigationBars["発表者ノート"].buttons["閉じる"].tap()
        app.buttons["スライドの順序・本文・ノートを編集"].tap()
        let title = app.textFields["タイトル"]
        XCTAssertTrue(title.waitForExistence(timeout: 5)); title.tap()
        let oldTitle = title.value as? String ?? ""
        title.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: oldTitle.count))
        title.typeText(savedTitle)
        capture("Presentation title edited")
        app.navigationBars["スライド編集"].buttons["保存"].tap()
        XCTAssertTrue(app.navigationBars[savedTitle].waitForExistence(timeout: 10))
        let pdf = app.buttons["PDF出力"]
        scrollTo(pdf, limit: 5); pdf.tap()
        XCTAssertTrue(app.buttons["出力ファイルを共有・保存"].waitForExistence(timeout: 45))
        capture("Saved presentation exported")
        removeTestResource(title: savedTitle, kind: "プレゼン")
    }
    private func removeTestResource(title: String, kind: String) {
        app.terminate(); app.launch()
        app.tabBars.buttons["見る"].tap()
        let row = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@ AND label CONTAINS %@", title + ",", kind)).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 10)); row.swipeLeft()
        app.buttons["削除"].tap()
        app.buttons["原本と派生を削除"].tap()
        let removed = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: row)
        wait(for: [removed], timeout: 10)
    }

    func testPDFImportFromFiles() {
        app.tabBars.buttons["見る"].tap()
        app.buttons["plus"].tap()
        let back = app.buttons["BackButton"].firstMatch
        XCTAssertTrue(back.waitForExistence(timeout: 10)); back.tap()
        let cloud = app.staticTexts["iCloud Drive"].firstMatch
        XCTAssertTrue(cloud.waitForExistence(timeout: 10)); cloud.tap()
        let search = app.searchFields["検索"].firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10)); search.tap()
        search.typeText("Learnleaf-Acceptance-20261017\n")
        let file = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Learnleaf-Acceptance-20261017")).firstMatch
        XCTAssertTrue(file.waitForExistence(timeout: 30)); file.tap()
        let open = app.buttons["開く"].firstMatch
        if open.waitForExistence(timeout: 3) { open.tap() }
        let row = app.buttons.matching(NSPredicate(format: "label CONTAINS %@ AND label CONTAINS %@", "Learnleaf-Acceptance-20261017", "PDF")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 30)); row.tap()
        XCTAssertTrue(app.buttons["1 / 44"].waitForExistence(timeout: 15))
        app.buttons["chevron.right"].firstMatch.tap()
        XCTAssertTrue(app.buttons["2 / 44"].waitForExistence(timeout: 5))
        app.buttons["拡大"].tap()
        app.buttons["全体"].tap()
        capture("Imported PDF second page")
        app.buttons["2 / 44"].tap()
        XCTAssertTrue(app.navigationBars["ページ一覧"].waitForExistence(timeout: 5))
        app.buttons["ページ 3"].tap()
        XCTAssertTrue(app.buttons["3 / 44"].waitForExistence(timeout: 5))
        capture("Imported PDF page picker")
        removeTestResource(title: "Learnleaf-Acceptance-20261017", kind: "PDF")
    }
}
