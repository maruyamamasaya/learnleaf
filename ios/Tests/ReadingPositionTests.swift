import XCTest
@testable import StudyApp

final class ReadingPositionTests: XCTestCase {
    private let article = Article(id: "20261001-171535", title: "RAG", path: "wiki/a.md", type: "study", tags: [], aliases: [], created: "", contentHash: String(repeating: "a", count: 64))
    @MainActor func testPositionSurvivesRestartBackupAndMergeWithoutChangingCompletion() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("records.json")
        let store = StudyStore(file: file)
        store.viewed(article); store.saveReadingPosition(article, fraction: 0.42)
        let restored = StudyStore(file: file)
        XCTAssertEqual(restored.data.progress[article.id]?.readingPosition?.fraction, 0.42)
        XCTAssertFalse(restored.data.progress[article.id]!.completed)
        let old = try store.export()
        restored.saveReadingPosition(article, fraction: 0.7)
        try restored.merge(old)
        XCTAssertEqual(restored.data.progress[article.id]?.readingPosition?.fraction, 0.7)
        try restored.restore(old)
        XCTAssertEqual(restored.data.progress[article.id]?.readingPosition?.fraction, 0.42)
    }
    @MainActor func testRevisionAndInvalidPositions() throws {
        let position = ReadingPosition(contentHash: article.contentHash, fraction: 0.4, updatedAt: Date())
        XCTAssertEqual(position.fraction(for: article.contentHash), 0.4)
        XCTAssertEqual(position.fraction(for: String(repeating: "b", count: 64)), 0)
        for value in [-0.1, 1.1, .infinity, .nan] {
            XCTAssertFalse(ReadingPosition(contentHash: article.contentHash, fraction: value, updatedAt: Date()).isValid)
        }
        var backup = StudyBackup()
        backup.progress[article.id] = ProgressRecord(title: "RAG", readingPosition: ReadingPosition(contentHash: "invalid", fraction: 0.4, updatedAt: Date()))
        XCTAssertThrowsError(try backup.validated())
        XCTAssertNoThrow(try StudyStore.decode(Data("{\"schemaVersion\":1,\"progress\":{\"20261001-171535\":{\"title\":\"old\",\"completed\":false}},\"sessions\":[]}".utf8)))
    }
    func testHomeSelectionExcludesCompletedAndDeletedArticles() {
        var backup = StudyBackup()
        backup.progress[article.id] = ProgressRecord(title: "RAG", completed: false, lastViewedAt: Date())
        XCTAssertEqual(HomeResumeSelection.article(in: [article], records: backup)?.id, article.id)
        XCTAssertNil(HomeResumeSelection.article(in: [], records: backup))
        backup.progress[article.id]?.completed = true
        XCTAssertNil(HomeResumeSelection.article(in: [article], records: backup))
    }
}
