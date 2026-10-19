import XCTest
@testable import StudyApp

final class SearchTests: XCTestCase {
    func testHistoryDeduplicatesLimitsAndRestoresConditions() {
        var preferences = SearchPreferences()
        for i in 0..<20 { preferences.remember(SearchConditions(query: String(i), tag: "RAG", favorites: true)) }
        XCTAssertEqual(preferences.history.count, 12)
        let latest = preferences.history[0]
        preferences.remember(latest)
        XCTAssertEqual(preferences.history.count, 12)
        XCTAssertEqual(preferences.history[0].tag, "RAG")
        XCTAssertTrue(preferences.history[0].favorites)
        preferences.remember(SearchConditions(query: "  "))
        XCTAssertEqual(preferences.history.count, 12)
    }
    @MainActor func testSavedSearchSurvivesRestartAndRemoval() throws {
        let suite = "search-tests-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let search = SearchNavigation(defaults: defaults)
        search.query = "RAG"; search.tag = "API"; search.order = "タイトル"
        search.save("仕事"); search.remember()
        let restored = SearchNavigation(defaults: defaults)
        let saved = try XCTUnwrap(restored.preferences.saved.first)
        restored.apply(saved.conditions)
        XCTAssertEqual(restored.conditions, search.conditions)
        restored.remove(saved.id); restored.clearHistory()
        XCTAssertTrue(SearchNavigation(defaults: defaults).preferences.saved.isEmpty)
        XCTAssertTrue(SearchNavigation(defaults: defaults).preferences.history.isEmpty)
    }
    @MainActor func testExternalSearchOpensArticleTabAndResetsPreviousRoute() {
        let suite = "search-routing-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let search = SearchNavigation(defaults: defaults)
        XCTAssertEqual(search.target, "記事")
        search.tab = 4
        search.query = "古いキーワード"; search.target = "資料"; search.audioOnly = true
        let request = search.requestID
        let collection = UUID()
        search.open(tag: "RAG", folder: "wiki", favorites: true, collection: collection)
        XCTAssertEqual(search.tab, 1)
        XCTAssertEqual(search.target, "記事")
        XCTAssertEqual(search.query, "")
        XCTAssertFalse(search.audioOnly)
        XCTAssertEqual(search.tag, "RAG")
        XCTAssertEqual(search.folder, "wiki")
        XCTAssertEqual(search.collection, collection)
        XCTAssertTrue(search.favorites)
        XCTAssertNotEqual(search.requestID, request)
        let nextRequest = search.requestID
        search.open()
        XCTAssertNotEqual(search.requestID, nextRequest)
        XCTAssertEqual(search.conditions, SearchConditions(target: "記事"))
    }
    @MainActor func testClearFiltersKeepsKeyword() {
        let suite = "search-clear-" + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let search = SearchNavigation(defaults: defaults)
        search.query = "RAG"; search.tag = "API"; search.target = "音声"
        search.favorites = true; search.state = "完了"; search.order = "タイトル"
        search.clearFilters()
        XCTAssertEqual(search.conditions, SearchConditions(query: "RAG", target: "記事"))
    }
    func testCombinedFiltersBodySearchAndMissingCollection() {
        let a = Article(id: "20261001-171535", title: "B", path: "wiki/rag/a.md", type: "study", tags: ["RAG"], aliases: [], created: "2026-10-01 17:15:35", contentHash: String(repeating: "a", count: 64))
        let b = Article(id: "20261001-171536", title: "A", path: "wiki/other/b.md", type: "study", tags: ["RAG"], aliases: [], created: "2026-10-01 17:15:36", contentHash: String(repeating: "b", count: 64))
        var records = StudyBackup(); records.favorites = [a.id]
        var conditions = SearchConditions(tag: "RAG", folder: "wiki/rag", favorites: true)
        XCTAssertEqual(SearchEngine.results(articles: [a,b], audio: AudioIndex(), records: records, search: conditions).articles.map(\.id), [a.id])
        conditions.collection = UUID()
        XCTAssertTrue(SearchEngine.results(articles: [a,b], audio: AudioIndex(), records: records, search: conditions).articles.isEmpty)
        conditions = SearchConditions(query: "本文")
        let bodies = [Library.cacheKey(a): "本文にだけある語"]
        XCTAssertEqual(SearchEngine.results(articles: [a,b], audio: AudioIndex(), records: records, search: conditions, bodies: bodies, bodyQuery: "本文").articles.map(\.id), [a.id])
        XCTAssertTrue(SearchEngine.results(articles: [a,b], audio: AudioIndex(), records: records, search: conditions, bodies: bodies, bodyQuery: "別の語").articles.isEmpty)
        conditions = SearchConditions(order: "タイトル")
        XCTAssertEqual(SearchEngine.results(articles: [a,b], audio: AudioIndex(), records: records, search: conditions).articles.map(\.id), [b.id,a.id])
    }
}
