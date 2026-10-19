import SwiftUI
import UIKit

struct ReadingPosition: Codable, Equatable {
    let contentHash: String
    let fraction: Double
    let updatedAt: Date
    var isValid: Bool {
        fraction.isFinite && (0...1).contains(fraction) &&
        Catalog.matches(contentHash, "^[a-f0-9]{64}$") && updatedAt.timeIntervalSince1970.isFinite
    }
    func fraction(for hash: String) -> Double { contentHash == hash ? fraction : 0 }
}

// Observe the containing vertical ScrollView without replacing its delegate or
// interfering with Markdown links, tables, selection, or accessibility scrolling.
@MainActor final class ReadingScrollState: ObservableObject {
    @Published private(set) var fraction: Double = 0
    @Published private(set) var updatedArticle = false
    var active = false
    private weak var scroll: UIScrollView?
    private var observations: [NSKeyValueObservation] = []
    private var restoreWork: DispatchWorkItem?
    private var saveWork: DispatchWorkItem?
    private var currentFraction: Double = 0
    private var ready = false
    private var touched = false
    private var applying = false
    private var save: ((Double) -> Void)?

    func prepare(article: Article, store: StudyStore) {
        restoreWork?.cancel(); saveWork?.cancel()
        let position = store.data.progress[article.id]?.readingPosition
        fraction = position?.fraction(for: article.contentHash) ?? 0
        currentFraction = fraction
        updatedArticle = position != nil && position?.contentHash != article.contentHash
        touched = false; ready = true
        save = { value in store.saveReadingPosition(article, fraction: value) }
        scheduleRestore()
    }
    func attach(_ view: UIView) {
        var parent = view.superview
        while let candidate = parent, !(candidate is UIScrollView) { parent = candidate.superview }
        guard let found = parent as? UIScrollView, found !== scroll else { return }
        observations = []; scroll = found
        observations = [
            found.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.offsetChanged() }
            },
            found.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
                MainActor.assumeIsolated { self?.scheduleRestore() }
            },
            found.observe(\.bounds, options: [.new]) { [weak self] old, change in
                // bounds origin also changes on every scroll; only size changes need restoration.
                MainActor.assumeIsolated {
                    if old.bounds.size != self?.viewportSize { self?.viewportSize = old.bounds.size; self?.scheduleRestore() }
                }
            }
        ]
        viewportSize = found.bounds.size
        scheduleRestore()
    }
    private var viewportSize: CGSize = .zero
    private var extent: CGFloat {
        guard let scroll else { return 0 }
        return max(0, scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.top + scroll.adjustedContentInset.bottom)
    }
    private func scheduleRestore() {
        guard ready, let scroll, !scroll.isDragging, !scroll.isDecelerating else { return }
        restoreWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, let scroll = self.scroll, self.ready, !scroll.isDragging, !scroll.isDecelerating else { return }
            self.applying = true
            scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: CGFloat(self.currentFraction) * self.extent - scroll.adjustedContentInset.top), animated: false)
            self.applying = false
        }
        restoreWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }
    private func offsetChanged() {
        guard ready, active, !applying, let scroll else { return }
        if scroll.isDragging || scroll.isDecelerating || UIAccessibility.isVoiceOverRunning { touched = true; restoreWork?.cancel() }
        guard touched, extent > 0, scroll.isDragging || scroll.isDecelerating || UIAccessibility.isVoiceOverRunning else { return }
        let value = min(1, max(0, Double((scroll.contentOffset.y + scroll.adjustedContentInset.top) / extent)))
        guard abs(value - currentFraction) > 0.0001 else { return }
        currentFraction = value
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.checkpoint() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
    func checkpoint() {
        saveWork?.cancel()
        guard ready, touched else { return }
        fraction = currentFraction
        save?(currentFraction)
    }
    func startOver() {
        currentFraction = 0; fraction = 0; touched = true; checkpoint(); scheduleRestore()
    }
    func leave() { checkpoint(); active = false; restoreWork?.cancel(); saveWork?.cancel() }
}

struct ReadingScrollObserver: UIViewRepresentable {
    let state: ReadingScrollState
    func makeUIView(context: Context) -> UIView { Probe(state: state) }
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async { state.attach(uiView) }
    }
    private final class Probe: UIView {
        weak var state: ReadingScrollState?
        init(state: ReadingScrollState) { self.state = state; super.init(frame: .zero); isUserInteractionEnabled = false }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        override func didMoveToWindow() { super.didMoveToWindow(); DispatchQueue.main.async { self.state?.attach(self) } }
    }
}
