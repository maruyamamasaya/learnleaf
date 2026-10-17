import XCTest

final class DeviceAcceptanceTests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
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
        scrollTo(article, limit: 5); article.tap()
        XCTAssertTrue(app.buttons["この記事を聴く"].waitForExistence(timeout: 20))
        capture("Article content")
        let create = app.buttons["この記事からスライドを作る"]
        scrollTo(create); create.tap()
        let open = app.buttons["作成したスライドを開く"]
        XCTAssertTrue(open.waitForExistence(timeout: 15)); scrollTo(open); open.tap()
        XCTAssertTrue(app.buttons["ノート"].waitForExistence(timeout: 15))
        capture("Presentation")
        app.buttons["ノート"].tap()
        XCTAssertTrue(app.navigationBars["発表者ノート"].waitForExistence(timeout: 5))
        app.buttons["閉じる"].tap()
        let edit = app.buttons["スライドの順序・本文・ノートを編集"]
        XCTAssertTrue(edit.exists); edit.tap()
        capture("Presentation editor")
        app.navigationBars.buttons.firstMatch.tap()
        let pdf = app.buttons["PDF出力"]
        scrollTo(pdf, limit: 5); pdf.tap()
        XCTAssertTrue(app.buttons["出力ファイルを共有・保存"].waitForExistence(timeout: 30))
        capture("Presentation PDF export")
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

}
