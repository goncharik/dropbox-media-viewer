import Combine
import UIKit
import IdentifiedCollections

@MainActor
final class HomeViewModel: ObservableObject {
    enum NavigationEvents {
        case logout
        case openFile(FileEntry)
    }

    struct Dependencies {
        var authClient: AuthClient
        var fileEntryRepo: FileEntryRepository
        var contentClient: ContentClient
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var items: IdentifiedArrayOf<FileEntry> = []

    @Published var error: Error?

    init(
        dependencies: Dependencies,
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler

        dependencies.fileEntryRepo.filesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$items)
    }

    func load() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await dependencies.fileEntryRepo.reload()
        } catch {
            self.error = error
        }
    }

    func loadMoreIfNeeded(for item: FileEntry) async {
        guard items.last?.id == item.id else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            try await dependencies.fileEntryRepo.loadMoreIfNeeded()
        } catch {
            self.error = error
        }
    }

    func itemSelected(_ item: FileEntry) {
        navHandler(.openFile(item))
    }

    func logout() async {
        await dependencies.authClient.logout()
        navHandler(.logout)
    }

    func clearCaches() {
        dependencies.contentClient.clearCaches()
    
    }

    func thumbnailProvider(_ item: FileEntry) -> () async -> UIImage? {
        return { [weak self] in
            do {
                return try await self?.dependencies.contentClient.thumbnail(for: item)
            } catch {
                print("Error loading thumbnail:", error)
                return nil
            }
        }
    }
}
