import SwiftUI

struct HomeResumeSelection {
    static func readDate(_ record: ProgressRecord?) -> Date {
        max(record?.lastViewedAt ?? .distantPast, record?.readingPosition?.updatedAt ?? .distantPast)
    }
    static func article(in articles: [Article], records: StudyBackup) -> Article? {
        articles.filter { records.progress[$0.id]?.lastViewedAt != nil && records.progress[$0.id]?.completed != true }
            .sorted {
                let a = readDate(records.progress[$0.id])
                let b = readDate(records.progress[$1.id])
                return a == b ? $0.id < $1.id : a > b
            }.first
    }
    static func track(in tracks: [AudioTrack]) -> AudioTrack? {
        tracks.filter { !$0.isListened && ($0.lastPlayedAt != nil || $0.positionSeconds > 0) }
            .sorted {
                let a = $0.lastPlayedAt ?? .distantPast, b = $1.lastPlayedAt ?? .distantPast
                return a == b ? $0.id.uuidString < $1.id.uuidString : a > b
            }.first
    }
    static func prefersAudio(article: Article?, track: AudioTrack?, records: StudyBackup) -> Bool {
        guard let track else { return false }
        guard let article else { return true }
        return (track.lastPlayedAt ?? .distantPast) > readDate(records.progress[article.id])
    }
    static func time(_ seconds: Double) -> String {
        let value = seconds.isFinite ? Int(min(864000, max(0, seconds))) : 0
        return "\(value / 60):\(String(format: "%02d", value % 60))"
    }
}

@MainActor struct ResumeHomeSection: View {
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var store: StudyStore
    @EnvironmentObject private var audio: AudioLibraryModel
    @EnvironmentObject private var player: TrackPlayer
    @EnvironmentObject private var search: SearchNavigation
    @Environment(\.studyTheme) private var design
    @State private var selectedAudio: Bool?
    @State private var showPlayer = false
    private var article: Article? { HomeResumeSelection.article(in: library.articles, records: store.data) }
    private var track: AudioTrack? { HomeResumeSelection.track(in: audio.index.tracks) }
    private var audioFirst: Bool { selectedAudio ?? HomeResumeSelection.prefersAudio(article: article, track: track, records: store.data) }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("続きから").font(.title2.bold())
            if article != nil || track != nil {
                VStack(alignment: .leading, spacing: 14) {
                    if article != nil && track != nil {
                        Picker("再開する学習", selection: Binding(get: { audioFirst }, set: { selectedAudio = $0 })) {
                            Label("読む", systemImage: "book").tag(false)
                            Label("聴く", systemImage: "headphones").tag(true)
                        }.pickerStyle(.segmented)
                    }
                    if audioFirst, let track { audioResume(track) }
                    else if let article { articleResume(article) }
                }.padding(18).background { StudyTileSurface() }
                HStack {
                    Text("ほかの続き").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    NavigationLink("履歴をすべて見る") { RecentLearningView() }.font(.footnote)
                }
                if audioFirst, let article {
                    NavigationLink { ArticleReader(article: article) } label: {
                        Label(article.title, systemImage: "book").font(.subheadline)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }.buttonStyle(.plain)
                } else if let track {
                    Button { openTrack(track) } label: {
                        Label(track.manifest.title + " · " + HomeResumeSelection.time(track.positionSeconds), systemImage: "headphones")
                            .font(.subheadline).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }.buttonStyle(.plain)
                }
            } else {
                Text("読みかけの記事や聴きかけの音声が、ここに並びます。")
                    .font(.subheadline).foregroundStyle(.secondary)
                Button("記事を探す", systemImage: "magnifyingglass") { search.open() }.buttonStyle(.borderedProminent)
            }
        }
        .navigationDestination(isPresented: $showPlayer) { AudioPlayerView() }
        .onAppear { selectedAudio = nil }
        .onChange(of: search.tab) { _, tab in if tab == 0 { selectedAudio = nil } }
    }
    private func articleResume(_ article: Article) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("読む · 前回の記事", systemImage: "book").font(.caption).foregroundStyle(.secondary)
            Text(article.title).font(.title3.bold()).fixedSize(horizontal: false, vertical: true)
            let position = store.data.progress[article.id]?.readingPosition
            if let position, position.contentHash == article.contentHash {
                Text("前回の位置 · \(Int(position.fraction * 100))%付近").font(.caption).foregroundStyle(.secondary)
            } else {
                Text(position == nil ? "記事を開いて学習を再開" : "記事が更新されています · 先頭から表示")
                    .font(.caption).foregroundStyle(.secondary)
            }
            NavigationLink { ArticleReader(article: article) } label: {
                Label("読むのを再開", systemImage: "book").foregroundStyle(design.onAccent).frame(maxWidth: .infinity, minHeight: 44)
            }.buttonStyle(.borderedProminent).accessibilityIdentifier("home.resumeRead")
        }
    }
    private func audioResume(_ track: AudioTrack) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(track.lastPlayedAt == nil ? "聴く · 再生位置を保存済み" : "聴く · 前回の音声", systemImage: "headphones").font(.caption).foregroundStyle(.secondary)
            Text(track.manifest.title).font(.title3.bold()).fixedSize(horizontal: false, vertical: true)
            Text(HomeResumeSelection.time(track.positionSeconds) + "から再開").font(.caption).foregroundStyle(.secondary)
            Button { openTrack(track) } label: {
                Label("聴くのを再開", systemImage: "play.fill").foregroundStyle(design.onAccent).frame(maxWidth: .infinity, minHeight: 44)
            }.buttonStyle(.borderedProminent).accessibilityIdentifier("home.resumeListen")
        }
    }
    private func openTrack(_ track: AudioTrack) {
        if player.track?.id == track.id { player.resume() }
        else if let radio = audio.index.radio, track.lastPlayedProgramID == radio.playlist.id, radio.trackID == track.id, radio.phase != .completed {
            player.playProgram(radio.playlist)
        } else { player.play(track) }
        showPlayer = true
    }
}

@MainActor struct RecentLearningView: View {
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var store: StudyStore
    @EnvironmentObject private var audio: AudioLibraryModel
    @EnvironmentObject private var player: TrackPlayer
    @State private var showPlayer = false
    var body: some View {
        List {
            Section("最近開いた記事") {
                let articles = library.articles.filter { store.data.progress[$0.id]?.lastViewedAt != nil }.sorted {
                    HomeResumeSelection.readDate(store.data.progress[$0.id]) > HomeResumeSelection.readDate(store.data.progress[$1.id])
                }
                ForEach(articles) { SearchArticleRow(article: $0) }
            }
            Section("聴きかけの音声") {
                ForEach(audio.index.tracks.filter { !$0.isListened && ($0.lastPlayedAt != nil || $0.positionSeconds > 0) }.sorted {
                    ($0.lastPlayedAt ?? .distantPast) > ($1.lastPlayedAt ?? .distantPast)
                }) { track in
                    Button { player.play(track); showPlayer = true } label: {
                        VStack(alignment: .leading) {
                            Text(track.manifest.title)
                            Text(HomeResumeSelection.time(track.positionSeconds) + "から再開").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.navigationTitle("最近の学習").navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showPlayer) { AudioPlayerView() }
    }
}
