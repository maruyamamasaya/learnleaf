import SwiftUI

@MainActor final class SearchNavigation: ObservableObject {
    @Published var tab = 0
    @Published private(set) var requestID = UUID()
    @Published var query = ""
    @Published var target = "記事"
    @Published var tag = ""
    @Published var folder = ""
    @Published var favorites = false
    @Published var collection: UUID?
    @Published var state = "すべて"
    @Published var audioOnly = false
    @Published var order = "標準"
    @Published private(set) var preferences = SearchPreferences()
    private let defaults: UserDefaults
    private let key = "study.searchPreferences.v1"
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key), let value = try? JSONDecoder().decode(SearchPreferences.self, from: data) { preferences = value }
    }
    var conditions: SearchConditions {
        SearchConditions(query: query, target: target, tag: tag, folder: folder, favorites: favorites,
                         collection: collection, state: state, audioOnly: audioOnly, order: order)
    }
    func apply(_ value: SearchConditions) {
        query = value.query; target = value.target; tag = value.tag; folder = value.folder
        favorites = value.favorites; collection = value.collection; state = value.state
        audioOnly = value.audioOnly; order = value.order
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(preferences) { defaults.set(data, forKey: key) }
    }
    func remember() { preferences.remember(conditions); persist() }
    func save(_ name: String) {
        let name = String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80))
        guard !name.isEmpty else { return }
        preferences.saved.append(SavedSearch(name: name, conditions: conditions)); persist()
    }
    func remove(_ id: UUID) { preferences.saved.removeAll { $0.id == id }; persist() }
    func clearHistory() { preferences.history = []; persist() }
    func open(tag: String = "", folder: String = "", favorites: Bool = false, collection: UUID? = nil) {
        reset()
        self.tag = tag; self.folder = folder; self.favorites = favorites; self.collection = collection
        target = "記事"; tab = 1; requestID = UUID()
    }
    func clearFilters() {
        let keyword = query
        reset()
        query = keyword
    }
    func reset() {
        query = ""; target = "記事"; tag = ""; folder = ""; favorites = false
        collection = nil; state = "すべて"; audioOnly = false; order = "標準"
    }
}

@MainActor struct SearchView: View {
    @EnvironmentObject private var visualResources: VisualResourceModel
    @Environment(\.studyTheme) private var design
    @EnvironmentObject private var search: SearchNavigation
    @EnvironmentObject private var library: Library
    @EnvironmentObject private var store: StudyStore
    @EnvironmentObject private var audio: AudioLibraryModel
    @EnvironmentObject private var player: TrackPlayer
    @FocusState private var searchFocused: Bool
    @State private var showFilters = false
    @State private var showSavedSearches = false
    @State private var saveName = ""
    @State private var showSaveSearch = false
    @State private var showPlayer = false
    @State private var bodies: [String: String] = [:]
    @State private var bodyTask: Task<Void, Never>?
    @State private var bodyQuery = ""
    @State private var scanning = false
    @State private var scanID = UUID()
    @State private var scanned = 0
    @State private var failures = 0
    private var tags: [String] { Array(Set(library.articles.flatMap(\.tags))).sorted() }
    private var keyword: String { search.query.trimmingCharacters(in: .whitespacesAndNewlines) }
    private func results() -> SearchEngine.Results {
        SearchEngine.results(articles: library.articles, audio: audio.index, records: store.data,
                             search: search.conditions, bodies: bodies, bodyQuery: bodyQuery)
    }
    private var hasArticleFilters: Bool { !search.tag.isEmpty || !search.folder.isEmpty || search.favorites || search.collection != nil || search.audioOnly }
    private var showArticles: Bool { search.target == "すべて" || search.target == "記事" }
    private var showTracks: Bool { search.target == "すべて" || search.target == "音声" }
    private var showPrograms: Bool { search.target == "すべて" || search.target == "番組" }
    private var showResources: Bool { search.target == "すべて" || search.target == "資料" }
    private var resourceResults: [VisualResource] {
        visualResources.resources.filter { resource in
            let linked = library.articles.filter { resource.articleIDs.contains($0.id) }
            let text = ([resource.title, resource.originalName, resource.category] + resource.tags).joined(separator: " ")
            guard keyword.isEmpty || text.localizedCaseInsensitiveContains(keyword) else { return false }
            guard search.tag.isEmpty || resource.tags.contains(search.tag) || linked.contains(where: { $0.tags.contains(search.tag) }) else { return false }
            guard search.folder.isEmpty || linked.contains(where: { $0.folder == search.folder || $0.folder.hasPrefix(search.folder + "/") }) else { return false }
            guard !search.favorites || resource.favorite else { return false }
            if let id = search.collection {
                let ids = store.data.collections?.first(where: { $0.id == id })?.articleIDs ?? []
                guard resource.articleIDs.contains(where: ids.contains) else { return false }
            }
            if search.state != "すべて" {
                guard linked.contains(where: { (store.data.progress[$0.id]?.completed == true) == (search.state == "完了") }) else { return false }
            }
            if search.audioOnly {
                guard audio.index.tracks.contains(where: { resource.articleIDs.contains($0.manifest.articleID) }) else { return false }
            }
            return true
        }
    }
    private var hasSearch: Bool {
        !keyword.isEmpty || hasArticleFilters || search.state != "すべて" || search.target != "記事" || search.order != "標準"
    }
    private var recentArticles: [Article] {
        library.articles.filter { store.data.progress[$0.id]?.lastViewedAt != nil }.sorted {
            let lhs = store.data.progress[$0.id]?.lastViewedAt ?? .distantPast
            let rhs = store.data.progress[$1.id]?.lastViewedAt ?? .distantPast
            return lhs == rhs ? $0.id < $1.id : lhs > rhs
        }
    }
    private var themeTags: [(tag: String, count: Int)] {
        let counts = library.articles.reduce(into: [String: Int]()) { counts, article in
            for tag in Set(article.tags) { counts[tag, default: 0] += 1 }
        }
        return counts.map { (tag: $0.key, count: $0.value) }.sorted {
            $0.count == $1.count ? $0.tag < $1.tag : $0.count > $1.count
        }
    }
    var body: some View {
        let result = results()
        let resources = showResources ? resourceResults : []
        let count = (showArticles ? result.articles.count : 0) + (showTracks ? result.tracks.count : 0)
            + (showPrograms ? result.programs.count : 0) + resources.count
        return NavigationStack {
            VStack(spacing: 0) {
                searchHeader
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let error = library.error {
                            Text(error).foregroundStyle(.red)
                            Button("記事一覧を再取得") { Task { await library.reload() } }
                        }
                        if library.loading { ProgressView("記事一覧を取得中") }
                        if hasSearch { searchResults(result, resources: resources, count: count) }
                        else { discovery }
                    }.padding(20).frame(maxWidth: 760).frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable { await library.reload() }
            }
            .background(design.background)
            .navigationTitle("探す").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    NavigationLink { FolderBrowser() } label: { Label("フォルダから探す", systemImage: "folder") }
                    NavigationLink { TagBrowser() } label: { Label("すべてのタグ", systemImage: "tag") }
                    NavigationLink { VisualLibraryView() } label: { Label("図解・資料ライブラリ", systemImage: "doc.richtext") }
                    Button("保存した検索・履歴", systemImage: "clock") { showSavedSearches = true }
                    Button("検索条件を保存", systemImage: "bookmark") { saveName = ""; showSaveSearch = true }
                } label: { Label("探し方", systemImage: "ellipsis.circle") }
            }
            .sheet(isPresented: $showFilters) {
                NavigationStack {
                    Form { filters }
                        .scrollContentBackground(.hidden)
                        .background(design.background)
                        .navigationTitle("絞り込み").navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) { Button("条件をクリア") { search.clearFilters() } }
                            ToolbarItem(placement: .confirmationAction) { Button("結果を見る") { showFilters = false } }
                        }
                }
            }
            .sheet(isPresented: $showSavedSearches) {
                NavigationStack {
                    ScrollView { savedSearches.padding(20) }
                        .background(design.background)
                        .navigationTitle("保存した検索・履歴").navigationBarTitleDisplayMode(.inline)
                        .toolbar { Button("閉じる") { showSavedSearches = false } }
                }
            }
            .alert("検索条件を保存", isPresented: $showSaveSearch) {
                TextField("名前", text: $saveName)
                Button("保存") { search.save(saveName) }.disabled(saveName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("キャンセル", role: .cancel) { }
            }
            .navigationDestination(isPresented: $showPlayer) { AudioPlayerView() }
            .onChange(of: search.conditions) { _, _ in
                bodyTask?.cancel(); scanID = UUID(); scanning = false; bodyQuery = ""
            }
            .onChange(of: search.tab) { _, _ in searchFocused = false }
            .onDisappear { bodyTask?.cancel(); scanID = UUID(); scanning = false }
        }
    }
    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("タイトル・キーワードで検索", text: $search.query)
                    .textFieldStyle(.plain).submitLabel(.search).focused($searchFocused)
                    .autocorrectionDisabled().accessibilityIdentifier("discovery.query")
                    .onSubmit { search.remember(); searchFocused = false }
                if !search.query.isEmpty {
                    Button { search.query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .accessibilityLabel("キーワードを消去").frame(minWidth: 44, minHeight: 44)
                }
            }.padding(.horizontal, 12).frame(minHeight: 48).background(design.surface, in: RoundedRectangle(cornerRadius: 12))
            HStack {
                Text(search.target == "記事" ? "記事を探す" : "検索対象：" + search.target).font(.caption).foregroundStyle(.secondary)
                Spacer()
                if hasSearch { Button("クリア") { search.reset() }.font(.footnote).frame(minHeight: 44) }
                Button { searchFocused = false; showFilters = true } label: { Label("絞り込み", systemImage: "slider.horizontal.3") }
                    .font(.footnote).frame(minHeight: 44).accessibilityIdentifier("discovery.filters")
            }
            activeConditions
        }.padding(.horizontal, 20).padding(.top, 12).frame(maxWidth: 760).frame(maxWidth: .infinity)
    }
    private var activeConditions: some View {
        TagFlow {
            if !search.tag.isEmpty { conditionChip(search.tag) { search.tag = "" } }
            if !search.folder.isEmpty { conditionChip(search.folder) { search.folder = "" } }
            if search.favorites { conditionChip("お気に入り") { search.favorites = false } }
            if let id = search.collection { conditionChip(store.data.collections?.first(where: { $0.id == id })?.name ?? "削除されたコレクション") { search.collection = nil } }
            if search.audioOnly { conditionChip("音声あり") { search.audioOnly = false } }
            if search.state != "すべて" { conditionChip(search.state == "完了" ? "読了・聴取済み" : "未読了・未聴取") { search.state = "すべて" } }
            if search.order != "標準" { conditionChip(search.order) { search.order = "標準" } }
        }
    }
    private var discovery: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !search.preferences.history.isEmpty {
                Text("最近の検索").font(.subheadline.bold())
                TagFlow {
                    ForEach(Array(search.preferences.history.prefix(4).enumerated()), id: \.offset) { _, value in
                        Button { search.apply(value) } label: { TagPill(text: value.query + " · " + value.target) }
                            .frame(minHeight: 44)
                    }
                }
            }
            HStack {
                Text("テーマから探す").font(.subheadline.bold())
                Spacer()
                NavigationLink("すべてのタグ") { TagBrowser() }.font(.footnote)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), alignment: .leading)], alignment: .leading, spacing: 10) {
                ForEach(Array(themeTags.prefix(6)), id: \.tag) { item in
                    Button { search.tag = item.tag } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.tag).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                            Text("\(item.count)記事").font(.caption).foregroundStyle(.secondary)
                        }.padding(14).frame(maxWidth: .infinity, alignment: .leading).background(design.surface, in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain)
                }
            }
            NavigationLink { FolderBrowser() } label: { Label("フォルダから探す", systemImage: "folder") }.frame(minHeight: 44)
            NavigationLink { ArticleResultsScreen(title: "すべての記事") } label: { Label("すべての記事 · \(library.articles.count)記事", systemImage: "list.bullet") }.frame(minHeight: 44)
            NavigationLink { VisualLibraryView(viewingOnly: true) } label: { Label("図解・資料を見る", systemImage: "doc.richtext") }.frame(minHeight: 44)
            if !recentArticles.isEmpty {
                Text("最近開いた記事").font(.subheadline.bold())
                ForEach(Array(recentArticles.prefix(3))) { SearchArticleRow(article: $0) }
            }
            if library.articles.isEmpty && !library.loading && library.error == nil {
                ContentUnavailableView("記事がありません", systemImage: "books.vertical", description: Text("下に引っ張って一覧を更新してください。"))
            }
        }
    }
    @ViewBuilder private func searchResults(_ result: SearchEngine.Results, resources: [VisualResource], count: Int) -> some View {
        Text("\(count)件").font(.footnote).foregroundStyle(.secondary).accessibilityIdentifier("discovery.count")
        if showArticles && !result.articles.isEmpty {
            if search.target == "すべて" { Text("記事 · \(result.articles.count)").font(.subheadline.bold()) }
            LazyVStack(spacing: 0) { ForEach(result.articles) { SearchArticleRow(article: $0) } }
        }
        if showTracks && !result.tracks.isEmpty {
            Text("音声 · \(result.tracks.count)").font(.subheadline.bold())
            ForEach(result.tracks) { track in
                Button { player.play(track); showPlayer = true } label: {
                    searchRow(track.manifest.title, subtitle: track.isListened ? "聴取済み" : "未聴取", icon: "headphones")
                }.buttonStyle(.plain)
            }
        }
        if showPrograms && !result.programs.isEmpty {
            Text("番組 · \(result.programs.count)").font(.subheadline.bold())
            ForEach(result.programs) { program in
                NavigationLink { ProgramDetailView(programID: program.id) } label: {
                    searchRow(program.title, subtitle: "\(program.trackIDs.count)本", icon: "play.rectangle")
                }.buttonStyle(.plain)
            }
        }
        if showResources {
            NavigationLink("図解・資料を登録・管理") { VisualLibraryView() }
            ForEach(resources) { resource in
                NavigationLink { VisualResourceDetail(id: resource.id) } label: {
                    searchRow(resource.title, subtitle: resource.kind.title, icon: "doc.richtext")
                }.buttonStyle(.plain)
            }
        }
        if count == 0 && !library.loading {
            ContentUnavailableView("対象がありません", systemImage: "magnifyingglass", description: Text("キーワードを短くするか、絞り込みを解除してください。"))
        }
        if showArticles && !keyword.isEmpty { bodySearchControls }
    }
    private var bodySearchControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            if scanning {
                ProgressView("本文を検索中 · \(scanned)記事確認")
                Button("取消") { bodyTask?.cancel() }
            } else {
                Button("記事本文も検索") { searchBodies() }
                Text("保存済み本文を検索し、未保存の本文は取得します。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if !bodyQuery.isEmpty && bodyQuery == keyword {
                Text("本文確認 \(scanned)記事 · 取得失敗 \(failures)記事")
                    .font(.caption).foregroundStyle(failures > 0 ? .orange : .secondary)
            }
        }
    }
    private var filters: some View {
        Section {
            Picker("検索対象", selection: $search.target) {
                ForEach(["記事", "音声", "番組", "資料", "すべて"], id: \.self) { Text($0) }
            }
            Picker("並び順", selection: $search.order) {
                Text("標準").tag("標準")
                Text("タイトル").tag("タイトル")
                Text("記事の新しい順").tag("新しい順")
            }
            Picker("タグ", selection: $search.tag) {
                Text("すべて").tag("")
                ForEach(tags, id: \.self) { Text($0).tag($0) }
            }
            Picker("フォルダ", selection: $search.folder) {
                Text("すべて").tag("")
                ForEach(ArticleDiscovery.folders(library.articles), id: \.self) { Text($0).tag($0) }
            }
            Picker("コレクション", selection: $search.collection) {
                Text("すべて").tag(nil as UUID?)
                ForEach(store.data.collections ?? []) { Text($0.name).tag(Optional($0.id)) }
            }
            Picker("読了・聴取状態", selection: $search.state) {
                Text("すべて").tag("すべて")
                Text("未読了・未聴取").tag("未完了")
                Text("読了・聴取済み").tag("完了")
            }.accessibilityIdentifier("discovery.state")
            Toggle("お気に入りに限定", isOn: $search.favorites)
            Toggle("音声がある記事に限定", isOn: $search.audioOnly)
        }.pickerStyle(.menu).listRowBackground(design.surface)
    }
    private func conditionChip(_ text: String, clear: @escaping () -> Void) -> some View {
        Button(action: clear) { TagPill(text: text + " ×") }.accessibilityLabel(text + "の条件を解除").frame(minHeight: 44)
    }
    private var savedSearches: some View {
        VStack(alignment: .leading, spacing: 10) {
            if search.preferences.saved.isEmpty && search.preferences.history.isEmpty {
                Text("検索履歴はキーワードの確定後に表示されます。検索条件は探し方メニューから保存できます。")
            }
            if !search.preferences.saved.isEmpty {
                DisclosureGroup("保存した検索 · \(search.preferences.saved.count)") {
                    ForEach(search.preferences.saved) { saved in
                        HStack {
                            Button(saved.name) { search.apply(saved.conditions); showSavedSearches = false }
                            Spacer()
                            Button { search.remove(saved.id) } label: { Image(systemName: "trash") }.accessibilityLabel(saved.name + "を削除")
                        }.padding(.vertical, 6)
                    }
                }
            }
            if !search.preferences.history.isEmpty {
                DisclosureGroup("検索履歴") {
                    ForEach(Array(search.preferences.history.enumerated()), id: \.offset) { _, conditions in
                        Button(conditions.query + " · " + conditions.target) { search.apply(conditions); showSavedSearches = false }.padding(.vertical, 6)
                    }
                    Button("履歴を消去") { search.clearHistory() }
                }
            }
        }.font(.footnote)
    }
    private func searchRow(_ title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(design.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background { StudyTileSurface() }
    }
    private func searchBodies() {
        bodyTask?.cancel()
        search.remember()
        let query = keyword
        let audioArticles = Set(audio.index.tracks.map { $0.manifest.articleID })
        let collectionIDs = Set(store.data.collections?.first { $0.id == search.collection }?.articleIDs ?? [])
        let candidates = library.articles.filter { article in
            ArticleDiscovery.inFolder(article, search.folder) &&
            (search.tag.isEmpty || article.tags.contains(search.tag)) &&
            (!search.favorites || store.isFavorite(article.id)) &&
            (search.collection == nil || collectionIDs.contains(article.id)) &&
            (!search.audioOnly || audioArticles.contains(article.id))
        }
        let id = UUID(); scanID = id
        bodyQuery = query; scanned = 0; failures = 0; scanning = true
        bodyTask = Task { @MainActor in
            defer { if scanID == id { scanning = false } }
            for article in candidates {
                guard !Task.isCancelled, scanID == id else { return }
                do {
                    let body = try await library.content(article)
                    guard !Task.isCancelled, scanID == id else { return }
                    bodies[Library.cacheKey(article)] = ArticleLinks.body(body)
                } catch {
                    guard !Task.isCancelled, scanID == id else { return }
                    failures += 1
                }
                scanned += 1
            }
        }
    }
}
