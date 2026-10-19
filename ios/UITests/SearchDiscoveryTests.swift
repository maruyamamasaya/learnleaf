import XCTest

// Uses the published catalog, without importing or removing personal files.
final class SearchDiscoveryTests: XCTestCase {
    func testSearchFilterSaveAndCrossTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["探す"].waitForExistence(timeout: 20))
        app.tabBars.buttons["探す"].tap()
        let field = app.textFields["discovery.query"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["フォルダから探す"].firstMatch.waitForExistence(timeout: 40))
        capture(app, "Discovery before search")
        field.tap(); field.typeText("RAG")
        let article = app.buttons.containing(.staticText, identifier: "RAGとは").firstMatch
        XCTAssertTrue(article.waitForExistence(timeout: 60))
        XCTAssertTrue(article.isHittable)
        capture(app, "Results with keyboard")
        field.typeText("\n")
        XCTAssertTrue(app.staticTexts["discovery.count"].exists)
        XCTAssertFalse(app.buttons["この検索条件を保存"].exists)
        capture(app, "Compact search results")
        app.buttons["discovery.filters"].tap()
        XCTAssertTrue(app.navigationBars["絞り込み"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["並び順"].exists)
        capture(app, "Search filters")
        app.buttons["discovery.state"].tap()
        app.buttons["未読了・未聴取"].tap()
        app.buttons["条件をクリア"].tap()
        app.buttons["結果を見る"].tap()
        XCTAssertEqual(field.value as? String, "RAG")
        XCTAssertTrue(article.waitForExistence(timeout: 5))
        article.tap()
        XCTAssertTrue(app.buttons["お気に入り・コレクションに保存"].waitForExistence(timeout: 30))
        capture(app, "Article opened from search")
        app.buttons["RAG"].firstMatch.tap()
        let tagChip = app.buttons["RAGの条件を解除"]
        XCTAssertTrue(tagChip.waitForExistence(timeout: 5))
        assertEmptyQuery(field)
        capture(app, "Article tag returns to search root")
        tagChip.tap()
        app.tabBars.buttons["ホーム"].tap()
        app.buttons["記事・音声・資料を検索"].tap()
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        assertEmptyQuery(field)
        field.tap(); field.typeText("RAGとは\n")
        XCTAssertTrue(article.waitForExistence(timeout: 20))
        let save = app.buttons["RAGとはを保存・整理"]
        XCTAssertTrue(save.exists); save.tap()
        capture(app, "Save action from result")
        XCTAssertTrue(app.buttons["完了"].waitForExistence(timeout: 5))
        app.buttons["完了"].tap()
        app.tabBars.buttons["保存"].tap()
        XCTAssertTrue(app.buttons["コレクションを作る"].waitForExistence(timeout: 5))
        capture(app, "Saved library")
    }
    private func assertEmptyQuery(_ field: XCUIElement) {
        XCTAssertTrue(field.exists)
        XCTAssertEqual(field.placeholderValue, "タイトル・キーワードで検索")
        // Device and Simulator expose an empty field differently via accessibility.
        let value = field.value as? String
        XCTAssertTrue(value == nil || value == "" || value == field.placeholderValue)
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
        let tree = XCTAttachment(string: app.debugDescription)
        tree.name = name + " hierarchy"; tree.lifetime = .keepAlways; add(tree)
    }
}
